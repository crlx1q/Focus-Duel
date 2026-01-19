import dotenv from "dotenv";

dotenv.config();

const requireEnv = (key: string) => {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Missing required env: ${key}`);
  }
  return value;
};

export const config = {
  port: Number(process.env.PORT ?? 4000),
  jwtSecret: requireEnv("JWT_SECRET"),
  heartbeatTimeoutSec: Number(process.env.HEARTBEAT_TIMEOUT_SEC ?? 10),
  slipDebounceSec: Number(process.env.SLIP_DEBOUNCE_SEC ?? 8),
  focusCheckMinMinute: Number(process.env.FOCUS_CHECK_MIN_MINUTE ?? 8),
  focusCheckMaxMinute: Number(process.env.FOCUS_CHECK_MAX_MINUTE ?? 12),
  allowedOrigins: (process.env.ALLOWED_ORIGINS ?? "")
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean),
};
