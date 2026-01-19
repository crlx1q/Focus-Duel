import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & stats')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const CircleAvatar(child: Text('A')),
            title: Text(authState.value?.userId ?? 'Guest'),
            subtitle: const Text('Guest'),
          ),
          Divider(),
          const ListTile(
            title: Text('Current streak'),
            trailing: Text('4 sprints'),
          ),
          const ListTile(
            title: Text('Weekly focus'),
            trailing: Text('312 min'),
          ),
          const ListTile(
            title: Text('Achievements'),
            subtitle: Text('First duel · 3 slips-free sprints'),
          ),
        ],
      ),
    );
  }
}
