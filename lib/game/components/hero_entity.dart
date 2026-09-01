import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../models/hero_model.dart';

class HeroEntity {
  static void render(Canvas canvas, HeroModel hero, double animTime) {
    if (hero.isInvulnerable && (animTime * 15).floor() % 2 == 0) {
      // Blink when invulnerable
      return;
    }

    canvas.save();
    canvas.translate(hero.x, hero.y);

    // 1. Glowing Elemental Aura
    final auraRadius = 32.0 + sin(animTime * 4) * 3.0;
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.frostPrimary.withValues(alpha: 0.4),
          AppColors.frostGlow.withValues(alpha: 0.15),
          AppColors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: auraRadius + 15));
    canvas.drawCircle(Offset.zero, auraRadius + 15, auraPaint);

    // 2. Ultimate Casting Ring
    if (hero.isCastingUltimate) {
      final ultPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..color = AppColors.celestialGold.withValues(alpha: 0.8);
      canvas.drawCircle(Offset.zero, 55.0 + sin(animTime * 12) * 5, ultPaint);
    }

    // 3. Rotate hero body towards facing angle
    canvas.rotate(hero.facingAngle);

    // Shadow
    final shadowPaint = Paint()..color = AppColors.shadowBlack;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 4), width: 44, height: 28),
      shadowPaint,
    );

    // Cape / Cloak
    final capePath = Path()
      ..moveTo(-12, -14)
      ..lineTo(-32 + sin(animTime * 6) * 4, 0)
      ..lineTo(-12, 14)
      ..close();
    final capePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.frostSecondary, AppColors.bgNavy],
      ).createShader(Rect.fromLTWH(-36, -16, 36, 32));
    canvas.drawPath(capePath, capePaint);

    // Torso Armor
    final armorPaint = Paint()..color = AppColors.bgSlateCard;
    final armorHighlight = Paint()..color = AppColors.frostPrimary;
    canvas.drawCircle(Offset.zero, 18, armorPaint);

    // Shoulder Pauldrons
    canvas.drawCircle(const Offset(4, -14), 7, armorHighlight);
    canvas.drawCircle(const Offset(4, 14), 7, armorHighlight);

    // Head / Helm with Visor
    final helmPaint = Paint()..color = AppColors.bgHelm;
    canvas.drawCircle(const Offset(6, 0), 10, helmPaint);

    final visorPaint = Paint()..color = AppColors.frostPrimary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(11, 0), width: 6, height: 10),
        const Radius.circular(3),
      ),
      visorPaint,
    );

    // Elemental Dual Blades
    final bladePaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;
    final bladeGlow = Paint()
      ..color = AppColors.frostPrimary
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Main Blade
    final bladeOffset = hero.isAttacking ? 22.0 : 14.0;
    final bladePath = Path()
      ..moveTo(12, 16)
      ..lineTo(12 + bladeOffset, 16)
      ..lineTo(16 + bladeOffset, 18)
      ..lineTo(12 + bladeOffset, 20)
      ..lineTo(12, 20)
      ..close();

    canvas.drawPath(bladePath, bladePaint);
    canvas.drawPath(bladePath, bladeGlow);

    // Offhand Blade
    final offBladePath = Path()
      ..moveTo(12, -16)
      ..lineTo(12 + bladeOffset * 0.8, -16)
      ..lineTo(15 + bladeOffset * 0.8, -18)
      ..lineTo(12 + bladeOffset * 0.8, -20)
      ..lineTo(12, -20)
      ..close();

    canvas.drawPath(offBladePath, bladePaint);
    canvas.drawPath(offBladePath, bladeGlow);

    // 4. Render Slash Arc if attacking
    if (hero.isAttacking) {
      final slashPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [
            AppColors.transparent,
            AppColors.frostPrimary.withValues(alpha: 0.5),
            AppColors.white,
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: 48));

      final slashAngle = (hero.attackComboIndex % 2 == 0) ? -0.8 : 0.8;
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: 46),
        -pi / 4 + slashAngle * 0.4,
        pi / 2,
        false,
        slashPaint,
      );
    }

    canvas.restore();
  }
}
