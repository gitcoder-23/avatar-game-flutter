import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/colors.dart';
import 'components/hero_entity.dart';
import 'game_controller.dart';

class GamePainter extends CustomPainter {
  final GameController controller;
  final double animTime;

  GamePainter({
    required this.controller,
    required this.animTime,
  }) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final cameraX = controller.cameraX;
    final cameraY = controller.cameraY;

    // 1. Dark City Night Sky Background
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgPaint = Paint()
      ..shader = AppColors.cityNightGradient.createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // 2. Distant Manhattan Skylines & Searchlights (Parallax)
    _drawCitySkylineParallax(canvas, size, cameraX, cameraY);

    // 3. Rooftop Combat Arena
    _drawRooftopArena(canvas, size, cameraX, cameraY);

    // 4. Projectiles & Web Shots
    for (var proj in controller.projectiles) {
      final screenX = proj.x - cameraX;
      final screenY = proj.y - cameraY;

      if (screenX >= -50 &&
          screenX <= size.width + 50 &&
          screenY >= -50 &&
          screenY <= size.height + 50) {
        _drawWebProjectile(canvas, proj, screenX, screenY);
      }
    }

    // 5. Enemies & Boss
    for (var enemy in controller.enemies) {
      final screenX = enemy.x - cameraX;
      final screenY = enemy.y - cameraY;

      if (screenX >= -100 &&
          screenX <= size.width + 100 &&
          screenY >= -100 &&
          screenY <= size.height + 100) {
        enemy.render(canvas, screenX, screenY);
      }
    }

    // 6. Spider-Hero Entity
    final heroScreenX = controller.hero.x - cameraX;
    final heroScreenY = controller.hero.y - cameraY;
    HeroEntity.render(canvas, controller.hero, heroScreenX, heroScreenY, animTime);

    // 7. Particle System (Web Splatters & Symbiote Tendrils)
    controller.particles.render(canvas, cameraX, cameraY);

    // 8. Comic Book Floating Text Bubbles ("THWACK!", "BAM!")
    for (var ft in controller.floatingTexts) {
      final screenX = ft.x - cameraX;
      final screenY = ft.y - cameraY;
      ft.render(canvas, screenX, screenY);
    }
  }

  void _drawCitySkylineParallax(Canvas canvas, Size size, double camX, double camY) {
    final skylinePaint = Paint()..color = AppColors.bgBuilding;
    final windowYellow = Paint()..color = AppColors.thugYellow.withValues(alpha: 0.7);
    final windowCyan = Paint()..color = AppColors.neonCyan.withValues(alpha: 0.6);

    // Distant Buildings
    for (int i = 0; i < 18; i++) {
      final bWidth = 90.0 + (i % 3) * 30.0;
      final bHeight = 180.0 + (i % 5) * 45.0;
      final bX = (i * 120.0 - camX * 0.15) % (size.width + 300) - 100;
      final bY = size.height - bHeight + 40;

      final bRect = Rect.fromLTWH(bX, bY, bWidth, bHeight);
      canvas.drawRect(bRect, skylinePaint);

      // Skyscraper windows
      for (double wy = bY + 15; wy < size.height; wy += 22) {
        for (double wx = bX + 10; wx < bX + bWidth - 10; wx += 16) {
          if ((wx + wy).toInt() % 3 == 0) {
            final wPaint = (wx.toInt() % 2 == 0) ? windowYellow : windowCyan;
            canvas.drawRect(Rect.fromLTWH(wx, wy, 8, 12), wPaint);
          }
        }
      }
    }

    // Sweeping Searchlight Beams across the sky
    final lightPaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final angle1 = -pi / 3 + sin(animTime * 0.5) * 0.4;
    final beamPath1 = Path()
      ..moveTo(size.width * 0.25, size.height)
      ..lineTo(size.width * 0.25 + cos(angle1) * 800 - 80, sin(angle1) * 800)
      ..lineTo(size.width * 0.25 + cos(angle1) * 800 + 80, sin(angle1) * 800)
      ..close();
    canvas.drawPath(beamPath1, lightPaint);

    final angle2 = -2 * pi / 3 + cos(animTime * 0.4) * 0.35;
    final beamPath2 = Path()
      ..moveTo(size.width * 0.75, size.height)
      ..lineTo(size.width * 0.75 + cos(angle2) * 800 - 90, sin(angle2) * 800)
      ..lineTo(size.width * 0.75 + cos(angle2) * 800 + 90, sin(angle2) * 800)
      ..close();
    canvas.drawPath(beamPath2, lightPaint);
  }

  void _drawRooftopArena(Canvas canvas, Size size, double camX, double camY) {
    final worldW = GameConstants.worldWidth;
    final worldH = GameConstants.worldHeight;

    // Arena Floor
    final arenaScreenRect = Rect.fromLTRB(-camX, -camY, worldW - camX, worldH - camY);
    final arenaPaint = Paint()..color = AppColors.bgArena;
    canvas.drawRect(arenaScreenRect, arenaPaint);

    // Rooftop Grid & Laser Border
    final borderPaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.5)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRect(arenaScreenRect, borderPaint);

    // Helipad / Central Spider Crest
    final centerScreenX = (worldW / 2) - camX;
    final centerScreenY = (worldH / 2) - camY;

    final ringPaint = Paint()
      ..color = AppColors.spiderRedLight.withValues(alpha: 0.35)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(centerScreenX, centerScreenY), 220, ringPaint);
    canvas.drawCircle(Offset(centerScreenX, centerScreenY), 160, ringPaint);

    // Spider Crest Lines
    final webPaint = Paint()
      ..color = AppColors.spiderBlueLight.withValues(alpha: 0.25)
      ..strokeWidth = 2.0;
    for (int i = 0; i < 8; i++) {
      final angle = i * (pi / 4);
      canvas.drawLine(
        Offset(centerScreenX, centerScreenY),
        Offset(centerScreenX + cos(angle) * 220, centerScreenY + sin(angle) * 220),
        webPaint,
      );
    }
  }

  void _drawWebProjectile(Canvas canvas, dynamic proj, double screenX, double screenY) {
    final webCorePaint = Paint()..color = AppColors.webWhite;
    final webGlowPaint = Paint()
      ..color = AppColors.webFluidBlue
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(Offset(screenX, screenY), 8, webGlowPaint);
    canvas.drawCircle(Offset(screenX, screenY), 5, webCorePaint);
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
