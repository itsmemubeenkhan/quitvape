import 'package:flutter/material.dart';
import 'package:quitvape/screens/onboarding_screen.dart';
import 'package:quitvape/screens/home_screen.dart';
import 'package:quitvape/services/quit_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await QuitService.init();
  await QuitService.grantTestCoinsIfNeeded(); // 5000 test coins
  runApp(const QuitVapeApp());
}

class QuitVapeApp extends StatelessWidget {
  const QuitVapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuitVape',
      debugShowCheckedModeBanner: false,
      theme: _buildDarkTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.dark, // Dark by default like the reference
      home: QuitService.hasStarted() ? const HomeScreen() : const OnboardingScreen(),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0F0D),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00E5A0),
        secondary: Color(0xFF00E5A0),
        surface: Color(0xFF131A17),
        background: Color(0xFF0A0F0D),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF131A17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

// Sexy dark-theme styling - inspired by premium quit apps
class AppStyle {
  // Colors - matching QuitVape logo (green leaf + blue swoosh + dark navy)
  static const bg = Color(0xFF0A0F0D);
  static const cardBg = Color(0xFF131A17);
  static const cardBg2 = Color(0xFF1A221E);
  static const emerald = Color(0xFF00E5A0);
  static const emeraldDark = Color(0xFF00B87D);
  static const skyBlue = Color(0xFF4FC3F7);
  static const deepBlue = Color(0xFF1E3A5F);
  static const navy = Color(0xFF1A2B3C);
  static const gold = Color(0xFFFFB800);
  static const red = Color(0xFFFF4D6D);
  static const redDark = Color(0xFFE0355B);
  static const textDim = Color(0xFF8A9A94);
  static const textFaint = Color(0xFF5A6A64);

  // Gradients - logo inspired
  static const gradientEmerald = LinearGradient(
    colors: [Color(0xFF00E5A0), Color(0xFF00B87D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientLogo = LinearGradient(
    colors: [Color(0xFF00E5A0), Color(0xFF4FC3F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientCard = LinearGradient(
    colors: [Color(0xFF16211C), Color(0xFF0F1613)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientHero = LinearGradient(
    colors: [Color(0xFF1A2E24), Color(0xFF0F1A14)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const gradientRed = LinearGradient(
    colors: [Color(0xFFFF4D6D), Color(0xFFE0355B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientGold = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFFF8A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card decoration
  static BoxDecoration card({bool glow = false}) {
    return BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF1E2A24), width: 1),
      boxShadow: glow
          ? [BoxShadow(color: emerald.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 8))]
          : null,
    );
  }

  // Hero card with emerald border glow
  static BoxDecoration heroCard() {
    return BoxDecoration(
      gradient: gradientHero,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: emerald.withOpacity(0.3), width: 1.5),
      boxShadow: [
        BoxShadow(color: emerald.withOpacity(0.12), blurRadius: 32, offset: const Offset(0, 12)),
      ],
    );
  }

  static TextStyle headline({double size = 28}) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w800,
      color: Colors.white,
      letterSpacing: -0.5,
      height: 1.2,
    );
  }

  static TextStyle subtext() {
    return const TextStyle(fontSize: 14, color: textDim, height: 1.5);
  }
}
