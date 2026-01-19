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

const app = express();
app.use(cors());
app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({ ok: true });
});

app.use("/auth", authRouter);
app.use("/rooms", roomsRouter);
app.use("/me", meRouter);
app.use("/notifications", notificationsRouter);

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
  },
});

setupRealtime(io);

server.listen(config.port, () => {
  console.log(`Focus Duel server listening on :${config.port}`);
});
