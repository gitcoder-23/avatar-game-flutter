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
      case EnemyType.impScout:
        // Street Thug Brawler
        canvas.drawCircle(Offset.zero, enemy.radius, bodyPaint);
        canvas.drawCircle(Offset.zero, enemy.radius, glowPaint);
        break;

      case EnemyType.shadowWolf:
        // Cyber Drone
        final dronePath = Path()
          ..moveTo(enemy.radius * 1.2, 0)
          ..lineTo(0, -enemy.radius * 0.8)
          ..lineTo(-enemy.radius * 1.1, 0)
          ..lineTo(0, enemy.radius * 0.8)
          ..close();
        canvas.drawPath(dronePath, bodyPaint);
        canvas.drawPath(dronePath, glowPaint);
        break;

      case EnemyType.fireDrake:
        // Rocket Mercenary
        canvas.drawCircle(Offset.zero, enemy.radius, bodyPaint);
        final wingPath = Path()
          ..moveTo(-10, -enemy.radius)
          ..lineTo(0, -enemy.radius - 14)
          ..lineTo(10, -enemy.radius)
          ..moveTo(-10, enemy.radius)
          ..lineTo(0, enemy.radius + 14)
          ..lineTo(10, enemy.radius);
        canvas.drawPath(wingPath, bodyPaint);
        break;

      case EnemyType.magmaGolem:
        // Heavy Brute Enforcer
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
        // Symbiote Crawler
        final wraithPath = Path()
          ..moveTo(0, -enemy.radius * 1.2)
          ..quadraticBezierTo(enemy.radius * 1.1, 0, 0, enemy.radius * 1.2 + sin(animTime * 6) * 4)
          ..quadraticBezierTo(-enemy.radius * 1.1, 0, 0, -enemy.radius * 1.2);
        canvas.drawPath(wraithPath, bodyPaint);
        canvas.drawPath(wraithPath, glowPaint);
        break;

      case EnemyType.cryoKnight:
        // Symbiote Heavy Mutant
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
        // Oscorp Laser Drone
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
        // Shock Tech Trooper
        canvas.drawCircle(Offset.zero, enemy.radius, bodyPaint);
        canvas.drawCircle(Offset.zero, enemy.radius, glowPaint);
        canvas.drawRect(
          Rect.fromCenter(center: const Offset(14, 0), width: 8, height: enemy.radius * 1.8),
          Paint()..color = AppColors.electricGold,
        );
        break;

      case EnemyType.voidStalker:
        // Symbiote Tendril Fiend
        canvas.drawCircle(Offset.zero, enemy.radius, bodyPaint);
        for (int i = 0; i < 4; i++) {
          final tAngle = i * pi / 2 + animTime * 3;
          final tx = cos(tAngle) * (enemy.radius + 8);
          final ty = sin(tAngle) * (enemy.radius + 8);
          canvas.drawCircle(Offset(tx, ty), 4, glowPaint);
        }
        break;

      case EnemyType.voidArchmage:
        // Oscorp Cyber Commander
        canvas.drawCircle(Offset.zero, enemy.radius, bodyPaint);
        final orbAngle = animTime * 4;
        final ox1 = cos(orbAngle) * (enemy.radius + 14);
        final oy1 = sin(orbAngle) * (enemy.radius + 14);
        final ox2 = cos(orbAngle + pi) * (enemy.radius + 14);
        final oy2 = sin(orbAngle + pi) * (enemy.radius + 14);
        canvas.drawCircle(Offset(ox1, oy1), 6, Paint()..color = AppColors.neonCyan);
        canvas.drawCircle(Offset(ox2, oy2), 6, Paint()..color = AppColors.neonMagenta);
        break;

      case EnemyType.dreadTitanBoss:
        break;
    }

    // Glowing Eyes
    final eyePaint = Paint()..color = isFlashing ? AppColors.black : AppColors.white;
    canvas.drawCircle(Offset(enemy.radius * 0.35, -4), 3, eyePaint);
    canvas.drawCircle(Offset(enemy.radius * 0.35, 4), 3, eyePaint);

    // Web Entangled Overlay
    if (enemy.isFrozen) {
      final webPaint = Paint()
        ..color = AppColors.webWhite
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawCircle(Offset.zero, enemy.radius + 4, webPaint);
      canvas.drawLine(Offset(-enemy.radius, 0), Offset(enemy.radius, 0), webPaint);
      canvas.drawLine(Offset(0, -enemy.radius), Offset(0, enemy.radius), webPaint);
    }

    // Health Bar
    if (!enemy.isBoss) {
      final hpBarWidth = max(36.0, enemy.radius * 1.8);
      const hpBarHeight = 5.0;
      final hpBarY = -enemy.radius - 12.0;

      final bgHp = Paint()..color = AppColors.black78;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(0, hpBarY), width: hpBarWidth + 2, height: hpBarHeight + 2),
          const Radius.circular(2),
        ),
        bgHp,
      );

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
