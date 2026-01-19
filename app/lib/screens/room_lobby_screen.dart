import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../widgets/status_pill.dart';

class RoomLobbyScreen extends ConsumerWidget {
  const RoomLobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomState = ref.watch(roomProvider);
    final room = roomState.value?.room;
    return Scaffold(
      appBar: AppBar(title: const Text('Room lobby')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Invite code', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    room?.code ?? '—',
                    style: const TextStyle(fontSize: 20, letterSpacing: 2),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.copy)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Participants', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (room == null)
              const Text('No room loaded.'),
            if (room != null)
              ...room.participants.map(
                (participant) => ListTile(
                  leading: CircleAvatar(child: Text(participant.userId.substring(0, 1).toUpperCase())),
                  title: Text(participant.role == 'host'
                      ? '${participant.userId} (host)'
                      : participant.userId),
                  trailing: const StatusPill(label: 'Ready', color: Colors.green),
                ),
              ),
            const Spacer(),
            FilledButton(
              onPressed: room == null
                  ? null
                  : () {
                      ref.read(roomProvider.notifier).startRoom();
                      context.go('/running');
                    },
              child: const Text('Start sprint'),
            ),
          ],
        ),
      ),
    );
  }
}
