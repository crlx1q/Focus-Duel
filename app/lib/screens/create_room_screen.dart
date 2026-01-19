import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateRoomScreen extends StatelessWidget {
  const CreateRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create room')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Mode', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Duel 1v1')),
              ButtonSegment(value: 1, label: Text('Coworking')),
            ],
            selected: const {0},
            onSelectionChanged: (_) {},
          ),
          const SizedBox(height: 16),
          const Text('Duration', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: const [
              ChoiceChip(label: Text('25 min'), selected: true),
              ChoiceChip(label: Text('50 min'), selected: false),
              ChoiceChip(label: Text('Custom'), selected: false),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Strictness', style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(value: 1, min: 1, max: 3, divisions: 2, onChanged: (_) {}),
          const Text('Level 1 (cross-platform): background + heartbeat'),
          const SizedBox(height: 12),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Focus check (Level 3 prototype)'),
            subtitle: const Text('Shows a 10s check around minute 8-12'),
          ),
          SwitchListTile(
            value: false,
            onChanged: (_) {},
            title: const Text('Forbidden apps detection (Android only)'),
            subtitle: const Text('Not available on iOS'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go('/lobby'),
            child: const Text('Create room'),
          ),
        ],
      ),
    );
  }
}
