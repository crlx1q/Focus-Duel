import { describe, expect, it } from "vitest";
import { computeStats } from "../src/services/metrics.js";

describe("computeStats", () => {
  it("calculates focus time and slips", () => {
    const result = computeStats({
      userId: "user-1",
      durationSec: 1500,
      timeline: [
        { type: "SLIP", userId: "user-1", createdAt: 1000 },
        { type: "AFK", userId: "user-1", createdAt: 2000 },
        { type: "BACK", userId: "user-1", createdAt: 5000 },
      ],
    });

    expect(result.slips).toBe(1);
    expect(result.afkTimeSec).toBe(3);
    expect(result.focusTimeSec).toBe(1497);
    expect(result.trustScore).toBeLessThan(100);
  });

  it("never returns negative focus time", () => {
    const result = computeStats({
      userId: "user-2",
      durationSec: 60,
      timeline: [
        { type: "AFK", userId: "user-2", createdAt: 0 },
        { type: "BACK", userId: "user-2", createdAt: 999999 },
      ],
    });

    expect(result.focusTimeSec).toBe(0);
  });
});
