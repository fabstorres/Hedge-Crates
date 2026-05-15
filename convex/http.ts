import { httpRouter } from "convex/server";
import { analyzeImages } from "./crates";
import { handleClerkWebhook } from "./clerk";

const http = httpRouter();

http.route({
  path: "/api/analyzeImages",
  method: "POST",
  handler: analyzeImages,
});

http.route({
  path: "/api/webhooks/clerk",
  method: "POST",
  handler: handleClerkWebhook,
});

export default http;
