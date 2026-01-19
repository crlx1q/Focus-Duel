import { config } from "./config.js";
import { PresenceState, RoomTimerState } from "./types.js";

export type RoomRuntime = {
  timer: RoomTimerState;
  presence: Map<string, PresenceState>;
  focusCheckAt?: number;
  sessionId?: string;
};

const rooms = new Map<string, RoomRuntime>();

export const roomState = {
  ensureRoom(roomId: string, durationSec: number): RoomRuntime {
    const existing = rooms.get(roomId);
    if (existing) {
      return existing;
    }
    const runtime: RoomRuntime = {
      timer: {
        roomId,
        startedAt: null,
        durationSec,
        status: "WAITING",
      },
      presence: new Map(),
    };
    rooms.set(roomId, runtime);
    return runtime;
  },
  get(roomId: string): RoomRuntime | undefined {
    return rooms.get(roomId);
  },
  setStarted(roomId: string, startedAt: number) {
    const runtime = rooms.get(roomId);
    if (!runtime) return;
      runtime.timer.startedAt = startedAt;
      runtime.timer.status = "RUNNING";
    const focusCheckMinute =
      config.focusCheckMinMinute +
      Math.floor(Math.random() * (config.focusCheckMaxMinute - config.focusCheckMinMinute + 1));
    runtime.focusCheckAt = startedAt + focusCheckMinute * 60 * 1000;
  },
  setSession(roomId: string, sessionId: string) {
    const runtime = rooms.get(roomId);
    if (!runtime) return;
    runtime.sessionId = sessionId;
  },
  setFinished(roomId: string) {
    const runtime = rooms.get(roomId);
    if (!runtime) return;
    runtime.timer.status = "FINISHED";
  },
  updatePresence(roomId: string, userId: string, updater: (state: PresenceState) => PresenceState) {
    const runtime = rooms.get(roomId);
    if (!runtime) return;
    const current = runtime.presence.get(userId) ?? {
      lastSeen: Date.now(),
      status: "FOCUS",
      slips: 0,
      trustScore: 100,
    };
    runtime.presence.set(userId, updater(current));
  },
};

export const heartbeatMonitor = (onAfk: (roomId: string, userId: string) => void) => {
  setInterval(() => {
    const now = Date.now();
    rooms.forEach((runtime, roomId) => {
      runtime.presence.forEach((state, userId) => {
        const isLate = now - state.lastSeen > config.heartbeatTimeoutSec * 1000;
        if (isLate && state.status !== "AFK") {
          onAfk(roomId, userId);
        }
      });
    });
  }, 1000);
};
