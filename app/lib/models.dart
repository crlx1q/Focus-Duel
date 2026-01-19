class AuthSession {
  AuthSession({required this.userId, required this.token});
  final String userId;
  final String token;
}

class RoomParticipant {
  RoomParticipant({required this.userId, required this.role});
  final String userId;
  final String role;
}

class RoomSummary {
  RoomSummary({
    required this.id,
    required this.code,
    required this.durationSec,
    required this.status,
    required this.participants,
  });

  final String id;
  final String code;
  final int durationSec;
  final String status;
  final List<RoomParticipant> participants;
}

class RoomPresence {
  RoomPresence({required this.userId, required this.status, required this.slips});
  final String userId;
  final String status;
  final int slips;
}

class RoomState {
  RoomState({
    required this.room,
    required this.presence,
    required this.remainingSec,
  });

  final RoomSummary room;
  final List<RoomPresence> presence;
  final int remainingSec;
}
