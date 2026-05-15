import { httpAction, internalMutation } from "./_generated/server";
import { v } from "convex/values";
import { internal } from "./_generated/api";
import { Webhook } from "svix";

/** Shape of a Clerk webhook event payload. `svix` returns `unknown` from
 * `verify()`, so we cast into this concrete type. */
interface ClerkWebhookEvent {
  type: string;
  data: Record<string, unknown> & { id?: string };
}

/**
 * Internal mutation to insert a new user into the Convex database
 * when Clerk fires a `user.created` event. Idempotent — skips if
 * the `userId` already exists.
 */
export const createUser = internalMutation({
  args: {
    userId: v.string(),
  },
  handler: async (ctx, args) => {
    // Check if user already exists (idempotent)
    const existing = await ctx.db
      .query("users")
      .withIndex("by_userId", (q) => q.eq("userId", args.userId))
      .first();

    if (existing) {
      return existing._id;
    }

    const id = await ctx.db.insert("users", {
      userId: args.userId,
      credits: 10,
    });

    return id;
  },
});

/**
 * HTTP action that serves as the Clerk webhook endpoint.
 *
 * 1. Reads the `CLERK_WEBHOOK_SECRET` from environment variables.
 * 2. Verifies the Svix signature on the incoming request.
 * 3. Listens exclusively for `user.created` events.
 * 4. Persists the new user via the `createUser` internal mutation.
 */
export const handleClerkWebhook = httpAction(async (ctx, request) => {
  try {
    const secret = process.env.CLERK_WEBHOOK_SECRET;
    if (!secret) {
      console.error("CLERK_WEBHOOK_SECRET is not configured");
      return new Response(
        JSON.stringify({ error: "Webhook secret not configured" }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    // Read the raw body *before* Svix consumes it
    const payload = await request.text();

    // Collect Svix verification headers
    const svixHeaders: Record<string, string> = {
      "svix-id": request.headers.get("svix-id") ?? "",
      "svix-timestamp": request.headers.get("svix-timestamp") ?? "",
      "svix-signature": request.headers.get("svix-signature") ?? "",
    };

    // Verify the webhook signature (returns `unknown` in svix typings)
    const wh = new Webhook(secret);
    const evt = wh.verify(payload, svixHeaders) as ClerkWebhookEvent;

    // Only process `user.created` events
    if (evt.type === "user.created" && typeof evt.data?.id === "string") {
      const clerkUserId = evt.data.id;
      await ctx.runMutation(internal.clerk.createUser, {
        userId: clerkUserId,
      });
      console.log(`User created: ${clerkUserId}`);
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    console.error("Clerk webhook error:", message);
    return new Response(JSON.stringify({ error: message }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }
});
