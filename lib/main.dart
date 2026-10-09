import 'package:flutter/material.dart';
import 'package:quitvape/screens/onboarding_screen.dart';
import 'package:quitvape/screens/home_screen.dart';
import 'package:quitvape/services/quit_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await QuitService.init();
  runApp(const QuitVapeApp());
}

class QuitVapeApp extends StatelessWidget {
  const QuitVapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuitVape',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: QuitService.hasStarted() ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
