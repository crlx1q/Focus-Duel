import { Router } from "express";
import { z } from "zod";
import { requireAuth } from "../middleware/auth.js";

export const notificationsRouter = Router();

notificationsRouter.post("/registerToken", requireAuth, async (req, res) => {
  const payload = z
    .object({
      token: z.string(),
      platform: z.enum(["ios", "android"]),
    })
    .parse(req.body);
  res.json({ registered: true, userId: res.locals.userId, payload });
});
