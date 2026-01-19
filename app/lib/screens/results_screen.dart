import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/status_pill.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Sprint summary', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const ListTile(
              leading: CircleAvatar(child: Text('A')),
              title: Text('Alex'),
              subtitle: Text('Focus 23m · Slips 0 · Trust 98'),
              trailing: StatusPill(label: 'WIN', color: Colors.green),
            ),
            const ListTile(
              leading: CircleAvatar(child: Text('B')),
              title: Text('Bora'),
              subtitle: Text('Focus 21m · Slips 2 · Trust 86'),
              trailing: StatusPill(label: 'OK', color: Colors.orange),
            ),
            const SizedBox(height: 16),
            const Text('Timeline'),
            const SizedBox(height: 8),
            const ListTile(
              leading: Icon(Icons.flag),
              title: Text('Sprint started'),
              subtitle: Text('00:00'),
            ),
            const ListTile(
              leading: Icon(Icons.bolt, color: Colors.red),
              title: Text('Bora slipped'),
              subtitle: Text('12:03'),
            ),
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
