import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Strictness', style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(value: 2, min: 1, max: 3, divisions: 2, onChanged: (_) {}),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Focus checks'),
          ),
          SwitchListTile(
            value: false,
            onChanged: (_) {},
            title: const Text('Friend slipped notifications'),
          ),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Privacy mode (hide history outside rooms)'),
          ),
        ],
      ),
    );
  }
}
