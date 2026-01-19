import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      if (next.value != null) {
        context.go('/home');
      }
    });
    final authState = ref.watch(authProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'Focus Duel',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Duel or cowork in timed sprints. Only status shows: Focus, Slip, or AFK.',
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: authState.isLoading
                    ? null
                    : () => ref.read(authProvider.notifier).signInGuest(),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue as guest'),
              ),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Sign in with email (soon)'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
