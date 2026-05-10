import { internalMutation, internalQuery, action } from "./_generated/server";
import { internal } from "./_generated/api";
import { v } from "convex/values";
import { Id } from "./_generated/dataModel";

const base64Chars =
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

function arrayBufferToBase64(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let result = "";
  for (let i = 0; i < bytes.length; i += 3) {
    const b1 = bytes[i];
    const b2 = bytes[i + 1] ?? 0;
    const b3 = bytes[i + 2] ?? 0;
    const bitmap = (b1 << 16) | (b2 << 8) | b3;
    result += base64Chars[(bitmap >> 18) & 63];
    result += base64Chars[(bitmap >> 12) & 63];
    result += i + 1 < bytes.length ? base64Chars[(bitmap >> 6) & 63] : "=";
    result += i + 2 < bytes.length ? base64Chars[bitmap & 63] : "=";
  }
  return result;
}

function base64ToArrayBuffer(base64: string): ArrayBuffer {
  const normalized = base64.replace(/=+$/, "");
  const bytes: number[] = [];
  for (let i = 0; i < normalized.length; i += 4) {
    const c1 = base64Chars.indexOf(normalized[i]);
    const c2 = base64Chars.indexOf(normalized[i + 1]);
    const c3 =
      normalized[i + 2] === undefined
        ? -1
        : base64Chars.indexOf(normalized[i + 2]);
    const c4 =
      normalized[i + 3] === undefined
        ? -1
        : base64Chars.indexOf(normalized[i + 3]);
    const bitmap =
      (c1 << 18) |
      (c2 << 12) |
      ((c3 === -1 ? 0 : c3) << 6) |
      (c4 === -1 ? 0 : c4);
    bytes.push((bitmap >> 16) & 255);
    if (c3 !== -1) bytes.push((bitmap >> 8) & 255);
    if (c4 !== -1) bytes.push(bitmap & 255);
  }
  return new Uint8Array(bytes).buffer;
}

export async function signGuestToken(
  guestId: string,
  secret: string,
): Promise<string> {
  const payload = `hc_guest:${guestId}`;
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "HMAC",
    key,
    encoder.encode(payload),
  );
  return `${payload}.${arrayBufferToBase64(signature)}`;
}

export async function verifyGuestToken(
  token: string,
  secret: string,
): Promise<Id<"guests"> | null> {
  const parts = token.split(".");
  if (parts.length !== 2) return null;
  const [payload, sigBase64] = parts;
  if (!payload.startsWith("hc_guest:")) return null;

  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["verify"],
  );
  const signature = base64ToArrayBuffer(sigBase64);
  const valid = await crypto.subtle.verify(
    "HMAC",
    key,
    signature,
    encoder.encode(payload),
  );
  if (!valid) return null;
  return payload.slice("hc_guest:".length) as Id<"guests">;
}

export const getGuestById = internalQuery({
  args: { guestId: v.id("guests") },
  handler: async (ctx, { guestId }) => {
    return await ctx.db.get(guestId);
  },
});

export const insertGuest = internalMutation({
  args: {},
  handler: async (ctx): Promise<Id<"guests">> => {
    const guestId = await ctx.db.insert("guests", { credits: 10 });
    return guestId;
  },
});

export const createGuest = action({
  args: {},
  handler: async (ctx): Promise<string> => {
    const guestId: Id<"guests"> = await ctx.runMutation(internal.guests.insertGuest, {});
    const secret = process.env.GUEST_TOKEN_SECRET;
    if (!secret) {
      throw new Error("GUEST_TOKEN_SECRET is not configured");
    }
    return await signGuestToken(guestId, secret);
  },
});
