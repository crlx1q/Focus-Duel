import dotenv from "dotenv";

dotenv.config();

export const config = {
  port: Number(process.env.PORT ?? 4000),
  jwtSecret: process.env.JWT_SECRET ?? "dev-secret",
  heartbeatTimeoutSec: Number(process.env.HEARTBEAT_TIMEOUT_SEC ?? 10),
  slipDebounceSec: Number(process.env.SLIP_DEBOUNCE_SEC ?? 8),
  focusCheckMinMinute: Number(process.env.FOCUS_CHECK_MIN_MINUTE ?? 8),
  focusCheckMaxMinute: Number(process.env.FOCUS_CHECK_MAX_MINUTE ?? 12),
};
