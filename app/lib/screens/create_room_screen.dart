import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  int mode = 0;
  int duration = 25;
  double strictness = 1;
  bool focusCheck = true;
  bool isPrivate = true;
  bool forbiddenApps = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(roomProvider, (previous, next) {
      if (next.value != null) {
        context.go('/lobby');
      }
    });
    final roomState = ref.watch(roomProvider);
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
            selected: {mode},
            onSelectionChanged: (value) => setState(() => mode = value.first),
          ),
          const SizedBox(height: 16),
          const Text('Duration', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              ChoiceChip(
                label: const Text('25 min'),
                selected: duration == 25,
                onSelected: (_) => setState(() => duration = 25),
              ),
              ChoiceChip(
                label: const Text('50 min'),
                selected: duration == 50,
                onSelected: (_) => setState(() => duration = 50),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Strictness', style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: strictness,
            min: 1,
            max: 3,
            divisions: 2,
            label: strictness.toInt().toString(),
            onChanged: (value) => setState(() => strictness = value),
          ),
          const Text('Level 1 (cross-platform): background + heartbeat'),
          const SizedBox(height: 12),
          SwitchListTile(
            value: focusCheck,
            onChanged: (value) => setState(() => focusCheck = value),
            title: const Text('Focus check (Level 3 prototype)'),
            subtitle: const Text('Shows a 10s check around minute 8-12'),
          ),
          SwitchListTile(
            value: forbiddenApps,
            onChanged: (value) => setState(() => forbiddenApps = value),
            title: const Text('Forbidden apps detection (Android only)'),
            subtitle: const Text('iOS uses Level 1 + focus checks'),
          ),
          SwitchListTile(
            value: isPrivate,
            onChanged: (value) => setState(() => isPrivate = value),
            title: const Text('Private room'),
            subtitle: const Text('Invite-only via code/link'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: roomState.isLoading
                ? null
                : () async {
                    await ref.read(roomProvider.notifier).createRoom(
                          mode: mode == 0 ? 'DUEL' : 'COWORK',
                          durationSec: duration * 60,
                          strictnessLevel: strictness.toInt(),
                          focusCheckEnabled: focusCheck,
                          isPrivate: isPrivate,
                        );
                  },
            child: roomState.isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create room'),
          ),
        ],
      ),
    );
  }
}
