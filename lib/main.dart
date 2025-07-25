import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:watter_project/theme/app_theme.dart';
import 'package:watter_project/screens/welcome_screen.dart';
import 'package:watter_project/screens/dashboard_screen.dart';
import 'package:watter_project/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('water_entries');
  runApp(const WatterApp());
}

class WatterApp extends StatelessWidget {
  const WatterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Watter',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
