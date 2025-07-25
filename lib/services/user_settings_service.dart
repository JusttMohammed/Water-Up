import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class UserSettingsService {
  static const String _dailyGoalKey = 'daily_goal_ml';
  static const String _themeModeKey = 'theme_mode';
  static const String _remindersEnabledKey = 'reminders_enabled';

  // Default values
  static const int defaultDailyGoal = 2500; // ml
  static const ThemeMode defaultThemeMode = ThemeMode.system;
  static const bool defaultRemindersEnabled = false;

  // Get daily goal
  Future<int> getDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailyGoalKey) ?? defaultDailyGoal;
  }

  // Set daily goal
  Future<void> setDailyGoal(int goalMl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyGoalKey, goalMl);
  }

  // Get theme mode
  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_themeModeKey);
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return defaultThemeMode;
    }
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String value = 'system';
    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';
    await prefs.setString(_themeModeKey, value);
  }

  // Get reminders enabled
  Future<bool> getRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_remindersEnabledKey) ?? defaultRemindersEnabled;
  }

  // Set reminders enabled
  Future<void> setRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_remindersEnabledKey, enabled);
  }
} 