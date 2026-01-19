import { NextFunction, Request, Response } from "express";

const buckets = new Map<string, { count: number; resetAt: number }>();

export const rateLimit = (keyPrefix: string, maxPerMinute: number) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const key = `${keyPrefix}:${req.ip}`;
    const now = Date.now();
    const bucket = buckets.get(key);
    if (!bucket || bucket.resetAt < now) {
      buckets.set(key, { count: 1, resetAt: now + 60_000 });
      next();
      return;
    }
    if (bucket.count >= maxPerMinute) {
      res.status(429).json({ error: "Too many requests" });
      return;
    }
    bucket.count += 1;
    next();
  };
};
