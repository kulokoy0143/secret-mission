import 'package:flutter/material.dart';
import '../features/welcome/welcome_screen.dart';
import 'app_theme.dart';

class SecretMissionApp extends StatelessWidget {
  const SecretMissionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secret Mission',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const WelcomeScreen(),
    );
  }
}