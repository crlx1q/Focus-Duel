import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models.dart';

class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;

  Future<AuthSession> createGuest() async {
    final response = await http.post(Uri.parse('$baseUrl/auth/guest'));
    if (response.statusCode != 200) {
      throw Exception('Failed to create guest');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthSession(userId: data['userId'] as String, token: data['token'] as String);
  }

  Future<RoomSummary> createRoom({
    required String token,
    required String mode,
    required int durationSec,
    required int strictnessLevel,
    required bool focusCheckEnabled,
    required bool isPrivate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rooms'),
      headers: _headers(token),
      body: jsonEncode({
        'mode': mode,
        'durationSec': durationSec,
        'strictnessLevel': strictnessLevel,
        'focusCheckEnabled': focusCheckEnabled,
        'isPrivate': isPrivate,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to create room');
    }
    return _roomFromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<RoomSummary> joinRoom({required String token, required String code}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rooms/join'),
      headers: _headers(token),
      body: jsonEncode({'code': code}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to join room');
    }
    return _roomFromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  RoomSummary _roomFromJson(Map<String, dynamic> json) {
    final participants = (json['participants'] as List<dynamic>? ?? [])
        .map((item) => RoomParticipant(
              userId: item['userId'] as String,
              role: item['role'] as String,
            ))
        .toList();
    return RoomSummary(
      id: json['id'] as String,
      code: json['code'] as String,
      durationSec: json['durationSec'] as int,
      status: json['status'] as String,
      participants: participants,
    );
  }
}
