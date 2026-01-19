import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                onPressed: () => context.go('/home'),
                child: const Text('Continue as guest'),
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
