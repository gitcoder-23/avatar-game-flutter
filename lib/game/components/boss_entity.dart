import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../models/enemy_model.dart';

class BossEntity {
  static void render(Canvas canvas, EnemyModel boss, double animTime) {
    if (boss.isDead) return;

    final isFlashing = boss.hitFlashTimer > 0;

    canvas.save();
    canvas.translate(boss.x, boss.y);

    // 1. Colossal Aura depending on Boss Phase
    Color phaseAuraColor;
    switch (boss.bossPhase) {
      case BossPhase.phase1:
        phaseAuraColor = AppColors.bossPrimary;
        break;
      case BossPhase.phase2:
        phaseAuraColor = AppColors.bossPhase2;
        break;
      case BossPhase.phase3:
        phaseAuraColor = AppColors.bossPhase3;
        break;
    }

    // Expanding pulsating aura
    final auraRadius = boss.radius * 1.4 + sin(animTime * 5) * 8.0;
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          phaseAuraColor.withValues(alpha: 0.4),
          phaseAuraColor.withValues(alpha: 0.1),
          AppColors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: auraRadius + 20));
    canvas.drawCircle(Offset.zero, auraRadius + 20, auraPaint);

    // Shadow
    final shadowPaint = Paint()..color = AppColors.shadowDeep;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 15), width: boss.radius * 2.8, height: boss.radius * 1.8),
      shadowPaint,
    );

    // 2. Rotating Ancient Chaos Rune Ring behind boss
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = phaseAuraColor.withValues(alpha: 0.6);

    canvas.drawCircle(Offset.zero, boss.radius * 1.35, ringPaint);
    for (int i = 0; i < 8; i++) {
      final rAngle = i * pi / 4 + animTime * 1.5;
      final rx = cos(rAngle) * (boss.radius * 1.35);
      final ry = sin(rAngle) * (boss.radius * 1.35);
      canvas.drawCircle(Offset(rx, ry), 5, Paint()..color = phaseAuraColor);
    }

    // 3. Colossal Titan Wings (Phase 2 & Phase 3)
    if (boss.bossPhase != BossPhase.phase1) {
      final wingFlap = sin(animTime * 6) * 12;
      final wingPaint = Paint()
        ..shader = LinearGradient(
          colors: [phaseAuraColor, AppColors.black],
        ).createShader(Rect.fromLTWH(-boss.radius * 2.5, -boss.radius * 2, boss.radius * 5, boss.radius * 4));

      // Left Wing
      final leftWing = Path()
        ..moveTo(-boss.radius * 0.5, -boss.radius * 0.4)
        ..lineTo(-boss.radius * 2.2, -boss.radius * 1.4 + wingFlap)
        ..lineTo(-boss.radius * 1.8, 0)
        ..lineTo(-boss.radius * 0.3, 0)
        ..close();
      canvas.drawPath(leftWing, wingPaint);

      // Right Wing
      final rightWing = Path()
        ..moveTo(boss.radius * 0.5, -boss.radius * 0.4)
        ..lineTo(boss.radius * 2.2, -boss.radius * 1.4 + wingFlap)
        ..lineTo(boss.radius * 1.8, 0)
        ..lineTo(boss.radius * 0.3, 0)
        ..close();
      canvas.drawPath(rightWing, wingPaint);
    }

    // 4. Heavy Armor Plated Body
    final bodyPaint = Paint()
      ..color = isFlashing ? AppColors.white : AppColors.bossArmor
      ..style = PaintingStyle.fill;
    final armorTrim = Paint()
      ..color = phaseAuraColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(Offset.zero, boss.radius, bodyPaint);
    canvas.drawCircle(Offset.zero, boss.radius, armorTrim);

    // Horns / Crown of Malakor
    final crownPath = Path()
      ..moveTo(-boss.radius * 0.8, -boss.radius * 0.5)
      ..lineTo(-boss.radius * 1.2, -boss.radius * 1.3)
      ..lineTo(-boss.radius * 0.4, -boss.radius * 0.8)
      ..lineTo(0, -boss.radius * 1.5)
      ..lineTo(boss.radius * 0.4, -boss.radius * 0.8)
      ..lineTo(boss.radius * 1.2, -boss.radius * 1.3)
      ..lineTo(boss.radius * 0.8, -boss.radius * 0.5)
      ..close();
    canvas.drawPath(crownPath, bodyPaint);
    canvas.drawPath(crownPath, armorTrim);

    // Glowing Core / Heart of Chaos
    final corePaint = Paint()
      ..color = isFlashing ? AppColors.white : phaseAuraColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(0, 4), 16 + sin(animTime * 8) * 3, corePaint);

    // Glowing Menacing Red Eyes
    final eyePaint = Paint()..color = AppColors.white;
    canvas.drawCircle(const Offset(-16, -14), 6, eyePaint);
    canvas.drawCircle(const Offset(16, -14), 6, eyePaint);
    canvas.drawCircle(const Offset(-16, -14), 3, Paint()..color = AppColors.bossEyeRed);
    canvas.drawCircle(const Offset(16, -14), 3, Paint()..color = AppColors.bossEyeRed);

    // 5. Huge Dread Greatsword
    final swordX = boss.radius * 0.9;
    final swordY = -boss.radius * 0.8 + sin(animTime * 4) * 6;
    final swordPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.white, phaseAuraColor, AppColors.black],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(swordX - 10, swordY - 40, 20, 120));

    final swordPath = Path()
      ..moveTo(swordX, swordY - 45)
      ..lineTo(swordX + 12, swordY + 60)
      ..lineTo(swordX - 12, swordY + 60)
      ..close();
    canvas.drawPath(swordPath, swordPaint);
    canvas.drawPath(swordPath, armorTrim);

    canvas.restore();
  }
}
