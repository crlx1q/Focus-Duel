import { EventType } from "../types.js";

export type TimelineEvent = {
  type: EventType;
  userId: string;
  createdAt: number;
};

export type StatInput = {
  userId: string;
  durationSec: number;
  timeline: TimelineEvent[];
};

export type StatOutput = {
  focusTimeSec: number;
  slips: number;
  afkTimeSec: number;
  trustScore: number;
};

export const computeStats = ({ userId, durationSec, timeline }: StatInput): StatOutput => {
  const userEvents = timeline.filter((event) => event.userId === userId);
  const slips = userEvents.filter((event) => event.type === "SLIP").length;
  let afkTimeSec = 0;
  let afkStart: number | null = null;

  for (const event of userEvents) {
    if (event.type === "AFK") {
      afkStart = event.createdAt;
    }
    if (event.type === "BACK" && afkStart !== null) {
      afkTimeSec += Math.max(0, Math.floor((event.createdAt - afkStart) / 1000));
      afkStart = null;
    }
  }

  const focusTimeSec = Math.max(0, durationSec - afkTimeSec);
  const trustScore = Math.max(0, 100 - slips * 10 - Math.floor(afkTimeSec / 30));

  return {
    focusTimeSec,
    slips,
    afkTimeSec,
    trustScore,
  };
};
