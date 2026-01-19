import cors from "cors";
import express from "express";
import http from "http";
import { Server } from "socket.io";
import { config } from "./config.js";
import { authRouter } from "./routes/auth.js";
import { roomsRouter } from "./routes/rooms.js";
import { meRouter } from "./routes/me.js";
import { notificationsRouter } from "./routes/notifications.js";
import { setupRealtime } from "./realtime/index.js";
import { errorHandler } from "./middleware/error.js";
import { rateLimit } from "./middleware/rate_limit.js";
import { logInfo } from "./logger.js";

const app = express();
app.use(
  cors({
    origin: config.allowedOrigins.length ? config.allowedOrigins : true,
  })
);
app.use(express.json());
app.use(rateLimit("http", 120));
app.use((req, _res, next) => {
  logInfo("http_request", { method: req.method, path: req.path });
  next();
});

app.get("/health", (_req, res) => {
  res.json({ ok: true });
});

app.use("/auth", authRouter);
app.use("/rooms", roomsRouter);
app.use("/me", meRouter);
app.use("/notifications", notificationsRouter);
app.use(errorHandler);

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: config.allowedOrigins.length ? config.allowedOrigins : true,
  },
});

setupRealtime(io);

server.listen(config.port, () => {
  logInfo("server_listening", { port: config.port });
});

const shutdown = async () => {
  logInfo("server_shutdown");
  await io.close();
  await new Promise((resolve) => server.close(resolve));
  process.exit(0);
};

process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);
