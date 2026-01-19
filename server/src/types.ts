export type RoomStatus = "WAITING" | "RUNNING" | "FINISHED" | "CANCELLED";

export type ParticipantStatus = "FOCUS" | "SLIP" | "AFK";

export type RoomMode = "DUEL" | "COWORK";

export type EventType =
  | "START"
  | "SLIP"
  | "AFK"
  | "BACK"
  | "FINISH"
  | "JOIN"
  | "LEAVE"
  | "CHECK_PROMPT"
  | "CHECK_MISSED";

export type RoomTimerState = {
  roomId: string;
  startedAt: number | null;
  durationSec: number;
  status: RoomStatus;
};

export type PresenceState = {
  lastSeen: number;
  status: ParticipantStatus;
  slips: number;
  trustScore: number;
  lastSlipAt?: number;
  afkStartedAt?: number;
};
