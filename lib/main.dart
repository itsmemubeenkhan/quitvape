import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      theme: _buildLightTheme(),
      themeMode: ThemeMode.light,
      home: QuitService.hasStarted() ? const HomeScreen() : const OnboardingScreen(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppStyle.bg,
      colorScheme: const ColorScheme.light(
        primary: AppStyle.primary,
        secondary: AppStyle.primary,
        surface: Colors.white,
        background: AppStyle.bg,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppStyle.line, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppStyle.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppStyle.ink),
        titleTextStyle: TextStyle(
          color: AppStyle.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppStyle.ink,
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}

// Clean, professional design system — light theme
class AppStyle {
  // Surfaces
  static const bg = Color(0xFFF4F7F5);
  static const cardBg = Colors.white;
  static const cardBg2 = Color(0xFFF4F7F5);
  static const line = Color(0xFFE2E9E5);

  // Text
  static const ink = Color(0xFF0E1B14);
  static const textDim = Color(0xFF5A6E63);
  static const textFaint = Color(0xFF9AA9A1);

  // Brand
  static const primary = Color(0xFF0BB57A);
  static const primaryDark = Color(0xFF08855C);
  static const primarySoft = Color(0xFFE3F6EE);
  static const emerald = Color(0xFF0BB57A); // alias for legacy code
  static const emeraldDark = Color(0xFF08855C);

  // Accents
  static const skyBlue = Color(0xFF2E9BD6);
  static const deepBlue = Color(0xFF1E3A5F);
  static const navy = Color(0xFF1A2B3C);
  static const gold = Color(0xFFF5A623);
  static const goldSoft = Color(0xFFFFF3DC);
  static const red = Color(0xFFE5484D);
  static const redDark = Color(0xFFC93A3F);
  static const redSoft = Color(0xFFFDECEC);

  // Primary button gradient
  static const gradientEmerald = LinearGradient(
    colors: [Color(0xFF0BB57A), Color(0xFF0AA06C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const gradientLogo = LinearGradient(
    colors: [Color(0xFF0BB57A), Color(0xFF2E9BD6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientCard = LinearGradient(
    colors: [Colors.white, Color(0xFFF7FAF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientHero = LinearGradient(
    colors: [Color(0xFFE9F8F0), Color(0xFFD9F2E5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const gradientRed = LinearGradient(
    colors: [Color(0xFFE5484D), Color(0xFFC93A3F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientGold = LinearGradient(
    colors: [Color(0xFFF5A623), Color(0xFFE8940A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card decoration — clean, subtle border, soft shadow
  static BoxDecoration card({bool glow = false}) {
    return BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: line, width: 1),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0E1B14).withOpacity(glow ? 0.08 : 0.04),
          blurRadius: glow ? 24 : 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Hero card — soft green tint
  static BoxDecoration heroCard() {
    return BoxDecoration(
      gradient: gradientHero,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: primary.withOpacity(0.25), width: 1),
    );
  }

  static TextStyle headline({double size = 28}) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w800,
      color: ink,
      letterSpacing: -0.5,
      height: 1.2,
    );
  }

  static TextStyle subtext() {
    return const TextStyle(fontSize: 14, color: textDim, height: 1.5);
  }

  // Primary button style helper
  static ButtonStyle primaryButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      minimumSize: const Size(double.infinity, 56),
    );
  }
}
