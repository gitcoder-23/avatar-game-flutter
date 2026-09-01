import 'package:flutter/material.dart';
import '../theme/colors.dart';

enum ElementType {
  spiderWeb,
  symbiote,
  techElectric,
  carnageStrike,
  ironArmor,
}

enum HeroSuitStyle {
  classicRedBlue,
  symbioteBlack,
  ironSpider,
  cyber2099,
}

enum HeroSuitPreset {
  classicSpider,
  symbioteBlack,
  ironSpider,
  cyber2099,
}

class GameConstants {
  // Arena World Dimensions
  static const double worldWidth = 2400.0;
  static const double worldHeight = 1600.0;

  // Hero Base Stats
  static const double baseHeroHp = 600.0;
  static const double baseHeroMp = 250.0;
  static const double baseHeroWebFluid = 250.0;
  static const double baseHeroAtk = 55.0;
  static const double baseHeroDef = 20.0;
  static const double baseHeroSpeed = 260.0;
  static const double baseHeroCritChance = 0.15;
  static const double baseHeroCritMultiplier = 2.0;

  // Web Zip & Combat Physics
  static const double webZipSpeed = 850.0;
  static const double webZipMaxRange = 450.0;
  static const double basicAttackRange = 95.0;
  static const double comboWindowSeconds = 1.4;
  static const int maxComboMultiplier = 5;

  // Comic Sound FX Words
  static const List<String> comicHitWords = [
    'THWACK!',
    'BAM!',
    'WHAM!',
    'POW!',
    'CRUNCH!',
    'KRAK!',
    'K.O.!',
  ];

  // Stage Theme Colors
  static const List<Color> stageColors = [
    AppColors.spiderBlueLight, // Stage 1: Queens Rooftops
    AppColors.thugYellow,      // Stage 2: Manhattan Skyscraper
    AppColors.symbiotePurple,  // Stage 3: Subway Underground
    AppColors.neonCyan,        // Stage 4: Oscorp Tech Labs
    AppColors.carnageCrimson,  // Stage 5: Times Square Catastrophe
    AppColors.bossPhase3,      // Stage 6: Oscorp Tower Apex (Venom Overlord)
  ];
}
