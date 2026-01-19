import { describe, expect, it } from "vitest";
import { applySlip } from "../src/services/slip.js";

const baseState = {
  lastSeen: Date.now(),
  status: "FOCUS" as const,
  slips: 0,
  trustScore: 100,
};

describe("applySlip", () => {
  it("accepts first slip", () => {
    const result = applySlip(baseState, 1000, 8);
    expect(result.accepted).toBe(true);
    expect(result.next.slips).toBe(1);
  });

  it("debounces rapid slips", () => {
    const first = applySlip(baseState, 1000, 8);
    const second = applySlip(first.next, 2000, 8);
    expect(second.accepted).toBe(false);
    expect(second.next.slips).toBe(1);
  });
});
