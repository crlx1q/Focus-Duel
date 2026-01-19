import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/create_room_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/results_screen.dart';
import 'screens/room_lobby_screen.dart';
import 'screens/running_room_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const ProviderScope(child: FocusDuelApp()));
}

class FocusDuelApp extends StatelessWidget {
  const FocusDuelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/create', builder: (_, __) => const CreateRoomScreen()),
        GoRoute(path: '/lobby', builder: (_, __) => const RoomLobbyScreen()),
        GoRoute(path: '/running', builder: (_, __) => const RunningRoomScreen()),
        GoRoute(path: '/results', builder: (_, __) => const ResultsScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      ],
    );

    return MaterialApp.router(
      title: 'Focus Duel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF14B86A)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
