import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/status_pill.dart';

class RunningRoomScreen extends ConsumerStatefulWidget {
  const RunningRoomScreen({super.key});

  @override
  ConsumerState<RunningRoomScreen> createState() => _RunningRoomScreenState();
}

class _RunningRoomScreenState extends ConsumerState<RunningRoomScreen> with WidgetsBindingObserver {
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      ref.read(roomProvider.notifier).sendHeartbeat();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(roomProvider.notifier).sendSlip('background');
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remaining';
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(roomProvider);
    final room = roomState.value;
    return Scaffold(
      appBar: AppBar(title: const Text('Sprint running')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _formatTime(room?.remainingSec ?? 0),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text('Statuses'),
            const SizedBox(height: 8),
            if (room != null)
              ...room.presence.map(
                (participant) => ListTile(
                  leading: CircleAvatar(child: Text(participant.userId.substring(0, 1).toUpperCase())),
                  title: Text(participant.userId),
                  trailing: StatusPill(
                    label: participant.status,
                    color: participant.status == 'SLIP'
                        ? Colors.red
                        : participant.status == 'AFK'
                            ? Colors.grey
                            : Colors.green,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            const Text('Recent events'),
            const SizedBox(height: 8),
            const Text('Live events will appear here.'),
            const Spacer(),
            FilledButton.tonal(
              onPressed: () => ref.read(roomProvider.notifier).sendBack(),
              child: const Text("I'm back"),
            ),
          ],
        ),
      ),
    );
  }
}
