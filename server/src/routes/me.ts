import { Router } from "express";
import { prisma } from "../db.js";

export const meRouter = Router();

meRouter.get("/stats", async (req, res) => {
  const userId = String(req.query.userId ?? "");
  if (!userId) {
    res.status(400).json({ error: "userId required" });
    return;
  }
  const stats = await prisma.participantSessionStat.findMany({
    where: { userId },
    take: 20,
    orderBy: { id: "desc" },
  });
  res.json({ stats });
});
