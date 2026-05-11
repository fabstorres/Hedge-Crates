import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  users: defineTable({
    credits: v.number(),
    userId: v.string(),
    guestId: v.optional(v.id("guests")),
  }),
  guests: defineTable({
    credits: v.number(),
  }),
  crates: defineTable({
    risk: v.union(v.literal("low"), v.literal("medium"), v.literal("high")),
    sprint: v.union(v.literal("short"), v.literal("long")),
    position: v.union(
      v.literal("bearish"),
      v.literal("bullish"),
      v.literal("neutral"),
    ),
    stance: v.union(v.literal("good"), v.literal("neutral"), v.literal("bad")),
    observations: v.array(v.string()),
    guestId: v.optional(v.id("guests")),
    userId: v.optional(v.id("users")),
  })
    .index("by_guest", ["guestId"]),
});
