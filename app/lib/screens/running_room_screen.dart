import 'package:flutter/material.dart';
import '../widgets/status_pill.dart';

class RunningRoomScreen extends StatelessWidget {
  const RunningRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sprint running')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '24:32',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text('Statuses'),
            const SizedBox(height: 8),
            const ListTile(
              leading: CircleAvatar(child: Text('A')),
              title: Text('Alex'),
              trailing: StatusPill(label: 'FOCUS', color: Colors.green),
            ),
            const ListTile(
              leading: CircleAvatar(child: Text('B')),
              title: Text('Bora'),
              trailing: StatusPill(label: 'SLIP', color: Colors.red),
            ),
            const SizedBox(height: 8),
            const Text('Recent events'),
            const SizedBox(height: 8),
            const ListTile(
              leading: Icon(Icons.bolt, color: Colors.red),
              title: Text('Bora slipped (background)'),
              subtitle: Text('0:32 ago'),
            ),
            const Spacer(),
            FilledButton.tonal(
              onPressed: () {},
              child: const Text("I'm back"),
            ),
          ],
        ),
      ),
    );
  }
}
