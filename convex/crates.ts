import {
  internalMutation,
  internalQuery,
  action,
  httpAction,
} from "./_generated/server";
import { v } from "convex/values";
import { internal } from "./_generated/api";
import { verifyGuestToken } from "./guests";
import { generateText, Output } from "ai";
import { openai } from "@ai-sdk/openai";
import { z } from "zod";

const SYSTEM_PROMPT = `You are a professional options trader and risk analyst. A user has uploaded screenshots of their trade. Analyze the trade and output the following fields:

- position: The trade direction (bullish / bearish / neutral)
- risk: Overall risk level (e.g., low / medium / high)
- sprint: The time horizon (e.g., short / long)
- stance: Overall trade quality assessment (good / neutral / bad)
- observations: Answer the following questions if possible, if not possible do not list as a observation
  - "What is the trade type? Is it a buterfly trade, an iron clad, etc.." 
  - "What is the direction? Is it bullish, neutral, bearish?"
  - "What is the PnL?"
  - "What is the risk and reward ratio?"
  - "What is the win condition?"
  - "What is the probability of making profit? (rough estitmate)"
  - "What is the biggest mistake? (if applicable)"

Be direct and concise. No explanations of basic concepts. Infer missing data logically. No mardkown formatting. No emojis.`;

const crateSchema = z.object({
  position: z.union([
    z.literal("bullish"),
    z.literal("bearish"),
    z.literal("neutral"),
  ]),
  risk: z.union([z.literal("low"), z.literal("medium"), z.literal("high")]),
  sprint: z.union([z.literal("short"), z.literal("long")]),
  stance: z.union([z.literal("good"), z.literal("neutral"), z.literal("bad")]),
  observations: z.array(z.string()),
});

export const createCrate = internalMutation({
  args: {
    risk: v.union(v.literal("low"), v.literal("medium"), v.literal("high")),
    sprint: v.union(v.literal("short"), v.literal("long")),
    position: v.union(
      v.literal("bearish"),
      v.literal("bullish"),
      v.literal("neutral"),
    ),
    stance: v.union(v.literal("good"), v.literal("neutral"), v.literal("bad")),
    observations: v.array(v.string()),
    guestId: v.id("guests"),
  },
  handler: async (ctx, args) => {
    const { guestId, ...crateData } = args;
    const guest = await ctx.db.get(guestId);
    if (!guest || guest.credits < 1) {
      throw new Error("Not enough tokens.");
    }
    const crateId = await ctx.db.insert("crates", { ...crateData, guestId });
    await ctx.db.patch(guestId, { credits: guest.credits - 1 });
    return await ctx.db.get(crateId);
  },
});

export const getCratesInternal = internalQuery({
  args: {
    guestId: v.optional(v.id("guests")),
  },
  handler: async (ctx, { guestId }) => {
    if (!guestId) return [];
    return await ctx.db
      .query("crates")
      .withIndex("by_guest", (q) => q.eq("guestId", guestId))
      .order("desc")
      .collect();
  },
});

export const getCrates = action({
  args: {
    guestToken: v.optional(v.string()),
  },
  handler: async (ctx, { guestToken }): Promise<any[]> => {
    if (!guestToken) return [];
    const secret = process.env.GUEST_TOKEN_SECRET;
    if (!secret) {
      throw new Error("GUEST_TOKEN_SECRET is not configured");
    }
    const guestId = await verifyGuestToken(guestToken, secret);
    if (!guestId) return [];
    return await ctx.runQuery(internal.crates.getCratesInternal, { guestId });
  },
});

export const analyzeImages = httpAction(async (ctx, request) => {
  try {
    const authHeader = request.headers.get("Authorization");
    const guestToken = authHeader?.startsWith("Bearer ")
      ? authHeader.slice(7)
      : null;
    if (!guestToken) {
      return new Response(
        JSON.stringify({ error: "Missing guest token." }),
        { status: 401, headers: { "Content-Type": "application/json" } },
      );
    }

    const secret = process.env.GUEST_TOKEN_SECRET;
    if (!secret) {
      return new Response(
        JSON.stringify({ error: "Server misconfiguration." }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    const guestId = await verifyGuestToken(guestToken, secret);
    if (!guestId) {
      return new Response(
        JSON.stringify({ error: "Invalid guest token." }),
        { status: 401, headers: { "Content-Type": "application/json" } },
      );
    }

    const guest = await ctx.runQuery(internal.guests.getGuestById, { guestId });
    if (!guest || guest.credits < 1) {
      return new Response(
        JSON.stringify({ error: "Not enough tokens." }),
        { status: 402, headers: { "Content-Type": "application/json" } },
      );
    }

    const formData = await request.formData();
    const images: File[] = [];

    formData.forEach((value, key) => {
      if (key === "image" && value instanceof File) {
        images.push(value);
      }
    });

    if (images.length === 0) {
      return new Response(
        JSON.stringify({ error: "At least one image is required." }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    if (images.length > 5) {
      return new Response(
        JSON.stringify({ error: "Maximum of 5 images allowed." }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    const imageParts = await Promise.all(
      images.map(async (file) => {
        const arrayBuffer = await file.arrayBuffer();
        return {
          image: new Uint8Array(arrayBuffer),
          mimeType: file.type || "image/jpeg",
        };
      }),
    );

    const { output: crate } = await generateText({
      model: openai("gpt-5.5"),
      system: SYSTEM_PROMPT,
      messages: [
        {
          role: "user",
          content: [
            { type: "text", text: "Analyze these trade screenshots." },
            ...imageParts.map((part) => ({
              type: "image" as const,
              image: part.image,
              mimeType: part.mimeType,
            })),
          ],
        },
      ],
      output: Output.object({
        schema: crateSchema,
      }),
    });

    const savedCrate = await ctx.runMutation(internal.crates.createCrate, {
      ...crate,
      guestId,
    });

    return new Response(JSON.stringify(savedCrate), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
