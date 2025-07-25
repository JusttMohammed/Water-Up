import 'package:flutter/material.dart';
import '../widgets/app_components.dart';
import 'data_collection_screen.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Tutorial', style: Theme.of(context).textTheme.titleLarge),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '• Track your daily water intake easily.\n\n• Get personalized hydration goals.\n\n• Stay healthy with reminders and insights.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppButton(
                  text: 'Skip Tutorial',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DataCollectionScreen()),
                    );
                  },
                ),
                AppButton(
                  text: 'Next',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DataCollectionScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 