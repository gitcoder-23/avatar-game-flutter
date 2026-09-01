import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import 'polygon3d.dart';
import 'vector3d.dart';

class MeshBuilder {
  // -------------------------------------------------------------
  // 1. 3D CUBE / PRISM GENERATOR (Building blocks, crates, vents)
  // -------------------------------------------------------------
  static List<Polygon3D> createBox({
    required Vector3D center,
    required double sizeX,
    required double sizeY,
    required double sizeZ,
    required Color topColor,
    required Color sideColor,
    Color? strokeColor,
    bool isGlowing = false,
    Color? glowColor,
  }) {
    final hx = sizeX / 2;
    final hy = sizeY / 2;
    final hz = sizeZ / 2;

    // 8 Vertices
    final p0 = Vector3D(center.x - hx, center.y + hy, center.z - hz); // Top-Front-Left
    final p1 = Vector3D(center.x + hx, center.y + hy, center.z - hz); // Top-Front-Right
    final p2 = Vector3D(center.x + hx, center.y + hy, center.z + hz); // Top-Back-Right
    final p3 = Vector3D(center.x - hx, center.y + hy, center.z + hz); // Top-Back-Left
    final p4 = Vector3D(center.x - hx, center.y - hy, center.z - hz); // Bottom-Front-Left
    final p5 = Vector3D(center.x + hx, center.y - hy, center.z - hz); // Bottom-Front-Right
    final p6 = Vector3D(center.x + hx, center.y - hy, center.z + hz); // Bottom-Back-Right
    final p7 = Vector3D(center.x - hx, center.y - hy, center.z + hz); // Bottom-Back-Left

    return [
      // Top Face
      Polygon3D(
        vertices: [p0, p1, p2, p3],
        baseColor: topColor,
        strokeColor: strokeColor,
        isGlowing: isGlowing,
        glowColor: glowColor,
      ),
      // Front Face
      Polygon3D(
        vertices: [p0, p4, p5, p1],
        baseColor: sideColor,
        strokeColor: strokeColor,
      ),
      // Right Face
      Polygon3D(
        vertices: [p1, p5, p6, p2],
        baseColor: sideColor,
        strokeColor: strokeColor,
      ),
      // Back Face
      Polygon3D(
        vertices: [p2, p6, p7, p3],
        baseColor: sideColor,
        strokeColor: strokeColor,
      ),
      // Left Face
      Polygon3D(
        vertices: [p3, p7, p4, p0],
        baseColor: sideColor,
        strokeColor: strokeColor,
      ),
    ];
  }

  // -------------------------------------------------------------
  // 2. 3D MANHATTAN ROOFTOP ARENA & SKYSCRAPERS
  // -------------------------------------------------------------
  static List<Polygon3D> buildCityEnvironment(double animTime) {
    final List<Polygon3D> polygons = [];

    // Main Central Rooftop (The Combat Arena, 800 x 800)
    polygons.addAll(createBox(
      center: Vector3D(0, -20, 0),
      sizeX: 750,
      sizeY: 40,
      sizeZ: 750,
      topColor: const Color(0xFF161B26),
      sideColor: const Color(0xFF0F121A),
      strokeColor: AppColors.spiderBlue.withValues(alpha: 0.4),
    ));

    // Arena Perimeter Glowing Barrier Ledges
    polygons.addAll(createBox(
      center: Vector3D(0, 10, -375),
      sizeX: 750,
      sizeY: 16,
      sizeZ: 14,
      topColor: AppColors.spiderRedLight,
      sideColor: AppColors.spiderRedDark,
      isGlowing: true,
      glowColor: AppColors.spiderRed,
    ));
    polygons.addAll(createBox(
      center: Vector3D(0, 10, 375),
      sizeX: 750,
      sizeY: 16,
      sizeZ: 14,
      topColor: AppColors.spiderRedLight,
      sideColor: AppColors.spiderRedDark,
      isGlowing: true,
      glowColor: AppColors.spiderRed,
    ));
    polygons.addAll(createBox(
      center: Vector3D(-375, 10, 0),
      sizeX: 14,
      sizeY: 16,
      sizeZ: 750,
      topColor: AppColors.neonCyan,
      sideColor: AppColors.spiderBlueDark,
      isGlowing: true,
      glowColor: AppColors.neonCyan,
    ));
    polygons.addAll(createBox(
      center: Vector3D(375, 10, 0),
      sizeX: 14,
      sizeY: 16,
      sizeZ: 750,
      topColor: AppColors.neonCyan,
      sideColor: AppColors.spiderBlueDark,
      isGlowing: true,
      glowColor: AppColors.neonCyan,
    ));

    // Helipad Center Marking on Rooftop
    final heliY = 1.0;
    const heliRadius = 130.0;
    final List<Vector3D> heliRing = [];
    for (int i = 0; i < 12; i++) {
      final a = i * pi / 6;
      heliRing.add(Vector3D(cos(a) * heliRadius, heliY, sin(a) * heliRadius));
    }
    polygons.add(Polygon3D(
      vertices: heliRing,
      baseColor: const Color(0xFF1E2536),
      strokeColor: AppColors.electricGold,
      strokeWidth: 2.5,
      isGlowing: true,
      glowColor: AppColors.electricGold,
    ));

    // Rooftop AC Units & Water Towers
    polygons.addAll(createBox(
      center: Vector3D(-240, 25, -240),
      sizeX: 80,
      sizeY: 50,
      sizeZ: 80,
      topColor: const Color(0xFF2A3447),
      sideColor: const Color(0xFF1A2230),
      strokeColor: AppColors.white24,
    ));
    polygons.addAll(createBox(
      center: Vector3D(240, 35, -240),
      sizeX: 70,
      sizeY: 70,
      sizeZ: 70,
      topColor: const Color(0xFF382F24),
      sideColor: const Color(0xFF241E17),
      strokeColor: AppColors.white24,
    ));

    // Surrounding 3D Distant Skyscrapers (The Manhattan Skyline)
    final skyscraperConfigs = [
      {'x': -650.0, 'z': -650.0, 'w': 280.0, 'h': 450.0, 'color': const Color(0xFF0F172A)},
      {'x': 650.0, 'z': -650.0, 'w': 260.0, 'h': 550.0, 'color': const Color(0xFF111827)},
      {'x': -750.0, 'z': 0.0, 'w': 240.0, 'h': 380.0, 'color': const Color(0xFF1E1B4B)},
      {'x': 750.0, 'z': 0.0, 'w': 300.0, 'h': 600.0, 'color': const Color(0xFF18181B)},
      {'x': -650.0, 'z': 650.0, 'w': 250.0, 'h': 420.0, 'color': const Color(0xFF0F172A)},
      {'x': 650.0, 'z': 650.0, 'w': 280.0, 'h': 500.0, 'color': const Color(0xFF111827)},
      {'x': 0.0, 'z': -800.0, 'w': 360.0, 'h': 700.0, 'color': const Color(0xFF1E293B)},
      {'x': 0.0, 'z': 800.0, 'w': 340.0, 'h': 480.0, 'color': const Color(0xFF0F172A)},
    ];

    for (var b in skyscraperConfigs) {
      final bx = b['x'] as double;
      final bz = b['z'] as double;
      final bw = b['w'] as double;
      final bh = b['h'] as double;
      final bColor = b['color'] as Color;

      polygons.addAll(createBox(
        center: Vector3D(bx, bh / 2 - 300, bz),
        sizeX: bw,
        sizeY: bh,
        sizeZ: bw,
        topColor: bColor,
        sideColor: bColor.withValues(alpha: 0.85),
        strokeColor: AppColors.neonCyan.withValues(alpha: 0.25),
      ));

      // Neon Rooftop Antenna / Billboards on Skyscrapers
      polygons.addAll(createBox(
        center: Vector3D(bx, bh - 300 + 25, bz),
        sizeX: 12,
        sizeY: 50,
        sizeZ: 12,
        topColor: AppColors.spiderRedLight,
        sideColor: AppColors.spiderRedDark,
        isGlowing: true,
        glowColor: AppColors.spiderRed,
      ));
    }

    return polygons;
  }

  // -------------------------------------------------------------
  // 3. 3D SPIDER-MAN HERO MESH & ANIMATED LIMBS
  // -------------------------------------------------------------
  static List<Polygon3D> buildSpiderMan3D({
    required Vector3D pos,
    required double facingAngle,
    required bool isMoving,
    required bool isAttacking,
    required bool isDashing,
    required double animTime,
    bool isSymbiote = false,
  }) {
    final List<Polygon3D> polygons = [];

    final baseRed = isSymbiote ? AppColors.symbioteBlack : AppColors.spiderRed;
    final baseBlue = isSymbiote ? AppColors.symbiotePurple : AppColors.spiderBlue;
    final eyeColor = isSymbiote ? AppColors.webGlow : AppColors.white;

    final legSwing = isMoving ? sin(animTime * 14) * 14.0 : 0.0;
    final armSwing = isMoving ? -sin(animTime * 14) * 12.0 : 0.0;

    // Helper to rotate local hero point by facing angle around Y
    Vector3D transformPoint(double lx, double ly, double lz) {
      final cosA = cos(facingAngle);
      final sinA = sin(facingAngle);
      final rx = lx * cosA - lz * sinA;
      final rz = lx * sinA + lz * cosA;
      return Vector3D(pos.x + rx, pos.y + ly, pos.z + rz);
    }

    // A. 3D Spider Boots & Legs
    // Left Leg
    polygons.addAll(createBox(
      center: transformPoint(-8, 14 + legSwing * 0.5, legSwing),
      sizeX: 8,
      sizeY: 28,
      sizeZ: 10,
      topColor: baseBlue,
      sideColor: baseRed,
      strokeColor: AppColors.black45,
    ));
    // Right Leg
    polygons.addAll(createBox(
      center: transformPoint(8, 14 - legSwing * 0.5, -legSwing),
      sizeX: 8,
      sizeY: 28,
      sizeZ: 10,
      topColor: baseBlue,
      sideColor: baseRed,
      strokeColor: AppColors.black45,
    ));

    // B. 3D Torso & Chest with Spider Emblem
    final chestCenter = transformPoint(0, 42, 0);
    polygons.addAll(createBox(
      center: chestCenter,
      sizeX: 24,
      sizeY: 28,
      sizeZ: 16,
      topColor: baseRed,
      sideColor: baseBlue,
      strokeColor: AppColors.black45,
    ));

    // C. 3D Arms & Web-Shooters
    final attackArmOffset = isAttacking ? 18.0 : 0.0;
    // Left Arm
    polygons.addAll(createBox(
      center: transformPoint(-17, 44 + armSwing * 0.3, armSwing),
      sizeX: 7,
      sizeY: 24,
      sizeZ: 8,
      topColor: baseRed,
      sideColor: baseBlue,
      strokeColor: AppColors.black45,
    ));
    // Right Arm (Striking forward if attacking)
    polygons.addAll(createBox(
      center: transformPoint(17, 44 - armSwing * 0.3, -armSwing + attackArmOffset),
      sizeX: 7,
      sizeY: 24,
      sizeZ: 8,
      topColor: baseRed,
      sideColor: baseBlue,
      strokeColor: AppColors.black45,
    ));

    // D. 3D Spider Mask & Glowing White Eyes
    final headCenter = transformPoint(0, 64, 0);
    polygons.addAll(createBox(
      center: headCenter,
      sizeX: 16,
      sizeY: 18,
      sizeZ: 16,
      topColor: baseRed,
      sideColor: baseRed,
      strokeColor: AppColors.black45,
    ));

    // Glowing Angled White Mask Eyes
    final eyeLeft = transformPoint(-4, 65, 9);
    final eyeRight = transformPoint(4, 65, 9);
    polygons.addAll(createBox(
      center: eyeLeft,
      sizeX: 5,
      sizeY: 4,
      sizeZ: 2,
      topColor: eyeColor,
      sideColor: AppColors.black,
      isGlowing: true,
      glowColor: eyeColor,
    ));
    polygons.addAll(createBox(
      center: eyeRight,
      sizeX: 5,
      sizeY: 4,
      sizeZ: 2,
      topColor: eyeColor,
      sideColor: AppColors.black,
      isGlowing: true,
      glowColor: eyeColor,
    ));

    // E. 3D Web-Zip Rope if Dashing or Attacking
    if (isDashing || isAttacking) {
      final webStart = transformPoint(12, 42, 8);
      final webEnd = transformPoint(12, 120, 280);
      polygons.add(Polygon3D(
        vertices: [webStart, webEnd],
        baseColor: AppColors.webWhite,
        strokeColor: AppColors.webFluidBlue,
        strokeWidth: 3.5,
        isGlowing: true,
        glowColor: AppColors.webFluidBlue,
      ));
    }

    return polygons;
  }

  // -------------------------------------------------------------
  // 4. 3D BOSS: ELECTRO (Hovering, Electric Storm, Lightning Orbs)
  // -------------------------------------------------------------
  static List<Polygon3D> buildElectro3D({
    required Vector3D pos,
    required double facingAngle,
    required double animTime,
  }) {
    final List<Polygon3D> polygons = [];

    final hoverY = pos.y + 24.0 + sin(animTime * 5) * 10.0;
    final electroPos = Vector3D(pos.x, hoverY, pos.z);

    // Green & Yellow High-Voltage Suit
    polygons.addAll(createBox(
      center: Vector3D(electroPos.x, electroPos.y + 36, electroPos.z),
      sizeX: 26,
      sizeY: 34,
      sizeZ: 18,
      topColor: AppColors.electricGold,
      sideColor: const Color(0xFF15803D),
      strokeColor: AppColors.electricGold,
      isGlowing: true,
      glowColor: AppColors.electricGold,
    ));

    // Head with Starburst Lightning Mask
    polygons.addAll(createBox(
      center: Vector3D(electroPos.x, electroPos.y + 60, electroPos.z),
      sizeX: 18,
      sizeY: 18,
      sizeZ: 18,
      topColor: AppColors.criticalYellow,
      sideColor: AppColors.criticalYellow,
      isGlowing: true,
      glowColor: AppColors.electricGold,
    ));

    // 4 Orbiting 3D High-Voltage Lightning Plasma Spheres
    for (int i = 0; i < 4; i++) {
      final orbAngle = animTime * 4.0 + (i * pi / 2);
      final ox = electroPos.x + cos(orbAngle) * 55.0;
      final oy = electroPos.y + 40.0 + sin(animTime * 6 + i) * 15.0;
      final oz = electroPos.z + sin(orbAngle) * 55.0;

      polygons.addAll(createBox(
        center: Vector3D(ox, oy, oz),
        sizeX: 12,
        sizeY: 12,
        sizeZ: 12,
        topColor: AppColors.criticalYellow,
        sideColor: AppColors.neonCyan,
        isGlowing: true,
        glowColor: AppColors.electricGold,
      ));

      // Lightning arc connection to Electro
      polygons.add(Polygon3D(
        vertices: [Vector3D(ox, oy, oz), Vector3D(electroPos.x, electroPos.y + 40, electroPos.z)],
        baseColor: AppColors.electricGold,
        strokeColor: AppColors.criticalYellow,
        strokeWidth: 2.5,
        isGlowing: true,
        glowColor: AppColors.electricGold,
      ));
    }

    return polygons;
  }

  // -------------------------------------------------------------
  // 5. 3D BOSS: DR. OCTOPUS (4 Articulated Mechanical Tentacles)
  // -------------------------------------------------------------
  static List<Polygon3D> buildDrOctopus3D({
    required Vector3D pos,
    required double facingAngle,
    required double animTime,
  }) {
    final List<Polygon3D> polygons = [];

    // Body in Green Trenchcoat
    polygons.addAll(createBox(
      center: Vector3D(pos.x, pos.y + 36, pos.z),
      sizeX: 30,
      sizeY: 38,
      sizeZ: 22,
      topColor: const Color(0xFF1E3A2F),
      sideColor: const Color(0xFF142921),
      strokeColor: AppColors.white24,
    ));

    // Head with Round Yellow/Orange Goggles
    polygons.addAll(createBox(
      center: Vector3D(pos.x, pos.y + 64, pos.z),
      sizeX: 18,
      sizeY: 18,
      sizeZ: 18,
      topColor: const Color(0xFFD4A373),
      sideColor: const Color(0xFFBC6C25),
      strokeColor: AppColors.black45,
    ));
    polygons.addAll(createBox(
      center: Vector3D(pos.x, pos.y + 65, pos.z + 10),
      sizeX: 14,
      sizeY: 6,
      sizeZ: 3,
      topColor: AppColors.criticalYellow,
      sideColor: AppColors.black,
      isGlowing: true,
      glowColor: AppColors.criticalYellow,
    ));

    // 4 Articulated 3D Mechanical Steel Tentacle Arms with 3-Prong Claws
    final tentacleOffsets = [
      {'angle': -0.7, 'height': 50.0, 'signX': -1.0},
      {'angle': 0.7, 'height': 50.0, 'signX': 1.0},
      {'angle': -1.8, 'height': 25.0, 'signX': -1.0},
      {'angle': 1.8, 'height': 25.0, 'signX': 1.0},
    ];

    for (int t = 0; t < tentacleOffsets.length; t++) {
      final tConf = tentacleOffsets[t];
      final baseA = tConf['angle']! + facingAngle;
      final startH = tConf['height']!;
      final sx = tConf['signX']!;

      var currentJoint = Vector3D(pos.x + sx * 16, pos.y + startH, pos.z - 8);

      // 4 Segmented Joints per tentacle
      for (int seg = 0; seg < 4; seg++) {
        final wave = sin(animTime * 4 + seg * 0.8 + t) * 18.0;
        final reachDist = 28.0;

        final nextJoint = Vector3D(
          currentJoint.x + cos(baseA) * reachDist + (sx * wave * 0.4),
          currentJoint.y + (seg == 3 ? -15.0 : 10.0) + wave * 0.5,
          currentJoint.z + sin(baseA) * reachDist + wave * 0.6,
        );

        polygons.addAll(createBox(
          center: Vector3D(
            (currentJoint.x + nextJoint.x) / 2,
            (currentJoint.y + nextJoint.y) / 2,
            (currentJoint.z + nextJoint.z) / 2,
          ),
          sizeX: 10 - seg * 1.5,
          sizeY: 10 - seg * 1.5,
          sizeZ: reachDist,
          topColor: const Color(0xFF94A3B8),
          sideColor: const Color(0xFF475569),
          strokeColor: AppColors.neonCyan.withValues(alpha: 0.6),
          isGlowing: seg == 3,
          glowColor: AppColors.neonCyan,
        ));

        currentJoint = nextJoint;
      }

      // 3-Prong Pincer Claw at Tentacle Tip
      polygons.addAll(createBox(
        center: currentJoint,
        sizeX: 14,
        sizeY: 14,
        sizeZ: 8,
        topColor: AppColors.healthRed,
        sideColor: const Color(0xFF334155),
        isGlowing: true,
        glowColor: AppColors.healthRed,
      ));
    }

    return polygons;
  }

  // -------------------------------------------------------------
  // 6. 3D FINAL BOSS: VENOM (Massive Symbiote Titan, Fangs & Tendrils)
  // -------------------------------------------------------------
  static List<Polygon3D> buildVenom3D({
    required Vector3D pos,
    required double facingAngle,
    required double animTime,
  }) {
    final List<Polygon3D> polygons = [];

    // Giant 2x Scale Muscular Symbiote Torso
    polygons.addAll(createBox(
      center: Vector3D(pos.x, pos.y + 54, pos.z),
      sizeX: 52,
      sizeY: 56,
      sizeZ: 36,
      topColor: AppColors.symbioteBlack,
      sideColor: const Color(0xFF0A0812),
      strokeColor: AppColors.venomGlow.withValues(alpha: 0.6),
    ));

    // Massive White Spider Chest Emblem
    polygons.addAll(createBox(
      center: Vector3D(pos.x, pos.y + 60, pos.z + 19),
      sizeX: 34,
      sizeY: 28,
      sizeZ: 2,
      topColor: AppColors.white,
      sideColor: AppColors.white70,
      isGlowing: true,
      glowColor: AppColors.webGlow,
    ));

    // Giant Head with Wide Open Crimson Jaw & White Fangs
    polygons.addAll(createBox(
      center: Vector3D(pos.x, pos.y + 92, pos.z),
      sizeX: 34,
      sizeY: 34,
      sizeZ: 34,
      topColor: AppColors.symbioteBlack,
      sideColor: const Color(0xFF0F0B1E),
      strokeColor: AppColors.venomGlow,
    ));

    // Jagged Glowing White Eyes
    polygons.addAll(createBox(
      center: Vector3D(pos.x - 10, pos.y + 98, pos.z + 18),
      sizeX: 10,
      sizeY: 8,
      sizeZ: 2,
      topColor: AppColors.white,
      sideColor: AppColors.venomGlow,
      isGlowing: true,
      glowColor: AppColors.webGlow,
    ));
    polygons.addAll(createBox(
      center: Vector3D(pos.x + 10, pos.y + 98, pos.z + 18),
      sizeX: 10,
      sizeY: 8,
      sizeZ: 2,
      topColor: AppColors.white,
      sideColor: AppColors.venomGlow,
      isGlowing: true,
      glowColor: AppColors.webGlow,
    ));

    // Red Jaw & Fangs
    polygons.addAll(createBox(
      center: Vector3D(pos.x, pos.y + 82, pos.z + 16),
      sizeX: 26,
      sizeY: 12,
      sizeZ: 8,
      topColor: AppColors.carnageCrimson,
      sideColor: const Color(0xFF450A0A),
      isGlowing: true,
      glowColor: AppColors.carnageCrimson,
    ));

    // 6 Writhing 3D Symbiote Tendrils from Venom's Back
    for (int i = 0; i < 6; i++) {
      final tAngle = (i - 2.5) * 0.45 + facingAngle + pi;
      final wave = sin(animTime * 6 + i) * 25.0;

      final startPt = Vector3D(pos.x, pos.y + 60, pos.z - 15);
      final midPt = Vector3D(pos.x + cos(tAngle) * 45 + wave * 0.4, pos.y + 85 + wave * 0.6, pos.z + sin(tAngle) * 45);
      final tipPt = Vector3D(pos.x + cos(tAngle) * 85 + wave, pos.y + 110 - wave * 0.5, pos.z + sin(tAngle) * 85);

      polygons.add(Polygon3D(
        vertices: [startPt, midPt, tipPt],
        baseColor: AppColors.symbioteBlack,
        strokeColor: AppColors.carnageCrimson,
        strokeWidth: 5.0,
        isGlowing: true,
        glowColor: AppColors.carnageCrimson,
      ));
    }

    return polygons;
  }

  // -------------------------------------------------------------
  // 7. 3D ENEMIES (Street Thugs & Flying Cyber Drones)
  // -------------------------------------------------------------
  static List<Polygon3D> buildEnemy3D({
    required Vector3D pos,
    required double facingAngle,
    required bool isDrone,
    required Color primaryColor,
    required Color glowColor,
    required double animTime,
  }) {
    final List<Polygon3D> polygons = [];

    if (isDrone) {
      // Flying Cyber Drone with 4 Spinning Cyan Rotors
      final hoverY = pos.y + 30 + sin(animTime * 8) * 8.0;
      final dronePos = Vector3D(pos.x, hoverY, pos.z);

      // Central Metal Hex Body
      polygons.addAll(createBox(
        center: dronePos,
        sizeX: 26,
        sizeY: 10,
        sizeZ: 26,
        topColor: const Color(0xFF1E293B),
        sideColor: const Color(0xFF0F172A),
        strokeColor: AppColors.neonCyan,
      ));

      // 4 Spinning Rotors
      final rotorSpin = animTime * 30.0;
      for (int i = 0; i < 4; i++) {
        final rAngle = i * (pi / 2) + rotorSpin;
        final rx = dronePos.x + cos(rAngle) * 22.0;
        final rz = dronePos.z + sin(rAngle) * 22.0;

        polygons.addAll(createBox(
          center: Vector3D(rx, dronePos.y + 4, rz),
          sizeX: 10,
          sizeY: 2,
          sizeZ: 10,
          topColor: AppColors.neonCyan,
          sideColor: AppColors.spiderBlueLight,
          isGlowing: true,
          glowColor: AppColors.neonCyan,
        ));
      }

      // Red Targeting Laser to Ground
      polygons.add(Polygon3D(
        vertices: [dronePos, Vector3D(dronePos.x, 0, dronePos.z)],
        baseColor: AppColors.healthRed,
        strokeColor: AppColors.healthRedLight,
        strokeWidth: 1.5,
        isGlowing: true,
        glowColor: AppColors.healthRed,
      ));
    } else {
      // Street Thug Brawler with Baseball Bat
      polygons.addAll(createBox(
        center: Vector3D(pos.x, pos.y + 32, pos.z),
        sizeX: 20,
        sizeY: 34,
        sizeZ: 14,
        topColor: primaryColor,
        sideColor: const Color(0xFF1E1B2E),
        strokeColor: glowColor.withValues(alpha: 0.6),
      ));

      // Head with Bandana
      polygons.addAll(createBox(
        center: Vector3D(pos.x, pos.y + 56, pos.z),
        sizeX: 14,
        sizeY: 14,
        sizeZ: 14,
        topColor: const Color(0xFFE2E8F0),
        sideColor: AppColors.spiderRedLight,
        strokeColor: AppColors.black45,
      ));

      // Baseball Bat / Weapon
      final batEnd = Vector3D(pos.x + 14, pos.y + 48, pos.z + 12);
      polygons.addAll(createBox(
        center: batEnd,
        sizeX: 4,
        sizeY: 24,
        sizeZ: 4,
        topColor: AppColors.electricGold,
        sideColor: const Color(0xFF78350F),
      ));
    }

    return polygons;
  }
}
