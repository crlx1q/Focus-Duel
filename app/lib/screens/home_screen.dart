import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Duel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              authState.value != null ? 'Guest: ${authState.value!.userId}' : 'Not signed in',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Text(
              'Quick start',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.go('/create'),
                    child: const Text('Duel 25'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => context.go('/create'),
                    child: const Text('Room 50'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.go('/create'),
              icon: const Icon(Icons.add),
              label: const Text('Create sprint'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.meeting_room_outlined),
              label: const Text('Join by code'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent rooms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.timer),
                    title: Text('Duel 25 · WIN'),
                    subtitle: Text('2 slips · 23 min focus'),
                  ),
                  ListTile(
                    leading: Icon(Icons.timer_outlined),
                    title: Text('Cowork 50 · DONE'),
                    subtitle: Text('0 slips · 48 min focus'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
