import 'package:flutter/material.dart';
import '../widgets/app_components.dart';
import 'goal_preview_screen.dart';

class DataCollectionScreen extends StatefulWidget {
  const DataCollectionScreen({super.key});

  @override
  State<DataCollectionScreen> createState() => _DataCollectionScreenState();
}

class _DataCollectionScreenState extends State<DataCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _weightUnit = 'kg';
  String _heightUnit = 'cm';
  String _activityLevel = 'Sedentary';
  String _climate = 'Temperate';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tell us about yourself', style: Theme.of(context).textTheme.titleLarge)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Age (years)', labelStyle: Theme.of(context).textTheme.bodyMedium),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your age';
                  final n = int.tryParse(value);
                  if (n == null || n <= 0) return 'Enter a valid age';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Weight ($_weightUnit)', labelStyle: Theme.of(context).textTheme.bodyMedium),
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your weight';
                        final n = double.tryParse(value);
                        if (n == null || n <= 0) return 'Enter a valid weight';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ToggleButtons(
                    isSelected: [_weightUnit == 'kg', _weightUnit == 'lbs'],
                    onPressed: (index) {
                      setState(() {
                        _weightUnit = index == 0 ? 'kg' : 'lbs';
                      });
                    },
                    children: [Text('kg', style: Theme.of(context).textTheme.bodyMedium), Text('lbs', style: Theme.of(context).textTheme.bodyMedium)],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Height ($_heightUnit)', labelStyle: Theme.of(context).textTheme.bodyMedium),
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your height';
                        final n = double.tryParse(value);
                        if (n == null || n <= 0) return 'Enter a valid height';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ToggleButtons(
                    isSelected: [_heightUnit == 'cm', _heightUnit == 'in'],
                    onPressed: (index) {
                      setState(() {
                        _heightUnit = index == 0 ? 'cm' : 'in';
                      });
                    },
                    children: [Text('cm', style: Theme.of(context).textTheme.bodyMedium), Text('in', style: Theme.of(context).textTheme.bodyMedium)],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _activityLevel,
                decoration: InputDecoration(labelText: 'Activity Level', labelStyle: Theme.of(context).textTheme.bodyMedium),
                items: [
                  DropdownMenuItem(value: 'Sedentary', child: Text('Sedentary', style: Theme.of(context).textTheme.bodyMedium)),
                  DropdownMenuItem(value: 'Light', child: Text('Light', style: Theme.of(context).textTheme.bodyMedium)),
                  DropdownMenuItem(value: 'Moderate', child: Text('Moderate', style: Theme.of(context).textTheme.bodyMedium)),
                  DropdownMenuItem(value: 'Active', child: Text('Active', style: Theme.of(context).textTheme.bodyMedium)),
                ],
                onChanged: (value) {
                  setState(() {
                    _activityLevel = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _climate,
                decoration: InputDecoration(labelText: 'Climate', labelStyle: Theme.of(context).textTheme.bodyMedium),
                items: [
                  DropdownMenuItem(value: 'Cold', child: Text('Cold', style: Theme.of(context).textTheme.bodyMedium)),
                  DropdownMenuItem(value: 'Temperate', child: Text('Temperate', style: Theme.of(context).textTheme.bodyMedium)),
                  DropdownMenuItem(value: 'Hot', child: Text('Hot', style: Theme.of(context).textTheme.bodyMedium)),
                ],
                onChanged: (value) {
                  setState(() {
                    _climate = value!;
                  });
                },
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Next',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final int age = int.parse(_ageController.text);
                    final double weight = double.parse(_weightController.text);
                    final double height = double.parse(_heightController.text);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GoalPreviewScreen(
                          age: age,
                          weight: weight,
                          weightUnit: _weightUnit,
                          height: height,
                          heightUnit: _heightUnit,
                          activityLevel: _activityLevel,
                          climate: _climate,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 