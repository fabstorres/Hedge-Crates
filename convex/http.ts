import { httpRouter } from "convex/server";
import { analyzeImages } from "./crates";

const http = httpRouter();

http.route({
  path: "/api/analyzeImages",
  method: "POST",
  handler: analyzeImages,
});

export default http;
