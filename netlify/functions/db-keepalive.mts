import type { Config } from "@netlify/functions";
import { prisma } from "../../src/server/db.js";

export default async (_request: Request) => {
  await prisma.$queryRaw`SELECT 1`;
  console.log("Scheduled database activity check succeeded.");
};

export const config: Config = {
  schedule: "@daily",
};
