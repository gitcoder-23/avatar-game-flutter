import 'package:flutter/material.dart';

class AppColors {
  // --- Spider-Hero & Superhero Palettes ---
  static const Color spiderRed = Color(0xFFE50914);
  static const Color spiderRedLight = Color(0xFFFF2A37);
  static const Color spiderRedDark = Color(0xFF8B0000);

  static const Color spiderBlue = Color(0xFF0051FF);
  static const Color spiderBlueLight = Color(0xFF2979FF);
  static const Color spiderBlueDark = Color(0xFF0D1B2A);

  static const Color spiderGlow = Color(0xFFFF334B);
  static const Color webWhite = Color(0xFFF0F8FF);
  static const Color webGlow = Color(0xFFE0F7FA);

  // --- Venom & Symbiote Palettes ---
  static const Color symbioteBlack = Color(0xFF0A0A12);
  static const Color symbiotePurple = Color(0xFF7928CA);
  static const Color venomGlow = Color(0xFF9D00FF);
  static const Color venomTeeth = Color(0xFFEDE7F6);

  static const Color carnageCrimson = Color(0xFFFF0055);
  static const Color carnageGlow = Color(0xFFFF1744);

  static const Color ironGold = Color(0xFFFFD700);
  static const Color electricGold = Color(0xFFFFAB00);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonMagenta = Color(0xFFFF007F);

  // --- City Rooftops & Backgrounds ---
  static const Color bgDark = Color(0xFF06070D);
  static const Color bgDarkCard = Color(0xFF0F111E);
  static const Color bgArena = Color(0xFF080914);
  static const Color bgCitySkyline = Color(0xFF050711);
  static const Color bgNavy = Color(0xFF10172A);
  static const Color bgDeepBlue = Color(0xFF0A0F24);
  static const Color bgSlateDark = Color(0xFF0F172A);
  static const Color bgSlateCard = Color(0xFF1E293B);
  static const Color bgBuilding = Color(0xFF141A2E);

  // --- Glassmorphic Containers ---
  static const Color bgGlass = Color(0x331E293B);
  static const Color bgGlassDark = Color(0x330B0F19);
  static const Color borderGlass = Color(0x4D64B5F6);
  static const Color borderGlow = Color(0x8000E5FF);
  static const Color gridLines = Color(0x1A64B5F6);

  // --- HUD & Combat Gauges ---
  static const Color healthRed = Color(0xFFFF1744);
  static const Color healthRedLight = Color(0xFFFF5252);
  static const Color healthRedDim = Color(0xFFFF8A80);
  static const Color webFluidBlue = Color(0xFF00E5FF);
  static const Color webFluidBlueLight = Color(0xFF80D8FF);
  static const Color ultimateGold = Color(0xFFFFD700);
  static const Color comboOrange = Color(0xFFFF6D00);
  static const Color criticalYellow = Color(0xFFFFEA00);
  static const Color goldCurrency = Color(0xFFFFD700);
  static const Color crystalCurrency = Color(0xFF00E5FF);
  static const Color potionGreen = Color(0xFF00E676);

  // --- Enemies & Boss Palettes ---
  static const Color thugYellow = Color(0xFFFFB300);
  static const Color thugGlow = Color(0xFFFFD54F);
  static const Color droneCyan = Color(0xFF00E5FF);
  static const Color droneGlow = Color(0xFF80D8FF);
  static const Color mercRed = Color(0xFFFF3D00);
  static const Color mercGlow = Color(0xFFFF6E40);
  static const Color mutantPurple = Color(0xFF7C4DFF);
  static const Color mutantGlow = Color(0xFFB388FF);
  static const Color mechOrange = Color(0xFFFF9100);
  static const Color bossPrimary = Color(0xFF7928CA);
  static const Color bossPhase2 = Color(0xFFFF0055);
  static const Color bossPhase3 = Color(0xFFE50914);

  // --- Neutrals & Shadows ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white54 = Color(0x8AFFFFFF);
  static const Color white38 = Color(0x61FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white24 = Color(0x3DFFFFFF);
  static const Color white12 = Color(0x1FFFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);

  static const Color black = Color(0xFF000000);
  static const Color black87 = Color(0xDD000000);
  static const Color black78 = Color(0xC7000000);
  static const Color black60 = Color(0x99000000);
  static const Color black45 = Color(0x73000000);
  static const Color black38 = Color(0x61000000);
  static const Color black30 = Color(0x4D000000);
  static const Color shadowBlack = Color(0x80000000);
  static const Color shadowDeep = Color(0xB3000000);
  static const Color transparent = Colors.transparent;

  // --- Superhero Preset Gradients ---
  static const LinearGradient spiderGradient = LinearGradient(
    colors: [spiderRed, spiderBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient symbioteGradient = LinearGradient(
    colors: [symbioteBlack, symbiotePurple, carnageCrimson],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cityNightGradient = LinearGradient(
    colors: [Color(0xFF050711), Color(0xFF0B1021), Color(0xFF06070D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient comicGoldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFF6D00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nebulaBackground = LinearGradient(
    colors: [
      Color(0xFF070914),
      Color(0xFF0B1124),
      Color(0xFF14081E),
      Color(0xFF06070D),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient loginNebulaBackground = LinearGradient(
    colors: [
      Color(0xFF050711),
      Color(0xFF120B1E),
      Color(0xFF06070D),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient registerNebulaBackground = LinearGradient(
    colors: [
      Color(0xFF0B0614),
      Color(0xFF160920),
      Color(0xFF06070D),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Backwards compatible aliases for UI components
  static const Color firePrimary = spiderRed;
  static const Color fireSecondary = spiderRedLight;
  static const Color fireGlow = spiderGlow;
  static const Color fireDark = spiderRedDark;

  static const Color frostPrimary = spiderBlueLight;
  static const Color frostSecondary = spiderBlue;
  static const Color frostGlow = webFluidBlue;
  static const Color frostDark = spiderBlueDark;

  static const Color stormPrimary = electricGold;
  static const Color stormSecondary = thugYellow;
  static const Color stormGlow = thugGlow;
  static const Color stormDark = Color(0xFFE65100);

  static const Color voidPrimary = symbiotePurple;
  static const Color voidSecondary = carnageCrimson;
  static const Color voidGlow = venomGlow;
  static const Color voidDark = Color(0xFF311B92);

  static const Color celestialGold = ironGold;
  static const Color celestialCyan = neonCyan;
  static const Color celestialAccent = electricGold;
  static const Color natureGreen = Color(0xFF00E676);
  static const Color natureDark = Color(0xFF1B5E20);
  static const Color manaBlue = webFluidBlue;
  static const Color manaBlueLight = webFluidBlueLight;

  static const LinearGradient frostGradient = LinearGradient(
    colors: [spiderRed, spiderBlueLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fireGradient = LinearGradient(
    colors: [spiderRed, carnageCrimson],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient voidGradient = LinearGradient(
    colors: [symbioteBlack, symbiotePurple, carnageCrimson],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient celestialGradient = LinearGradient(
    colors: [spiderRed, spiderBlueLight, ironGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
