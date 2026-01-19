import { Server, Socket } from "socket.io";
import { config } from "../config.js";
import { prisma } from "../db.js";
import { computeStats } from "../services/metrics.js";
import { applySlip } from "../services/slip.js";
import { roomState, heartbeatMonitor } from "../state.js";
import { EventType, ParticipantStatus } from "../types.js";

const ROOM_NAMESPACE = "/realtime";

const ensureParticipant = async (roomId: string, userId: string) => {
  const participant = await prisma.roomParticipant.findFirst({
    where: { roomId, userId, leftAt: null },
  });
  if (!participant) {
    throw new Error("Not a participant");
  }
};

export const setupRealtime = (io: Server) => {
  const nsp = io.of(ROOM_NAMESPACE);

  nsp.on("connection", (socket: Socket) => {
    let currentUserId: string | null = null;
    let currentRoomId: string | null = null;

    socket.on("auth", async ({ guestId }: { guestId?: string }) => {
      if (!guestId) return;
      const user = await prisma.user.findUnique({ where: { guestId } });
      if (!user) return;
      currentUserId = user.id;
      socket.emit("auth:ok", { userId: user.id, tServer: Date.now() });
    });

    socket.on("room:join", async ({ code }: { code: string }) => {
      if (!currentUserId) return;
      const room = await prisma.room.findUnique({ where: { code }, include: { participants: true } });
      if (!room) return;
      currentRoomId = room.id;
      socket.join(room.id);
      roomState.ensureRoom(room.id, room.durationSec);
      socket.emit("room:state", {
        room,
        participants: room.participants,
        timer: roomState.get(room.id)?.timer,
        statuses: Array.from(roomState.get(room.id)?.presence ?? []),
        tServer: Date.now(),
      });
      nsp.to(room.id).emit("room:event", {
        type: "JOIN" as EventType,
        userId: currentUserId,
        tServer: Date.now(),
      });
    });

    socket.on("room:leave", async () => {
      if (!currentRoomId || !currentUserId) return;
      socket.leave(currentRoomId);
      nsp.to(currentRoomId).emit("room:event", {
        type: "LEAVE" as EventType,
        userId: currentUserId,
        tServer: Date.now(),
      });
      currentRoomId = null;
    });

    socket.on("hb", async ({ roomId }: { roomId: string; tClient: number }) => {
      if (!currentUserId) return;
      await ensureParticipant(roomId, currentUserId);
      roomState.updatePresence(roomId, currentUserId, (state) => ({
        ...state,
        lastSeen: Date.now(),
        status: state.status === "AFK" ? "FOCUS" : state.status,
      }));
      nsp.to(roomId).emit("room:state", {
        roomId,
        statuses: Array.from(roomState.get(roomId)?.presence ?? []),
        tServer: Date.now(),
      });
    });

    socket.on("slip", async ({ roomId, reason }: { roomId: string; reason: string }) => {
      if (!currentUserId) return;
      await ensureParticipant(roomId, currentUserId);
      const runtime = roomState.get(roomId);
      if (!runtime || runtime.timer.status !== "RUNNING") return;
      let accepted = true;
      const now = Date.now();
      roomState.updatePresence(roomId, currentUserId, (state) => {
        const result = applySlip(state, now, config.slipDebounceSec);
        accepted = result.accepted;
        return result.next;
      });
      if (!accepted) return;
      nsp.to(roomId).emit("room:event", {
        type: "SLIP" as EventType,
        userId: currentUserId,
        reason,
        tServer: now,
      });
    });

    socket.on("focus_check:reply", async ({ roomId, ok }: { roomId: string; ok: boolean }) => {
      if (!currentUserId) return;
      await ensureParticipant(roomId, currentUserId);
      if (ok) {
        nsp.to(roomId).emit("room:event", {
          type: "BACK" as EventType,
          userId: currentUserId,
          reason: "check_ok",
          tServer: Date.now(),
        });
      } else {
        nsp.to(roomId).emit("room:event", {
          type: "CHECK_MISSED" as EventType,
          userId: currentUserId,
          reason: "missed_check",
          tServer: Date.now(),
        });
      }
    });

    socket.on("room:start", async () => {
      if (!currentRoomId || !currentUserId) return;
      const room = await prisma.room.findUnique({ where: { id: currentRoomId } });
      if (!room || room.hostId !== currentUserId) return;
      await prisma.room.update({
        where: { id: room.id },
        data: { status: "RUNNING", startedAt: new Date() },
      });
      roomState.setStarted(room.id, Date.now());
      nsp.to(room.id).emit("room:event", {
        type: "START" as EventType,
        userId: currentUserId,
        tServer: Date.now(),
      });
    });
  });

  heartbeatMonitor((roomId, userId) => {
    roomState.updatePresence(roomId, userId, (state) => ({
      ...state,
      status: "AFK" as ParticipantStatus,
      afkStartedAt: state.afkStartedAt ?? Date.now(),
    }));
    nsp.to(roomId).emit("room:event", {
      type: "AFK" as EventType,
      userId,
      tServer: Date.now(),
    });
  });

  setInterval(async () => {
    const now = Date.now();
    const rooms = await prisma.room.findMany({ where: { status: "RUNNING" } });
    for (const room of rooms) {
      const runtime = roomState.get(room.id);
      if (!runtime?.timer.startedAt) continue;
      const elapsedSec = Math.floor((now - runtime.timer.startedAt) / 1000);
      const remainingSec = Math.max(0, room.durationSec - elapsedSec);
      nsp.to(room.id).emit("room:timer", { remainingSec, tServer: now });
      if (remainingSec === 0) {
        await prisma.room.update({ where: { id: room.id }, data: { status: "FINISHED", finishedAt: new Date() } });
        const session = await prisma.session.create({
          data: {
            roomId: room.id,
            startedAt: room.startedAt ?? new Date(),
            finishedAt: new Date(),
            serverTimeOffset: 0,
            finalState: "FINISHED",
          },
        });
        const presence = runtime.presence;
        const timeline = [] as { type: EventType; userId: string; createdAt: number }[];
        presence.forEach((_state, userId) => {
          timeline.push({ type: "FINISH", userId, createdAt: now });
        });
        for (const [userId] of presence) {
          const stats = computeStats({
            userId,
            durationSec: room.durationSec,
            timeline,
          });
          await prisma.participantSessionStat.create({
            data: {
              sessionId: session.id,
              userId,
              focusTimeSec: stats.focusTimeSec,
              slips: stats.slips,
              afkTimeSec: stats.afkTimeSec,
              trustScore: stats.trustScore,
            },
          });
        }
        nsp.to(room.id).emit("room:finish", {
          results: Array.from(presence.entries()),
          timeline,
          tServer: now,
        });
      }
    }
  }, 1000);
};
