import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Strictness', style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: settings.strictness,
            min: 1,
            max: 3,
            divisions: 2,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).state = settings.copyWith(strictness: value),
          ),
          SwitchListTile(
            value: settings.focusChecks,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).state = settings.copyWith(focusChecks: value),
            title: const Text('Focus checks'),
          ),
          SwitchListTile(
            value: settings.notifications,
            onChanged: (value) => ref
                .read(settingsProvider.notifier)
                .state = settings.copyWith(notifications: value),
            title: const Text('Friend slipped notifications'),
          ),
          SwitchListTile(
            value: settings.privacy,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).state = settings.copyWith(privacy: value),
            title: const Text('Privacy mode (hide history outside rooms)'),
          ),
        ],
      ),
    );
  }
}
