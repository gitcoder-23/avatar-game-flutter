import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/colors.dart';
import 'components/boss_entity.dart';
import 'components/enemy_entity.dart';
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
    // 1. Screen Shake Calculation
    double shakeOffsetX = 0.0;
    double shakeOffsetY = 0.0;
    if (controller.screenShakeIntensity > 0) {
      shakeOffsetX = (Random().nextDouble() - 0.5) * controller.screenShakeIntensity * 2;
      shakeOffsetY = (Random().nextDouble() - 0.5) * controller.screenShakeIntensity * 2;
    }

    canvas.save();
    canvas.translate(shakeOffsetX, shakeOffsetY);

    // 2. Camera Transform (Hero Centered)
    final screenCenterX = size.width / 2;
    final screenCenterY = size.height / 2;
    final viewX = screenCenterX - controller.cameraX;
    final viewY = screenCenterY - controller.cameraY;

    canvas.save();
    canvas.translate(viewX, viewY);

    // 3. Render Arena Background & Elemental Floor Grid
    _renderArenaFloor(canvas, size);

    // 4. Render Center Rune Circle
    _renderCenterRune(canvas);

    // 5. Render Projectiles
    _renderProjectiles(canvas);

    // 6. Render Enemies
    for (var enemy in controller.enemies) {
      if (enemy.isBoss) {
        BossEntity.render(canvas, enemy, animTime);
      } else {
        EnemyEntity.render(canvas, enemy, animTime);
      }
    }

    // 7. Render Hero
    HeroEntity.render(canvas, controller.hero, animTime);

    // 8. Render Particles Layer
    controller.particleSystem.render(canvas);

    // 9. Render Floating Texts
    _renderFloatingTexts(canvas);

    canvas.restore(); // Restore Camera
    canvas.restore(); // Restore Screen Shake
  }

  void _renderArenaFloor(Canvas canvas, Size size) {
    // Arena Background
    final arenaRect = const Rect.fromLTWH(0, 0, GameConstants.worldWidth, GameConstants.worldHeight);
    final bgPaint = Paint()..color = AppColors.bgArena;
    canvas.drawRect(arenaRect, bgPaint);

    // Stage Gradient Tint
    final stageTint = Paint()
      ..shader = RadialGradient(
        colors: [
          controller.stage.primaryColor.withValues(alpha: 0.12),
          controller.stage.secondaryColor.withValues(alpha: 0.05),
          AppColors.transparent,
        ],
        radius: 0.8,
      ).createShader(arenaRect);
    canvas.drawRect(arenaRect, stageTint);

    // Grid Lines
    final gridPaint = Paint()
      ..color = AppColors.gridLines
      ..strokeWidth = 1.0;

    const gridSize = 100.0;
    for (double x = 0; x <= GameConstants.worldWidth; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, GameConstants.worldHeight), gridPaint);
    }
    for (double y = 0; y <= GameConstants.worldHeight; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(GameConstants.worldWidth, y), gridPaint);
    }

    // Arena Perimeter Glow Boundary
    final borderGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = controller.stage.primaryColor.withValues(alpha: 0.7);
    canvas.drawRect(arenaRect, borderGlow);

    final borderInner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = AppColors.white.withValues(alpha: 0.5);
    canvas.drawRect(arenaRect.deflate(4), borderInner);
  }

  void _renderCenterRune(Canvas canvas) {
    final centerX = GameConstants.worldWidth / 2;
    final centerY = GameConstants.worldHeight / 2;

    final runePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = controller.stage.primaryColor.withValues(alpha: 0.35);

    canvas.drawCircle(Offset(centerX, centerY), 260, runePaint);
    canvas.drawCircle(Offset(centerX, centerY), 160, runePaint);

    // Rotating 8-point elemental star
    final starPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = controller.stage.secondaryColor.withValues(alpha: 0.4);

    const numPoints = 8;
    for (int i = 0; i < numPoints; i++) {
      final angle = i * 2 * pi / numPoints + animTime * 0.2;
      final x1 = centerX + cos(angle) * 260;
      final y1 = centerY + sin(angle) * 260;
      final x2 = centerX + cos(angle + pi) * 260;
      final y2 = centerY + sin(angle + pi) * 260;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), starPaint);
    }
  }

  void _renderProjectiles(Canvas canvas) {
    final projPaint = Paint()..style = PaintingStyle.fill;
    final projGlow = Paint()..style = PaintingStyle.stroke..strokeWidth = 3.0;

    for (var p in controller.projectiles) {
      projPaint.color = p.color;
      projGlow.color = AppColors.white;

      canvas.drawCircle(Offset(p.x, p.y), p.radius, projPaint);
      canvas.drawCircle(Offset(p.x, p.y), p.radius + 2, projGlow);

      // Trailing tail
      final tailPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = p.radius * 1.5
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [p.color.withValues(alpha: 0.8), AppColors.transparent],
        ).createShader(Rect.fromLTWH(p.x - p.vx * 0.05, p.y - p.vy * 0.05, p.vx * 0.05, p.vy * 0.05));

      canvas.drawLine(Offset(p.x, p.y), Offset(p.x - p.vx * 0.06, p.y - p.vy * 0.06), tailPaint);
    }
  }

  void _renderFloatingTexts(Canvas canvas) {
    for (var ft in controller.floatingTexts) {
      final alpha = (ft.lifeProgress * 255).clamp(0, 255).toInt();
      final textSpan = TextSpan(
        text: ft.text,
        style: TextStyle(
          color: ft.color.withValues(alpha: alpha / 255),
          fontSize: ft.fontSize,
          fontWeight: ft.isCrit ? FontWeight.w900 : FontWeight.bold,
          shadows: [
            Shadow(
              color: AppColors.black.withValues(alpha: alpha / 255),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(ft.x - textPainter.width / 2, ft.y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
