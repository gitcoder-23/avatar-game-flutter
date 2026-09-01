import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../models/enemy_model.dart';

class EnemyEntity {
  static void render(Canvas canvas, EnemyModel enemy, double animTime) {
    if (enemy.isDead) return;

    // 1. Attack Telegraph Indicator
    if (enemy.isTelegraphing) {
      final progress = (enemy.telegraphTimer / enemy.telegraphMaxTime).clamp(0.0, 1.0);
      final telegraphPaint = Paint()
        ..color = AppColors.healthRed.withValues(alpha: 0.25 + progress * 0.35)
        ..style = PaintingStyle.fill;
      final telegraphBorder = Paint()
        ..color = AppColors.healthRed
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(Offset(enemy.x, enemy.y), enemy.attackRange * progress, telegraphPaint);
      canvas.drawCircle(Offset(enemy.x, enemy.y), enemy.attackRange, telegraphBorder);
    }

    canvas.save();
    canvas.translate(enemy.x, enemy.y);

    // Hit Flash
    final isFlashing = enemy.hitFlashTimer > 0;

    // Shadow
    final shadowPaint = Paint()..color = AppColors.shadowBlack;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 4), width: enemy.radius * 2.2, height: enemy.radius * 1.4),
      shadowPaint,
    );

    // Body Paint
    final bodyPaint = Paint()
      ..color = isFlashing ? AppColors.white : enemy.primaryColor
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = enemy.glowColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Render by type
    switch (enemy.type) {
      case EnemyType.forestImp:
        // Spiky round body with horns
        canvas.drawCircle(Offset.zero, enemy.radius, bodyPaint);
        canvas.drawCircle(Offset.zero, enemy.radius, glowPaint);
        // Horns
        final hornPath = Path()
          ..moveTo(-8, -enemy.radius + 2)
          ..lineTo(-12, -enemy.radius - 8)
          ..lineTo(-4, -enemy.radius + 2)
          ..moveTo(8, -enemy.radius + 2)
          ..lineTo(12, -enemy.radius - 8)
          ..lineTo(4, -enemy.radius + 2);
        canvas.drawPath(hornPath, bodyPaint);
        break;

      case EnemyType.shadowWolf:
        // Feral beast quad
        final wolfPath = Path()
          ..moveTo(enemy.radius * 1.2, 0)
          ..lineTo(0, -enemy.radius * 0.8)
          ..lineTo(-enemy.radius * 1.1, 0)
          ..lineTo(0, enemy.radius * 0.8)
          ..close();
        canvas.drawPath(wolfPath, bodyPaint);
        canvas.drawPath(wolfPath, glowPaint);
        break;

      case EnemyType.fireDrake:
        // Winged serpentine body
        canvas.drawCircle(Offset.zero, enemy.radius, bodyPaint);
        final wingPath = Path()
          ..moveTo(-10, -enemy.radius)
          ..lineTo(0, -enemy.radius - 16 - sin(animTime * 8) * 4)
          ..lineTo(10, -enemy.radius)
          ..moveTo(-10, enemy.radius)
          ..lineTo(0, enemy.radius + 16 + sin(animTime * 8) * 4)
          ..lineTo(10, enemy.radius);
        canvas.drawPath(wingPath, bodyPaint);
        break;

      case EnemyType.magmaGolem:
        // Bulky rocky jagged hexagonal brute
        final golemPath = Path();
        for (int i = 0; i < 6; i++) {
          final angle = i * pi / 3;
          final r = enemy.radius + ((i % 2 == 0) ? 4 : -2);
          final px = cos(angle) * r;
          final py = sin(angle) * r;
          if (i == 0) {
            golemPath.moveTo(px, py);
          } else {
            golemPath.lineTo(px, py);
          }
        }
        golemPath.close();
        canvas.drawPath(golemPath, bodyPaint);
        canvas.drawPath(golemPath, glowPaint);
        break;

      case EnemyType.frostWraith:
        // Floating ethereal ghost form
        final wraithPath = Path()
          ..moveTo(0, -enemy.radius * 1.2)
          ..quadraticBezierTo(enemy.radius * 1.1, 0, 0, enemy.radius * 1.2 + sin(animTime * 6) * 4)
          ..quadraticBezierTo(-enemy.radius * 1.1, 0, 0, -enemy.radius * 1.2);
        canvas.drawPath(wraithPath, bodyPaint);
        canvas.drawPath(wraithPath, glowPaint);
        break;

      case EnemyType.cryoKnight:
        // Shielded armored knight
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: enemy.radius * 1.8, height: enemy.radius * 1.8),
            const Radius.circular(8),
          ),
          bodyPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: enemy.radius * 1.8, height: enemy.radius * 1.8),
            const Radius.circular(8),
          ),
          glowPaint,
        );
        break;

      case EnemyType.stormHarpy:
        // Fast flying avian demon
        final harpyPath = Path()
          ..moveTo(enemy.radius, 0)
          ..lineTo(-enemy.radius, -enemy.radius * 1.4 - sin(animTime * 10) * 6)
          ..lineTo(-enemy.radius * 0.4, 0)
          ..lineTo(-enemy.radius, enemy.radius * 1.4 + sin(animTime * 10) * 6)
          ..close();
        canvas.drawPath(harpyPath, bodyPaint);
        canvas.drawPath(harpyPath, glowPaint);
        break;

      case EnemyType.thunderWarden:
        // Heavy thunder warden with dual shields
        canvas.drawCircle(Offset.zero, enemy.radius, bodyPaint);
        canvas.drawCircle(Offset.zero, enemy.radius, glowPaint);
        canvas.drawRect(
          Rect.fromCenter(center: const Offset(14, 0), width: 8, height: enemy.radius * 1.8),
          Paint()..color = AppColors.celestialGold,
        );
        break;

      case EnemyType.voidStalker:
        // Shadow phantom with tendrils
        canvas.drawCircle(Offset.zero, enemy.radius, bodyPaint);
        for (int i = 0; i < 4; i++) {
          final tAngle = i * pi / 2 + animTime * 3;
          final tx = cos(tAngle) * (enemy.radius + 8 + sin(animTime * 5 + i) * 4);
          final ty = sin(tAngle) * (enemy.radius + 8 + cos(animTime * 5 + i) * 4);
          canvas.drawCircle(Offset(tx, ty), 4, glowPaint);
        }
        break;

      case EnemyType.darkArchmage:
        // Dark hooded robes with revolving void orbs
        canvas.drawCircle(Offset.zero, enemy.radius, bodyPaint);
        final orbAngle = animTime * 4;
        final ox1 = cos(orbAngle) * (enemy.radius + 14);
        final oy1 = sin(orbAngle) * (enemy.radius + 14);
        final ox2 = cos(orbAngle + pi) * (enemy.radius + 14);
        final oy2 = sin(orbAngle + pi) * (enemy.radius + 14);
        canvas.drawCircle(Offset(ox1, oy1), 6, Paint()..color = AppColors.voidGlow);
        canvas.drawCircle(Offset(ox2, oy2), 6, Paint()..color = AppColors.voidGlow);
        break;

      case EnemyType.bossMinion:
        canvas.drawCircle(Offset.zero, enemy.radius, bodyPaint);
        canvas.drawCircle(Offset.zero, enemy.radius * 0.5, Paint()..color = AppColors.black);
        break;

      case EnemyType.dreadTitanBoss:
        break;
    }

    // Glowing Eyes
    final eyePaint = Paint()..color = isFlashing ? AppColors.black : AppColors.white;
    canvas.drawCircle(Offset(enemy.radius * 0.35, -4), 3, eyePaint);
    canvas.drawCircle(Offset(enemy.radius * 0.35, 4), 3, eyePaint);

    // Frozen Ice Block Overlay
    if (enemy.isFrozen) {
      final icePaint = Paint()
        ..color = AppColors.frostGlow.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      final iceBorder = Paint()
        ..color = AppColors.frostPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      final iceRect = Rect.fromCenter(
        center: Offset.zero,
        width: enemy.radius * 2.6,
        height: enemy.radius * 2.6,
      );
      canvas.drawRect(iceRect, icePaint);
      canvas.drawRect(iceRect, iceBorder);
    }

    // Floating Health Bar
    if (!enemy.isBoss) {
      final hpBarWidth = max(36.0, enemy.radius * 1.8);
      const hpBarHeight = 5.0;
      final hpBarY = -enemy.radius - 12.0;

      // Background
      final bgHp = Paint()..color = AppColors.black78;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(0, hpBarY), width: hpBarWidth + 2, height: hpBarHeight + 2),
          const Radius.circular(2),
        ),
        bgHp,
      );

      // Fill
      final hpPercent = (enemy.currentHp / enemy.maxHp).clamp(0.0, 1.0);
      final fillHp = Paint()
        ..color = hpPercent > 0.4 ? AppColors.healthRed : AppColors.healthRedLight;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-hpBarWidth / 2, hpBarY - hpBarHeight / 2, hpBarWidth * hpPercent, hpBarHeight),
          const Radius.circular(2),
        ),
        fillHp,
      );
    }

    canvas.restore();
  }
}
