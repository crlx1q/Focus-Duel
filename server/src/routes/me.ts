import { Router } from "express";
import { prisma } from "../db.js";
import { requireAuth } from "../middleware/auth.js";

export const meRouter = Router();

meRouter.get("/stats", requireAuth, async (_req, res) => {
  const userId = res.locals.userId as string;
  const stats = await prisma.participantSessionStat.findMany({
    where: { userId },
    take: 20,
    orderBy: { id: "desc" },
  });
  res.json({ stats });
});
