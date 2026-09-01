import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../models/hero_model.dart';

class HeroEntity {
  static void render(Canvas canvas, HeroModel hero, double screenX, double screenY, double animTime) {
    canvas.save();
    canvas.translate(screenX, screenY);

    // Shadow on Rooftop
    final shadowPaint = Paint()
      ..color = AppColors.shadowBlack
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 22), width: 44, height: 18),
      shadowPaint,
    );

    canvas.rotate(hero.facingAngle);

    // Spider-Hero Aura / Web Glow
    final isSymbioteSuit = hero.heroName.toLowerCase().contains('symbiote') ||
        hero.heroName.toLowerCase().contains('black');

    final auraColor = isSymbioteSuit ? AppColors.venomGlow : AppColors.spiderGlow;
    final auraPaint = Paint()
      ..color = auraColor.withValues(alpha: 0.35 + sin(animTime * 6) * 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(Offset.zero, 30, auraPaint);

    // Spider-Suit Torso
    final suitBaseColor = isSymbioteSuit ? AppColors.symbioteBlack : AppColors.spiderRed;
    final suitAccentColor = isSymbioteSuit ? AppColors.symbiotePurple : AppColors.spiderBlue;

    // Outer Suit Silhouette
    final suitPaint = Paint()..color = suitBaseColor;
    canvas.drawCircle(Offset.zero, 24, suitPaint);

    // Blue / Accent Flanks
    final flankPaint = Paint()..color = suitAccentColor;
    final flankPath = Path()
      ..addArc(Rect.fromCircle(center: Offset.zero, radius: 24), -pi / 3, 2 * pi / 3);
    canvas.drawPath(flankPath, flankPaint);

    final leftFlankPath = Path()
      ..addArc(Rect.fromCircle(center: Offset.zero, radius: 24), 2 * pi / 3, 2 * pi / 3);
    canvas.drawPath(leftFlankPath, flankPaint);

    // Web Lines Texture on Mask & Suit
    final webMeshPaint = Paint()
      ..color = isSymbioteSuit ? AppColors.venomGlow.withValues(alpha: 0.4) : AppColors.black45
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(-22, 0), const Offset(22, 0), webMeshPaint);
    canvas.drawLine(const Offset(0, -22), const Offset(0, 22), webMeshPaint);
    canvas.drawCircle(Offset.zero, 14, webMeshPaint);

    // Iconic Spider Emblem on Chest
    final spiderEmblemPaint = Paint()
      ..color = isSymbioteSuit ? AppColors.white : AppColors.black
      ..style = PaintingStyle.fill;
    _drawSpiderEmblem(canvas, spiderEmblemPaint);

    // Spider Mask Eyes (Glowing Angled White Eyes with Black Border)
    _drawSpiderEyes(canvas, isSymbioteSuit);

    // Attack Slash / Acrobat Kick Arc VFX
    if (hero.isAttacking) {
      final swingProgress = 1.0 - (hero.attackTimer / 0.2);
      final slashPaint = Paint()
        ..color = (isSymbioteSuit ? AppColors.carnageCrimson : AppColors.webFluidBlue)
            .withValues(alpha: 0.8)
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      final sweepAngle = pi * 0.9;
      final startAngle = -sweepAngle / 2 + (swingProgress * sweepAngle);
      final slashRect = Rect.fromCircle(center: Offset.zero, radius: 46);
      canvas.drawArc(slashRect, startAngle - 0.4, 0.8, false, slashPaint);
    }

    canvas.restore();
  }

  static void _drawSpiderEmblem(Canvas canvas, Paint paint) {
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 0), width: 6, height: 12), paint);
    // Spider legs
    canvas.drawLine(const Offset(0, -3), const Offset(12, -8), paint..strokeWidth = 1.5);
    canvas.drawLine(const Offset(0, -1), const Offset(14, -2), paint..strokeWidth = 1.5);
    canvas.drawLine(const Offset(0, 1), const Offset(13, 6), paint..strokeWidth = 1.5);
    canvas.drawLine(const Offset(0, 3), const Offset(11, 12), paint..strokeWidth = 1.5);

    canvas.drawLine(const Offset(0, -3), const Offset(-12, -8), paint..strokeWidth = 1.5);
    canvas.drawLine(const Offset(0, -1), const Offset(-14, -2), paint..strokeWidth = 1.5);
    canvas.drawLine(const Offset(0, 1), const Offset(-13, 6), paint..strokeWidth = 1.5);
    canvas.drawLine(const Offset(0, 3), const Offset(-11, 12), paint..strokeWidth = 1.5);
  }

  static void _drawSpiderEyes(Canvas canvas, bool isSymbiote) {
    final eyeBlackBorder = Paint()..color = AppColors.black;
    final eyeWhiteFill = Paint()..color = isSymbiote ? AppColors.webGlow : AppColors.white;

    final rightEyePath = Path()
      ..moveTo(6, -10)
      ..lineTo(18, -14)
      ..lineTo(14, -4)
      ..close();
    canvas.drawPath(rightEyePath, eyeBlackBorder);
    canvas.drawPath(rightEyePath, eyeWhiteFill);

    final leftEyePath = Path()
      ..moveTo(6, 10)
      ..lineTo(18, 14)
      ..lineTo(14, 4)
      ..close();
    canvas.drawPath(leftEyePath, eyeBlackBorder);
    canvas.drawPath(leftEyePath, eyeWhiteFill);
  }
}
