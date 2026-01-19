import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models.dart';
import '../services/api_client.dart';
import '../services/socket_service.dart';
import '../services/secure_storage.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: 'http://localhost:4000');
});

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService(baseUrl: 'http://localhost:4000');
  ref.onDispose(service.dispose);
  return service;
});

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

class AuthController extends StateNotifier<AsyncValue<AuthSession?>> {
  AuthController(this._apiClient, this._storage) : super(const AsyncValue.data(null)) {
    _hydrate();
  }

  final ApiClient _apiClient;
  final SecureStorage _storage;

  Future<void> _hydrate() async {
    final session = await _storage.readSession();
    if (session == null) return;
    state = AsyncValue.data(AuthSession(userId: session['userId']!, token: session['token']!));
  }

  Future<void> signInGuest() async {
    state = const AsyncValue.loading();
    try {
      final session = await _apiClient.createGuest();
      await _storage.saveSession(token: session.token, userId: session.userId);
      state = AsyncValue.data(session);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

final authProvider = StateNotifierProvider<AuthController, AsyncValue<AuthSession?>>((ref) {
  return AuthController(ref.watch(apiClientProvider), ref.watch(secureStorageProvider));
});

class RoomController extends StateNotifier<AsyncValue<RoomState?>> {
  RoomController(this._apiClient, this._socketService, this._ref)
      : super(const AsyncValue.data(null));

  final ApiClient _apiClient;
  final SocketService _socketService;
  final Ref _ref;
  StreamSubscription<RoomState>? _roomSub;
  StreamSubscription<Map<String, dynamic>>? _eventSub;

  Future<void> createRoom({
    required String mode,
    required int durationSec,
    required int strictnessLevel,
    required bool focusCheckEnabled,
    required bool isPrivate,
  }) async {
    final session = _ref.read(authProvider).value;
    if (session == null) return;
    state = const AsyncValue.loading();
    try {
      final room = await _apiClient.createRoom(
        token: session.token,
        mode: mode,
        durationSec: durationSec,
        strictnessLevel: strictnessLevel,
        focusCheckEnabled: focusCheckEnabled,
        isPrivate: isPrivate,
      );
      _socketService.connect(token: session.token);
      _socketService.joinRoom(room.code);
      _roomSub?.cancel();
      _roomSub = _socketService.stateStream.listen((value) {
        state = AsyncValue.data(value);
      });
      _eventSub?.cancel();
      _eventSub = _socketService.eventStream.listen((event) {
        final current = state.value;
        if (current == null) return;
        if (event['remainingSec'] != null) {
          state = AsyncValue.data(RoomState(
            room: current.room,
            presence: current.presence,
            remainingSec: event['remainingSec'] as int,
          ));
        }
      });
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  void startRoom() {
    _socketService.startRoom();
  }

  void sendHeartbeat() {
    final current = state.value;
    if (current == null) return;
    _socketService.sendHeartbeat(current.room.id);
  }

  void sendSlip(String reason) {
    final current = state.value;
    if (current == null) return;
    _socketService.sendSlip(current.room.id, reason);
  }

  void sendBack() {
    final current = state.value;
    if (current == null) return;
    _socketService.sendBack(current.room.id);
  }

  @override
  void dispose() {
    _roomSub?.cancel();
    _eventSub?.cancel();
    super.dispose();
  }
}

final roomProvider = StateNotifierProvider<RoomController, AsyncValue<RoomState?>>((ref) {
  return RoomController(ref.watch(apiClientProvider), ref.watch(socketServiceProvider), ref);
});

class SettingsState {
  SettingsState({
    required this.strictness,
    required this.focusChecks,
    required this.notifications,
    required this.privacy,
  });

  final double strictness;
  final bool focusChecks;
  final bool notifications;
  final bool privacy;

  SettingsState copyWith({
    double? strictness,
    bool? focusChecks,
    bool? notifications,
    bool? privacy,
  }) {
    return SettingsState(
      strictness: strictness ?? this.strictness,
      focusChecks: focusChecks ?? this.focusChecks,
      notifications: notifications ?? this.notifications,
      privacy: privacy ?? this.privacy,
    );
  }
}

final settingsProvider = StateProvider<SettingsState>((ref) {
  return SettingsState(strictness: 2, focusChecks: true, notifications: false, privacy: true);
});
