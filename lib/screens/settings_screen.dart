import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/user_settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = UserSettingsService();
  final _goalController = TextEditingController();
  int _dailyGoal = UserSettingsService.defaultDailyGoal;
  ThemeMode _themeMode = UserSettingsService.defaultThemeMode;
  bool _remindersEnabled = UserSettingsService.defaultRemindersEnabled;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final goal = await _settings.getDailyGoal();
    final theme = await _settings.getThemeMode();
    final reminders = await _settings.getRemindersEnabled();
    setState(() {
      _dailyGoal = goal;
      _goalController.text = goal.toString();
      _themeMode = theme;
      _remindersEnabled = reminders;
      _loading = false;
    });
  }

  Future<void> _saveDailyGoal() async {
    final value = int.tryParse(_goalController.text);
    if (value != null && value > 0) {
      await _settings.setDailyGoal(value);
      setState(() => _dailyGoal = value);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Daily goal updated!')));
    }
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    await _settings.setThemeMode(mode);
    setState(() => _themeMode = mode);
  }

  Future<void> _saveReminders(bool enabled) async {
    await _settings.setRemindersEnabled(enabled);
    setState(() => _remindersEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text('Daily Water Goal', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _goalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter daily goal (ml)',
                          filled: true,
                          fillColor: AppTheme.lightBlue.withAlpha(30),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saveDailyGoal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Theme', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('System')),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                  ],
                  selected: {_themeMode},
                  onSelectionChanged: (modes) {
                    if (modes.isNotEmpty) _saveThemeMode(modes.first);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(AppTheme.lightBlue.withAlpha(30)),
                    foregroundColor: MaterialStateProperty.all(AppTheme.primaryBlue),
                  ),
                ),
                const SizedBox(height: 32),
                Text('Reminders', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _remindersEnabled,
                  onChanged: _saveReminders,
                  title: const Text('Enable daily reminders'),
                  activeColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: AppTheme.lightBlue.withAlpha(30),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ],
            ),
    );
  }
} 