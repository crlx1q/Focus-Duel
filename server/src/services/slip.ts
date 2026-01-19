import { PresenceState } from "../types.js";

export const applySlip = (
  state: PresenceState,
  now: number,
  debounceSec: number
): { next: PresenceState; accepted: boolean } => {
  if (state.lastSlipAt && now - state.lastSlipAt < debounceSec * 1000) {
    return { next: state, accepted: false };
  }
  return {
    accepted: true,
    next: {
      ...state,
      slips: state.slips + 1,
      status: "SLIP",
      lastSlipAt: now,
    },
  };
};
