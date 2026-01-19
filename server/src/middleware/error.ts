import { NextFunction, Request, Response } from "express";

export const errorHandler = (error: Error, _req: Request, res: Response, _next: NextFunction) => {
  console.error("[error]", error.message);
  res.status(500).json({ error: "Internal server error" });
};
