import { NextFunction, Request, Response } from "express";
import { logError } from "../logger.js";

export const errorHandler = (error: Error, _req: Request, res: Response, _next: NextFunction) => {
  logError("http_error", { message: error.message });
  res.status(500).json({ error: "Internal server error" });
};
