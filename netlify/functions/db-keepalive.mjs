import { prisma } from "../../src/server/db.js";
export default async (_request) => {
    await prisma.$queryRaw `SELECT 1`;
    console.log("Scheduled database activity check succeeded.");
};
export const config = {
    schedule: "@daily",
};
