import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../models/hero_model.dart';

class HeroEntity {
  static void render(
    Canvas canvas,
    HeroModel hero,
    double screenX,
    double screenY,
    double animTime, {
    bool isSpiderSenseActive = false,
  }) {
    canvas.save();
    canvas.translate(screenX, screenY);

    // 1. Spider-Sense Warning Waves
    if (isSpiderSenseActive) {
      final sensePaint = Paint()
        ..color = AppColors.criticalYellow.withValues(alpha: 0.8 + sin(animTime * 15) * 0.2)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      for (int i = -3; i <= 3; i++) {
        final angle = -pi / 2 + (i * 0.22);
        final startR = 46.0;
        final endR = 64.0 + sin(animTime * 12 + i) * 6;
        canvas.drawLine(
          Offset(cos(angle) * startR, sin(angle) * startR),
          Offset(cos(angle) * endR, sin(angle) * endR),
          sensePaint,
        );
      }
    }

    // 2. Shadow on Rooftop Floor
    final shadowPaint = Paint()
      ..color = AppColors.shadowDeep
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 26), width: 62, height: 26),
      shadowPaint,
    );

    // 3. Web Tether Line if Web-Zipping or Attacking
    if (hero.isDashing || hero.isAttacking) {
      final webGlow = Paint()
        ..color = AppColors.webFluidBlue
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      final webCore = Paint()
        ..color = AppColors.webWhite
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      final startOffset = Offset(cos(hero.facingAngle) * 20, sin(hero.facingAngle) * 20);
      final endOffset = Offset(cos(hero.facingAngle) * 260, sin(hero.facingAngle) * 260);
      canvas.drawLine(startOffset, endOffset, webGlow);
      canvas.drawLine(startOffset, endOffset, webCore);
    }

    canvas.rotate(hero.facingAngle);

    // 4. Spider-Hero Body & Suit
    final isSymbioteSuit = hero.heroName.toLowerCase().contains('symbiote') ||
        hero.heroName.toLowerCase().contains('black');

    final baseColor = isSymbioteSuit ? AppColors.symbioteBlack : AppColors.spiderRed;
    final accentColor = isSymbioteSuit ? AppColors.symbiotePurple : AppColors.spiderBlue;
    final auraColor = isSymbioteSuit ? AppColors.venomGlow : AppColors.spiderGlow;

    // Glowing Superhero Energy Aura
    final auraPaint = Paint()
      ..color = auraColor.withValues(alpha: 0.35 + sin(animTime * 6) * 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(Offset.zero, 38, auraPaint);

    // Acrobatic Legs / Boots (Animated Running Steps)
    final legAngleOffset = hero.isMoving ? sin(animTime * 14) * 12.0 : 0.0;
    final bootPaint = Paint()..color = isSymbioteSuit ? AppColors.symbioteBlack : AppColors.spiderRed;

    // Left Leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(-14, 20 + legAngleOffset), width: 12, height: 20),
        const Radius.circular(5),
      ),
      bootPaint,
    );
    // Right Leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(14, 20 - legAngleOffset), width: 12, height: 20),
        const Radius.circular(5),
      ),
      bootPaint,
    );

    // Torso Base Silhouette (Radius 32)
    final torsoPaint = Paint()..color = baseColor;
    canvas.drawCircle(Offset.zero, 32, torsoPaint);

    // Blue Flanks / Side Accents
    final flankPaint = Paint()..color = accentColor;
    final leftFlank = Path()
      ..addArc(Rect.fromCircle(center: Offset.zero, radius: 32), pi * 0.4, pi * 0.5);
    final rightFlank = Path()
      ..addArc(Rect.fromCircle(center: Offset.zero, radius: 32), -pi * 0.9, pi * 0.5);
    canvas.drawPath(leftFlank, flankPaint);
    canvas.drawPath(rightFlank, flankPaint);

    // Web Shooters on Wrists
    final gauntletPaint = Paint()..color = AppColors.neonCyan;
    canvas.drawCircle(const Offset(24, -18), 4, gauntletPaint);
    canvas.drawCircle(const Offset(24, 18), 4, gauntletPaint);

    // Web Texture Mesh Grid Lines
    final webPaint = Paint()
      ..color = isSymbioteSuit ? AppColors.venomGlow.withValues(alpha: 0.45) : AppColors.black45
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(-30, 0), const Offset(30, 0), webPaint);
    canvas.drawLine(const Offset(0, -30), const Offset(0, 30), webPaint);
    canvas.drawLine(const Offset(-22, -22), const Offset(22, 22), webPaint);
    canvas.drawLine(const Offset(-22, 22), const Offset(22, -22), webPaint);
    canvas.drawCircle(Offset.zero, 18, webPaint);

    // Iconic Spider Emblem on Chest & Back
    final emblemPaint = Paint()
      ..color = isSymbioteSuit ? AppColors.white : AppColors.black
      ..style = PaintingStyle.fill;
    _drawSpiderEmblem(canvas, emblemPaint);

    // Expressive Spider Mask Eyes (Angled Glowing White Eyes with Black Outlines)
    _drawSpiderEyes(canvas, isSymbioteSuit);

    // Acrobatic Strike Slash Arc
    if (hero.isAttacking) {
      final swingProgress = 1.0 - (hero.attackTimer / 0.2);
      final slashPaint = Paint()
        ..color = (isSymbioteSuit ? AppColors.carnageCrimson : AppColors.spiderRedLight)
            .withValues(alpha: 0.85)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      final sweepAngle = pi * 1.1;
      final startAngle = -sweepAngle / 2 + (swingProgress * sweepAngle);
      final slashRect = Rect.fromCircle(center: Offset.zero, radius: 56);
      canvas.drawArc(slashRect, startAngle - 0.5, 0.9, false, slashPaint);
    }

    canvas.restore();
  }

  static void _drawSpiderEmblem(Canvas canvas, Paint paint) {
    // Spider Oval Body
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 0), width: 8, height: 16), paint);
    canvas.drawCircle(const Offset(0, -7), 3, paint);

    // 8 Long Branching Arachnid Legs
    final legPaint = Paint()
      ..color = paint.color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top Right
    canvas.drawLine(const Offset(0, -4), const Offset(14, -14), legPaint);
    canvas.drawLine(const Offset(14, -14), const Offset(20, -10), legPaint);
    // Middle Right
    canvas.drawLine(const Offset(0, -1), const Offset(18, -4), legPaint);
    // Bottom Right
    canvas.drawLine(const Offset(0, 2), const Offset(16, 10), legPaint);
    canvas.drawLine(const Offset(16, 10), const Offset(22, 16), legPaint);

    // Top Left
    canvas.drawLine(const Offset(0, -4), const Offset(-14, -14), legPaint);
    canvas.drawLine(const Offset(-14, -14), const Offset(-20, -10), legPaint);
    // Middle Left
    canvas.drawLine(const Offset(0, -1), const Offset(-18, -4), legPaint);
    // Bottom Left
    canvas.drawLine(const Offset(0, 2), const Offset(-16, 10), legPaint);
    canvas.drawLine(const Offset(-16, 10), const Offset(-22, 16), legPaint);
  }

  static void _drawSpiderEyes(Canvas canvas, bool isSymbiote) {
    final eyeBlackBorder = Paint()..color = AppColors.black;
    final eyeWhiteFill = Paint()..color = isSymbiote ? AppColors.webGlow : AppColors.white;

    // Right Eye
    final rightEyeBorder = Path()
      ..moveTo(8, -14)
      ..lineTo(26, -20)
      ..lineTo(20, -4)
      ..close();
    final rightEyeFill = Path()
      ..moveTo(9, -13)
      ..lineTo(23, -18)
      ..lineTo(18, -5)
      ..close();
    canvas.drawPath(rightEyeBorder, eyeBlackBorder);
    canvas.drawPath(rightEyeFill, eyeWhiteFill);

    // Left Eye
    final leftEyeBorder = Path()
      ..moveTo(8, 14)
      ..lineTo(26, 20)
      ..lineTo(20, 4)
      ..close();
    final leftEyeFill = Path()
      ..moveTo(9, 13)
      ..lineTo(23, 18)
      ..lineTo(18, 5)
      ..close();
    canvas.drawPath(leftEyeBorder, eyeBlackBorder);
    canvas.drawPath(leftEyeFill, eyeWhiteFill);
  }
}
