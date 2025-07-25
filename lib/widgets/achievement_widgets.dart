import 'package:flutter/material.dart';

class Badge {
  final String name;
  final bool unlocked;
  final int progress;
  final int goal;
  Badge(this.name, this.unlocked, this.progress, this.goal);
}

class BadgeWidget extends StatelessWidget {
  final Badge badge;
  const BadgeWidget({required this.badge, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: badge.unlocked ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
          child: Icon(
            badge.unlocked ? Icons.emoji_events : Icons.lock,
            color: badge.unlocked ? Theme.of(context).colorScheme.onPrimary : Colors.grey,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          badge.name,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        if (!badge.unlocked)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '${badge.progress}/${badge.goal}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class VirtualPlantWidget extends StatelessWidget {
  final int level;
  final int streak;
  const VirtualPlantWidget({required this.level, required this.streak, super.key});
  
  @override
  Widget build(BuildContext context) {
    // Plant grows with level, smiles with streak
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.local_florist, size: 80, color: Theme.of(context).colorScheme.primary.withAlpha(102)),
            if (streak >= 7)
              Positioned(
                bottom: 0,
                child: Icon(Icons.emoji_emotions, color: Colors.orange, size: 32),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Your Plant', style: Theme.of(context).textTheme.bodyLarge),
        Text('Level $level', style: Theme.of(context).textTheme.bodyMedium),
        if (streak >= 7)
          Text('Happy! 7+ day streak!', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class WeeklyChallengeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mock challenge
    const bool completed = false;
    const int progress = 3;
    const int goal = 5;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.flag, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weekly Challenge', style: Theme.of(context).textTheme.labelLarge),
                  Text('Log your first drink before 8am for 5 days.', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress / goal,
                    backgroundColor: Colors.grey.shade200,
                    color: completed ? Colors.green : Theme.of(context).colorScheme.primary,
                    minHeight: 8,
                  ),
                  Text('$progress/$goal days', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            completed
                ? const Icon(Icons.check_circle, color: Colors.green)
                : Icon(Icons.hourglass_bottom, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
} 