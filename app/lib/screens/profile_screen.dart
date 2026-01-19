import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & stats')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: CircleAvatar(child: Text('A')),
            title: Text('Alex'),
            subtitle: Text('Guest'),
          ),
          Divider(),
          ListTile(
            title: Text('Current streak'),
            trailing: Text('4 sprints'),
          ),
          ListTile(
            title: Text('Weekly focus'),
            trailing: Text('312 min'),
          ),
          ListTile(
            title: Text('Achievements'),
            subtitle: Text('First duel · 3 slips-free sprints'),
          ),
        ],
      ),
    );
  }
}
