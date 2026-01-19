import { Router } from "express";
import { z } from "zod";
import { createRoom, joinRoom } from "../services/rooms.js";
import { prisma } from "../db.js";
import { requireAuth } from "../middleware/auth.js";

export const roomsRouter = Router();

roomsRouter.post("/", requireAuth, async (req, res) => {
  const payload = z
    .object({
      mode: z.enum(["DUEL", "COWORK"]),
      durationSec: z.number().min(300),
      strictnessLevel: z.number().min(1).max(3),
      focusCheckEnabled: z.boolean(),
      isPrivate: z.boolean(),
    })
    .parse(req.body);

  const room = await createRoom({ ...payload, hostId: res.locals.userId });
  res.json(room);
});

roomsRouter.post("/join", requireAuth, async (req, res) => {
  const payload = z.object({ code: z.string() }).parse(req.body);
  const room = await joinRoom(payload.code, res.locals.userId);
  res.json(room);
});

roomsRouter.get("/:code", requireAuth, async (req, res) => {
  const room = await prisma.room.findUnique({
    where: { code: req.params.code },
    include: { participants: true },
  });
  if (!room) {
    res.status(404).json({ error: "Room not found" });
    return;
  }
  res.json(room);
});

roomsRouter.post("/:code/start", requireAuth, async (req, res) => {
  const room = await prismaKnownRoom(req.params.code);
  if (room.hostId !== res.locals.userId) {
    res.status(403).json({ error: "Only host can start" });
    return;
  }
  const updated = await prisma.room.update({
    where: { id: room.id },
    data: {
      status: "RUNNING",
      startedAt: new Date(),
    },
  });
  res.json(updated);
});

const prismaKnownRoom = async (code: string) => {
  const room = await prisma.room.findUnique({ where: { code } });
  if (!room) {
    throw new Error("Room not found");
  }
  return room;
};
