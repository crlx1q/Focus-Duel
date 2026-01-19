# Focus Duel

Focus Duel is a Pomodoro-style duel/coworking app focused on honest, low-friction accountability. The stack is:

- **Flutter + Riverpod** for Android/iOS.
- **Node.js (TypeScript) + Express + Socket.IO** for realtime.
- **Postgres (Prisma)** for persistence, **Redis** for timers/presence (optional, in-memory fallback included).

## Repository layout

```
/app      Flutter client
/server   Node.js API + Socket.IO server
```

## Local setup

### 1) Start Postgres + Redis

```bash
docker-compose up -d
```

### 2) Server

```bash
cd server
cp .env.example .env
npm install
npm run prisma:generate
npm run prisma:migrate
npm run dev
```

### 3) Flutter

```bash
cd app
flutter pub get
flutter run
```

## Environment variables

See `.env.example` for all variables and descriptions.

## Realtime Socket.IO protocol

Namespace: `/realtime`

### Client → Server
- `auth { token? , guestId? }`
- `room:join { code }`
- `room:leave {}`
- `room:ready { ready: true|false }`
- `room:start {}` (host only)
- `hb { roomId, tClient }`
- `slip { roomId, reason }`
- `focus_check:reply { roomId, ok: true|false }`

### Server → Client
- `room:state { room, participants, timer, statuses, tServer }`
- `room:event { type, userId, reason, tServer, payload }`
- `room:timer { remainingSec, tServer }`
- `room:finish { results, timeline, tServer }`

## Screens & navigation (Flutter)

- **Onboarding/Sign in** → guest login or email (stub).
- **Home** → quick start buttons + recent rooms.
- **Create Room** → mode, duration, strictness, focus check, forbidden apps (Android only).
- **Room Lobby** → participants, ready status, invite link, host start.
- **Running Room** → big timer, statuses, slips, mini timeline, “I’m back”.
- **Results** → stats table + timeline + rematch.
- **Profile/Stats** → streaks, achievements, weekly minutes.
- **Settings** → strictness, focus checks, notifications, privacy.

## Roadmap

### MVP
- Rooms (duel/coworking), ready/start flow, server timer.
- Heartbeats and AFK detection.
- Slip detection (background + focus check).
- Results with slips and focus time.

### v1
- Push notifications, link invites, improved achievements.
- Basic leaderboard (weekly).
- Android forbidden apps detection.

### v2
- Matchmaking and public rooms.
- Advanced privacy modes and subscriptions.

## Platform limitations

- **Forbidden apps detection (Level 2)** is only available on Android. iOS is restricted to Level 1 (lifecycle) and optional focus checks.

