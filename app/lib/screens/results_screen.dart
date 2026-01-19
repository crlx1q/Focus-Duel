import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../widgets/status_pill.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final room = ref.watch(roomProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Sprint summary', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (room == null)
              const Text('No results yet.')
            else
              ...room.presence.map(
                (participant) => ListTile(
                  leading: CircleAvatar(child: Text(participant.userId.substring(0, 1).toUpperCase())),
                  title: Text(participant.userId),
                  subtitle: Text('Slips ${participant.slips}'),
                  trailing: StatusPill(
                    label: participant.status,
                    color: participant.status == 'SLIP'
                        ? Colors.red
                        : participant.status == 'AFK'
                            ? Colors.grey
                            : Colors.green,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Text('Timeline'),
            const SizedBox(height: 8),
            const Text('Timeline events will appear here.'),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.go('/create'),
                    child: const Text('Rematch'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => context.go('/home'),
                    child: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
