import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/status_pill.dart';

class RoomLobbyScreen extends StatelessWidget {
  const RoomLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                const Expanded(
                  child: Text(
                    'FOCUS12',
                    style: TextStyle(fontSize: 20, letterSpacing: 2),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.copy)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Participants', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const ListTile(
              leading: CircleAvatar(child: Text('A')),
              title: Text('Alex (host)'),
              trailing: StatusPill(label: 'Ready', color: Colors.green),
            ),
            const ListTile(
              leading: CircleAvatar(child: Text('B')),
              title: Text('Bora'),
              trailing: StatusPill(label: 'Not ready', color: Colors.grey),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => context.go('/running'),
              child: const Text('Start sprint'),
            ),
          ],
        ),
      ),
    );
  }
}
