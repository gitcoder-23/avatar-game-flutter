import 'package:flutter/material.dart';
import 'colors.dart';

class GameTheme {
  // Aliases referencing AppColors
  static const Color firePrimary = AppColors.firePrimary;
  static const Color fireGlow = AppColors.fireGlow;
  static const Color frostPrimary = AppColors.frostPrimary;
  static const Color frostGlow = AppColors.frostGlow;
  static const Color stormPrimary = AppColors.stormPrimary;
  static const Color stormGlow = AppColors.stormGlow;
  static const Color voidPrimary = AppColors.voidPrimary;
  static const Color voidGlow = AppColors.voidGlow;
  static const Color celestialGold = AppColors.celestialGold;
  static const Color celestialCyan = AppColors.celestialCyan;

  // Surface & Glassmorphism
  static const Color bgDark = AppColors.bgDark;
  static const Color bgDarkCard = AppColors.bgDarkCard;
  static const Color bgGlass = AppColors.bgGlass;
  static const Color borderGlass = AppColors.borderGlass;
  static const Color borderGlow = AppColors.borderGlow;

  // HUD & Combat Colors
  static const Color healthRed = AppColors.healthRed;
  static const Color manaBlue = AppColors.manaBlue;
  static const Color ultimateGold = AppColors.ultimateGold;
  static const Color comboOrange = AppColors.comboOrange;
  static const Color criticalYellow = AppColors.criticalYellow;

  // Gradients
  static const LinearGradient fireGradient = AppColors.fireGradient;
  static const LinearGradient frostGradient = AppColors.frostGradient;
  static const LinearGradient voidGradient = AppColors.voidGradient;
  static const LinearGradient celestialGradient = AppColors.celestialGradient;
  static const LinearGradient glassGradient = AppColors.glassGradient;

  static BoxDecoration glassCardDecoration({
    double radius = 18,
    Color borderColor = borderGlass,
    Color glowColor = AppColors.transparent,
  }) {
    return BoxDecoration(
      color: bgGlass,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: glowColor.withValues(alpha: 0.3),
          blurRadius: 16,
          spreadRadius: 2,
        ),
        const BoxShadow(
          color: AppColors.shadowDeep,
          blurRadius: 20,
          offset: Offset(0, 10),
        ),
      ],
    );
  }

  static BoxDecoration glowingButtonDecoration({
    required List<Color> gradientColors,
    double radius = 14,
    Color glowColor = AppColors.borderGlow,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: glowColor.withValues(alpha: 0.6),
          blurRadius: 12,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static ThemeData get themeData {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bgDark,
      primaryColor: frostPrimary,
      colorScheme: const ColorScheme.dark(
        primary: frostPrimary,
        secondary: firePrimary,
        surface: bgDarkCard,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: frostPrimary,
          foregroundColor: AppColors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
