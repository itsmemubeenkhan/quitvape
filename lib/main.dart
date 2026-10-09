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
          seedColor: const Color(0xFF6C3CE0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F7FF),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C3CE0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F0D1A),
      ),
      themeMode: ThemeMode.system,
      home: QuitService.hasStarted() ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}

// App-wide sexy styling helpers
class AppStyle {
  static const primary = Color(0xFF6C3CE0);
  static const primaryLight = Color(0xFF9D7BEA);
  static const accent = Color(0xFF00E5A0);
  static const accentDark = Color(0xFF00B87D);
  static const warning = Color(0xFFFF6B6B);
  static const gold = Color(0xFFFFD93D);

  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFF6C3CE0), Color(0xFF9D4EDD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSuccess = LinearGradient(
    colors: [Color(0xFF00E5A0), Color(0xFF00B87D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientDark = LinearGradient(
    colors: [Color(0xFF1A1533), Color(0xFF2D1B69)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientFire = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientGold = LinearGradient(
    colors: [Color(0xFFFFD93D), Color(0xFFFF9F1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E1A33) : Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: primary.withOpacity(isDark ? 0.15 : 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static TextStyle headline(BuildContext context) {
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: Theme.of(context).colorScheme.onSurface,
      letterSpacing: -0.5,
    );
  }
}
