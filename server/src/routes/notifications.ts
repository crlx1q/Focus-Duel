import { Router } from "express";
import { z } from "zod";

export const notificationsRouter = Router();

notificationsRouter.post("/registerToken", async (req, res) => {
  const payload = z
    .object({
      userId: z.string(),
      token: z.string(),
      platform: z.enum(["ios", "android"]),
    })
    .parse(req.body);
  res.json({ registered: true, payload });
});
