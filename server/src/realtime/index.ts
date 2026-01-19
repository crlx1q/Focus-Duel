import { Server, Socket } from "socket.io";
import jwt from "jsonwebtoken";
import { z } from "zod";
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
  const rateLimiter = new Map<string, { count: number; resetAt: number }>();
  const logEvent = async (sessionId: string | undefined, userId: string, type: EventType, reason?: string) => {
    if (!sessionId) return;
    await prisma.event.create({
      data: {
        sessionId,
        userId,
        type,
        reason,
      },
    });
  };

  const canProceed = (socket: Socket, event: string, limit = 30) => {
    const key = `${socket.id}:${event}`;
    const now = Date.now();
    const bucket = rateLimiter.get(key);
    if (!bucket || bucket.resetAt < now) {
      rateLimiter.set(key, { count: 1, resetAt: now + 60_000 });
      return true;
    }
    if (bucket.count >= limit) return false;
    bucket.count += 1;
    return true;
  };

  nsp.on("connection", (socket: Socket) => {
    let currentUserId: string | null = null;
    let currentRoomId: string | null = null;

    socket.on("auth", async (payload: unknown) => {
      if (!canProceed(socket, "auth", 10)) return;
      const parsed = z.object({ token: z.string() }).safeParse(payload);
      if (!parsed.success) return;
      try {
        const decoded = jwt.verify(parsed.data.token, config.jwtSecret) as { userId: string };
        const user = await prisma.user.findUnique({ where: { id: decoded.userId } });
        if (!user) return;
        currentUserId = user.id;
        socket.emit("auth:ok", { userId: user.id, tServer: Date.now() });
      } catch (error) {
        socket.emit("auth:error", { error: "Invalid token" });
      }
    });

    socket.on("room:join", async (payload: unknown) => {
      if (!canProceed(socket, "room:join", 20)) return;
      const parsed = z.object({ code: z.string() }).safeParse(payload);
      if (!parsed.success) return;
      if (!currentUserId) return;
      const room = await prisma.room.findUnique({ where: { code: parsed.data.code }, include: { participants: true } });
      if (!room) return;
      try {
        await ensureParticipant(room.id, currentUserId);
      } catch (error) {
        socket.emit("room:error", { error: "Not a participant" });
        return;
      }
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
      if (!canProceed(socket, "room:leave", 40)) return;
      if (!currentRoomId || !currentUserId) return;
      socket.leave(currentRoomId);
      nsp.to(currentRoomId).emit("room:event", {
        type: "LEAVE" as EventType,
        userId: currentUserId,
        tServer: Date.now(),
      });
      currentRoomId = null;
    });

    socket.on("hb", async (payload: unknown) => {
      if (!canProceed(socket, "hb", 120)) return;
      const parsed = z.object({ roomId: z.string(), tClient: z.number() }).safeParse(payload);
      if (!parsed.success) return;
      if (!currentUserId) return;
      await ensureParticipant(parsed.data.roomId, currentUserId);
      roomState.updatePresence(parsed.data.roomId, currentUserId, (state) => ({
        ...state,
        lastSeen: Date.now(),
        status: state.status === "AFK" ? "FOCUS" : state.status,
      }));
      nsp.to(parsed.data.roomId).emit("room:state", {
        roomId: parsed.data.roomId,
        statuses: Array.from(roomState.get(parsed.data.roomId)?.presence ?? []),
        tServer: Date.now(),
      });
    });

    socket.on("slip", async (payload: unknown) => {
      if (!canProceed(socket, "slip", 30)) return;
      const parsed = z.object({ roomId: z.string(), reason: z.string() }).safeParse(payload);
      if (!parsed.success) return;
      if (!currentUserId) return;
      await ensureParticipant(parsed.data.roomId, currentUserId);
      const runtime = roomState.get(parsed.data.roomId);
      if (!runtime || runtime.timer.status !== "RUNNING") return;
      let accepted = true;
      const now = Date.now();
      roomState.updatePresence(parsed.data.roomId, currentUserId, (state) => {
        const result = applySlip(state, now, config.slipDebounceSec);
        accepted = result.accepted;
        return result.next;
      });
      if (!accepted) return;
      await logEvent(runtime.sessionId, currentUserId, "SLIP", parsed.data.reason);
      nsp.to(parsed.data.roomId).emit("room:event", {
        type: "SLIP" as EventType,
        userId: currentUserId,
        reason: parsed.data.reason,
        tServer: now,
      });
    });

    socket.on("focus_check:reply", async (payload: unknown) => {
      if (!canProceed(socket, "focus_check:reply", 30)) return;
      const parsed = z.object({ roomId: z.string(), ok: z.boolean() }).safeParse(payload);
      if (!parsed.success) return;
      if (!currentUserId) return;
      await ensureParticipant(parsed.data.roomId, currentUserId);
      if (parsed.data.ok) {
        await logEvent(roomState.get(parsed.data.roomId)?.sessionId, currentUserId, "BACK", "check_ok");
        nsp.to(parsed.data.roomId).emit("room:event", {
          type: "BACK" as EventType,
          userId: currentUserId,
          reason: "check_ok",
          tServer: Date.now(),
        });
      } else {
        await logEvent(
          roomState.get(parsed.data.roomId)?.sessionId,
          currentUserId,
          "CHECK_MISSED",
          "missed_check"
        );
        nsp.to(parsed.data.roomId).emit("room:event", {
          type: "CHECK_MISSED" as EventType,
          userId: currentUserId,
          reason: "missed_check",
          tServer: Date.now(),
        });
      }
    });

    socket.on("room:start", async () => {
      if (!canProceed(socket, "room:start", 10)) return;
      if (!currentRoomId || !currentUserId) return;
      const room = await prisma.room.findUnique({ where: { id: currentRoomId } });
      if (!room || room.hostId !== currentUserId) return;
      const startedAt = new Date();
      await prisma.room.update({
        where: { id: room.id },
        data: { status: "RUNNING", startedAt },
      });
      const session = await prisma.session.create({
        data: {
          roomId: room.id,
          startedAt,
          serverTimeOffset: 0,
          finalState: "RUNNING",
        },
      });
      roomState.setSession(room.id, session.id);
      roomState.setStarted(room.id, Date.now());
      await logEvent(session.id, currentUserId, "START");
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
    logEvent(roomState.get(roomId)?.sessionId, userId, "AFK");
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
        const runtimeSessionId = runtime.sessionId;
        const session = runtimeSessionId
          ? await prisma.session.update({
              where: { id: runtimeSessionId },
              data: {
                finishedAt: new Date(),
                finalState: "FINISHED",
              },
            })
          : await prisma.session.create({
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
        await Promise.all(
          timeline.map((event) => prisma.event.create({ data: { sessionId: session.id, userId: event.userId, type: event.type } }))
        );
        nsp.to(room.id).emit("room:finish", {
          results: Array.from(presence.entries()),
          timeline,
          tServer: now,
        });
      }
    }
  }, 1000);
};
