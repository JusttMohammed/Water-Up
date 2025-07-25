import 'package:flutter/material.dart';

class CustomizeGoalScreen extends StatelessWidget {
  const CustomizeGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customize Your Goal', style: Theme.of(context).textTheme.titleLarge)),
      body: Center(
        child: Text('Goal customization coming soon!', style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
} 