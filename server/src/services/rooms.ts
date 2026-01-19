import { nanoid } from "nanoid";
import { prisma } from "../db.js";
import { RoomMode, RoomStatus } from "../types.js";

const CODE_LENGTH = 6;

export const createRoom = async ({
  hostId,
  mode,
  durationSec,
  strictnessLevel,
  focusCheckEnabled,
  isPrivate,
}: {
  hostId: string;
  mode: RoomMode;
  durationSec: number;
  strictnessLevel: number;
  focusCheckEnabled: boolean;
  isPrivate: boolean;
}) => {
  const code = nanoid(CODE_LENGTH).toUpperCase();
  return prisma.room.create({
    data: {
      code,
      mode,
      durationSec,
      strictnessLevel,
      focusCheckEnabled,
      isPrivate,
      hostId,
      status: "WAITING" as RoomStatus,
      participants: {
        create: {
          userId: hostId,
          role: "host",
        },
      },
    },
    include: {
      participants: true,
    },
  });
};

export const joinRoom = async (code: string, userId: string) => {
  const room = await prisma.room.findUnique({
    where: { code },
    include: { participants: true },
  });
  if (!room) {
    throw new Error("Room not found");
  }
  const exists = room.participants.find((p) => p.userId === userId);
  if (!exists) {
    await prisma.roomParticipant.create({
      data: {
        roomId: room.id,
        userId,
        role: "participant",
      },
    });
  }
  return prisma.room.findUniqueOrThrow({
    where: { id: room.id },
    include: { participants: true },
  });
};
