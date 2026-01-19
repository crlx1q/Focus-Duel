import { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";
import { config } from "../config.js";

export type AuthPayload = {
  userId: string;
};

export const signToken = (payload: AuthPayload) => {
  return jwt.sign(payload, config.jwtSecret, { expiresIn: "30d" });
};

export const requireAuth = (req: Request, res: Response, next: NextFunction) => {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) {
    res.status(401).json({ error: "Missing token" });
    return;
  }
  const token = header.replace("Bearer ", "");
  try {
    const decoded = jwt.verify(token, config.jwtSecret) as AuthPayload;
    res.locals.userId = decoded.userId;
    next();
  } catch (error) {
    res.status(401).json({ error: "Invalid token" });
  }
};
