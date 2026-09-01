import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../models/enemy_model.dart';
import 'engine_3d/camera3d.dart';
import 'engine_3d/mesh_builder.dart';
import 'engine_3d/polygon3d.dart';
import 'engine_3d/vector3d.dart';
import 'game_controller.dart';

class Game3DPainter extends CustomPainter {
  final GameController controller;
  final Camera3D camera;
  final double animTime;

  Game3DPainter({
    required this.controller,
    required this.camera,
    required this.animTime,
  }) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    controller.setViewportSize(size.width, size.height);

    // 1. Draw Cinematic 3D Manhattan Night Sky
    final skyRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final skyPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.6),
        radius: 1.2,
        colors: [
          Color(0xFF0F172A),
          Color(0xFF090D16),
          Color(0xFF030712),
        ],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, skyPaint);

    // Glowing Full Moon in Background
    final moonCenter = Offset(size.width * 0.78, size.height * 0.22);
    final moonGlow = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawCircle(moonCenter, 45, moonGlow);
    canvas.drawCircle(moonCenter, 24, Paint()..color = const Color(0xFFF1F5F9));

    // 2. Collect All 3D Scene Geometry
    final List<Polygon3D> scenePolygons = [];

    // A. 3D Manhattan Rooftops & City Skyscrapers
    scenePolygons.addAll(MeshBuilder.buildCityEnvironment(animTime));

    // B. 3D Enemies & Supervillain Bosses
    for (var enemy in controller.enemies) {
      if (enemy.isDead) continue;

      final enemyPos3D = Vector3D(enemy.x - 1200.0, 0.0, enemy.y - 800.0);

      if (enemy.type == EnemyType.dreadTitanBoss) {
        // Stage 6 Boss: Venom
        scenePolygons.addAll(MeshBuilder.buildVenom3D(
          pos: enemyPos3D,
          facingAngle: enemy.facingAngle,
          animTime: animTime,
        ));
      } else if (controller.stage.id == 3 && enemy.isBoss) {
        // Stage 3 Boss: Electro
        scenePolygons.addAll(MeshBuilder.buildElectro3D(
          pos: enemyPos3D,
          facingAngle: enemy.facingAngle,
          animTime: animTime,
        ));
      } else if (controller.stage.id == 5 && enemy.isBoss) {
        // Stage 5 Boss: Dr. Octopus
        scenePolygons.addAll(MeshBuilder.buildDrOctopus3D(
          pos: enemyPos3D,
          facingAngle: enemy.facingAngle,
          animTime: animTime,
        ));
      } else {
        // Regular 3D Street Thugs & Flying Drones
        final isDrone = enemy.type == EnemyType.shadowWolf || enemy.type == EnemyType.stormHarpy;
        scenePolygons.addAll(MeshBuilder.buildEnemy3D(
          pos: enemyPos3D,
          facingAngle: enemy.facingAngle,
          isDrone: isDrone,
          primaryColor: enemy.primaryColor,
          glowColor: enemy.glowColor,
          animTime: animTime,
        ));
      }
    }

    // C. 3D Spider-Man Hero Mesh
    final heroPos3D = Vector3D(controller.hero.x - 1200.0, 0.0, controller.hero.y - 800.0);
    final isSymbiote = controller.hero.heroName.toLowerCase().contains('symbiote') ||
        controller.hero.heroName.toLowerCase().contains('black');

    scenePolygons.addAll(MeshBuilder.buildSpiderMan3D(
      pos: heroPos3D,
      facingAngle: controller.hero.facingAngle,
      isMoving: controller.hero.isMoving,
      isAttacking: controller.hero.isAttacking,
      isDashing: controller.hero.isDashing,
      animTime: animTime,
      isSymbiote: isSymbiote,
    ));

    // 3. Directional 3D Sunlight & City Floodlights
    final lightDir = Vector3D(0.4, 0.8, -0.5).normalized();

    // 4. Project All 3D Polygons to 2D Screen Space
    final List<Polygon3D> visiblePolygons = [];
    for (var poly in scenePolygons) {
      poly.project(
        cameraPos: camera.position,
        cameraYaw: camera.yaw,
        cameraPitch: camera.pitch,
        focalLength: camera.focalLength,
        screenWidth: size.width,
        screenHeight: size.height,
        lightDir: lightDir,
      );

      if (poly.isVisible) {
        visiblePolygons.add(poly);
      }
    }

    // 5. Depth Sort (Painter's Algorithm: Furthest Z rendered first)
    visiblePolygons.sort((a, b) => b.depthZ.compareTo(a.depthZ));

    // 6. Draw All Sorted 3D Polygons
    for (var poly in visiblePolygons) {
      poly.render(canvas);
    }

    // 7. 3D Spider-Sense Alert Wave Over Hero
    bool isSpiderSense = false;
    for (var enemy in controller.enemies) {
      final d = sqrt(pow(enemy.x - controller.hero.x, 2) + pow(enemy.y - controller.hero.y, 2));
      if (d < 140.0) {
        isSpiderSense = true;
        break;
      }
    }

    if (isSpiderSense) {
      // Screen-Center Hero Spider-Sense Tingling Lines
      final sensePaint = Paint()
        ..color = AppColors.criticalYellow.withValues(alpha: 0.85 + sin(animTime * 15) * 0.15)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;

      final heroScreenCenter = Offset(size.width / 2, size.height * 0.58);
      for (int i = -3; i <= 3; i++) {
        final angle = -pi / 2 + (i * 0.24);
        const r1 = 44.0;
        final r2 = 68.0 + sin(animTime * 12 + i) * 8;
        canvas.drawLine(
          heroScreenCenter + Offset(cos(angle) * r1, sin(angle) * r1),
          heroScreenCenter + Offset(cos(angle) * r2, sin(angle) * r2),
          sensePaint,
        );
      }
    }

    // 8. 3D Comic Hit Bubbles & Words ("THWACK!", "ZAP!", "BAM!")
    for (var ft in controller.floatingTexts) {
      final ftPos3D = Vector3D(ft.x - 1200.0, 40.0, ft.y - 800.0);
      final relX = ftPos3D.x - camera.position.x;
      final relY = ftPos3D.y - camera.position.y;
      final relZ = ftPos3D.z - camera.position.z;
      final yawRot = Vector3D(relX, relY, relZ).rotateY(-camera.yaw);
      final camSpace = yawRot.rotateX(-camera.pitch);

      if (camSpace.z > 1.0) {
        final scale = camera.focalLength / camSpace.z;
        final screenX = (camSpace.x * scale) + (size.width / 2);
        final screenY = (camSpace.y * scale) + (size.height / 2);
        ft.render(canvas, screenX, screenY);
      }
    }
  }

  @override
  bool shouldRepaint(covariant Game3DPainter oldDelegate) => true;
}
