import { Router } from "express";
import { nanoid } from "nanoid";
import { prisma } from "../db.js";

export const authRouter = Router();

authRouter.post("/guest", async (_req, res) => {
  const guestId = nanoid(10);
  const user = await prisma.user.create({
    data: {
      guestId,
      authProvider: "guest",
    },
  });
  res.json({
    userId: user.id,
    guestId,
  });
});
