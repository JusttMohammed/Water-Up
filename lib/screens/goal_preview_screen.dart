import 'package:flutter/material.dart';
import '../widgets/app_components.dart';
import 'dashboard_screen.dart';
import 'customize_goal_screen.dart';

class GoalPreviewScreen extends StatelessWidget {
  final int age;
  final double weight;
  final String weightUnit;
  final double height;
  final String heightUnit;
  final String activityLevel;
  final String climate;

  const GoalPreviewScreen({
    super.key,
    required this.age,
    required this.weight,
    required this.weightUnit,
    required this.height,
    required this.heightUnit,
    required this.activityLevel,
    required this.climate,
  });

  double calculateGoalLiters() {
    double weightKg = weightUnit == 'kg' ? weight : weight * 0.453592;
    double base = weightKg * 0.035; // 35ml per kg
    // Adjust for activity
    double activityAdj = 0.0;
    switch (activityLevel) {
      case 'Light':
        activityAdj = 0.2;
        break;
      case 'Moderate':
        activityAdj = 0.4;
        break;
      case 'Active':
        activityAdj = 0.6;
        break;
      default:
        activityAdj = 0.0;
    }
    // Adjust for climate
    double climateAdj = 0.0;
    switch (climate) {
      case 'Hot':
        climateAdj = 0.5;
        break;
      case 'Cold':
        climateAdj = -0.2;
        break;
      default:
        climateAdj = 0.0;
    }
    double total = base + activityAdj + climateAdj;
    // Clamp between 1.5L and 4L
    if (total < 1.5) total = 1.5;
    if (total > 4.0) total = 4.0;
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final double goalLiters = calculateGoalLiters();
    return Scaffold(
      appBar: AppBar(title: Text('Your Daily Water Goal', style: Theme.of(context).textTheme.titleLarge)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Based on your info, we recommend:',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              '${goalLiters.toStringAsFixed(1)} liters per day',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You can adjust this goal if you like.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Looks Good',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                );
              },
            ),
            AppButton(
              text: 'Customize Goal',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomizeGoalScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 