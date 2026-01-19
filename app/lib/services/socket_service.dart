import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../models.dart';

class SocketService {
  SocketService({required this.baseUrl});

  final String baseUrl;
  io.Socket? _socket;
  final _stateController = StreamController<RoomState>.broadcast();
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<RoomState> get stateStream => _stateController.stream;
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  void connect({required String token}) {
    _socket = io.io(
      '$baseUrl/realtime',
      io.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    );
    _socket?.connect();
    _socket?.onConnect((_) {
      _socket?.emit('auth', {'token': token});
    });
    _socket?.on('room:state', _handleRoomState);
    _socket?.on('room:timer', (data) {
      _eventController.add(Map<String, dynamic>.from(data as Map));
    });
    _socket?.on('room:event', (data) {
      _eventController.add(Map<String, dynamic>.from(data as Map));
    });
    _socket?.on('room:finish', (data) {
      _eventController.add(Map<String, dynamic>.from(data as Map));
    });
  }

  void joinRoom(String code) {
    _socket?.emit('room:join', {'code': code});
  }

  void startRoom() {
    _socket?.emit('room:start');
  }

  void sendHeartbeat(String roomId) {
    _socket?.emit('hb', {'roomId': roomId, 'tClient': DateTime.now().millisecondsSinceEpoch});
  }

  void sendSlip(String roomId, String reason) {
    _socket?.emit('slip', {'roomId': roomId, 'reason': reason});
  }

  void sendBack(String roomId) {
    _socket?.emit('focus_check:reply', {'roomId': roomId, 'ok': true});
  }

  void _handleRoomState(dynamic data) {
    if (data is! Map) return;
    final room = data['room'] as Map<String, dynamic>?;
    if (room == null) return;
    final participantsJson = room['participants'] as List<dynamic>? ?? [];
    final participants = participantsJson
        .map((item) => RoomParticipant(
              userId: item['userId'] as String,
              role: item['role'] as String,
            ))
        .toList();
    final presenceData = data['statuses'] as List<dynamic>? ?? [];
    final presence = presenceData.map((entry) {
      final list = entry as List<dynamic>;
      final userId = list[0] as String;
      final state = Map<String, dynamic>.from(list[1] as Map);
      return RoomPresence(
        userId: userId,
        status: state['status'] as String? ?? 'FOCUS',
        slips: state['slips'] as int? ?? 0,
      );
    }).toList();
    final remainingSec = (data['timer']?['durationSec'] as int?) ?? 0;
    _stateController.add(RoomState(
      room: RoomSummary(
        id: room['id'] as String,
        code: room['code'] as String,
        durationSec: room['durationSec'] as int,
        status: room['status'] as String,
        participants: participants,
      ),
      presence: presence,
      remainingSec: remainingSec,
    ));
  }

  void dispose() {
    _socket?.dispose();
    _stateController.close();
    _eventController.close();
  }
}
