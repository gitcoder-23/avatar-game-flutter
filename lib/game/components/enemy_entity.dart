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
    final shadowPaint = Paint()..color = AppColors.shadowDeep;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 8), width: enemy.radius * 2.4, height: enemy.radius * 1.5),
      shadowPaint,
    );

    canvas.rotate(enemy.facingAngle);

    // Body Paint
    final bodyPaint = Paint()
      ..color = isFlashing ? AppColors.white : enemy.primaryColor
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = enemy.glowColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Distinct Visual Artwork By Enemy Type
    switch (enemy.type) {
      case EnemyType.impScout:
        // Street Thug (Leather jacket, bandana, weapon)
        canvas.drawCircle(Offset.zero, enemy.radius, bodyPaint);
        canvas.drawCircle(Offset.zero, enemy.radius, glowPaint);
        // Bandana
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: enemy.radius),
          -pi * 0.6,
          pi * 1.2,
          false,
          Paint()..color = AppColors.spiderRedLight..strokeWidth = 4..style = PaintingStyle.stroke,
        );
        // Baseball Bat Weapon
        final batPaint = Paint()..color = AppColors.electricGold..strokeWidth = 4..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(enemy.radius * 0.8, -10), Offset(enemy.radius * 1.5, -20), batPaint);
        break;

      case EnemyType.shadowWolf:
      case EnemyType.stormHarpy:
        // Oscorp Cyber Scout Drone (Metallic frame, 4 spinning cyan rotors, laser sight)
        canvas.drawCircle(Offset.zero, enemy.radius, bodyPaint);
        canvas.drawCircle(Offset.zero, enemy.radius, glowPaint);
        // 4 Spinning Rotors
        final rotorSpeed = animTime * 25.0;
        final rotorPaint = Paint()
          ..color = AppColors.neonCyan.withValues(alpha: 0.8)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;
        for (int i = 0; i < 4; i++) {
          final rAngle = i * (pi / 2) + rotorSpeed;
          final rx = cos(rAngle) * (enemy.radius + 10);
          final ry = sin(rAngle) * (enemy.radius + 10);
          canvas.drawCircle(Offset(rx, ry), 5, rotorPaint);
        }
        // Red Laser Targeting Line
        final laserPaint = Paint()
          ..color = AppColors.healthRed.withValues(alpha: 0.6)
          ..strokeWidth = 1.5;
        canvas.drawLine(const Offset(10, 0), const Offset(140, 0), laserPaint);
        break;

      case EnemyType.fireDrake:
        // Rocket Mercenary (Armored helmet, shoulder rocket launcher)
        canvas.drawCircle(Offset.zero, enemy.radius, bodyPaint);
        canvas.drawRect(
          Rect.fromCenter(center: Offset(enemy.radius * 0.5, -12), width: 18, height: 8),
          Paint()..color = AppColors.black..style = PaintingStyle.fill,
        );
        canvas.drawCircle(Offset(enemy.radius * 0.9, -12), 4, Paint()..color = AppColors.electricGold);
        break;

      case EnemyType.magmaGolem:
      case EnemyType.cryoKnight:
      case EnemyType.thunderWarden:
        // Heavy Brute Enforcer (Hexagonal steel armor plate)
        final brutePath = Path();
        for (int i = 0; i < 6; i++) {
          final angle = i * pi / 3;
          final r = enemy.radius + ((i % 2 == 0) ? 6 : -3);
          final px = cos(angle) * r;
          final py = sin(angle) * r;
          if (i == 0) {
            brutePath.moveTo(px, py);
          } else {
            brutePath.lineTo(px, py);
          }
        }
        brutePath.close();
        canvas.drawPath(brutePath, bodyPaint);
        canvas.drawPath(brutePath, glowPaint);
        break;

      case EnemyType.frostWraith:
      case EnemyType.voidStalker:
        // Symbiote Mutant / Crawler (Alien organic spikes, writhing tendrils)
        canvas.drawCircle(Offset.zero, enemy.radius, bodyPaint);
        for (int i = 0; i < 4; i++) {
          final tAngle = i * (pi / 2) + sin(animTime * 6 + i) * 0.4;
          final tx = cos(tAngle) * (enemy.radius + 12);
          final ty = sin(tAngle) * (enemy.radius + 12);
          canvas.drawCircle(Offset(tx, ty), 5, Paint()..color = enemy.glowColor);
          canvas.drawLine(Offset.zero, Offset(tx, ty), Paint()..color = enemy.primaryColor..strokeWidth = 3);
        }
        break;

      case EnemyType.voidArchmage:
        // Oscorp Cyber Commander
        canvas.drawCircle(Offset.zero, enemy.radius, bodyPaint);
        canvas.drawCircle(Offset.zero, enemy.radius + 6, glowPaint);
        break;

      case EnemyType.dreadTitanBoss:
        // Venom Symbiote Overlord (Giant 52 radius, sharp white spider emblem, grinning fangs, 6 tentacles)
        canvas.drawCircle(Offset.zero, enemy.radius, bodyPaint);
        // Writhing Tentacles
        final tentaclePaint = Paint()
          ..color = AppColors.symbioteBlack
          ..strokeWidth = 6.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        for (int i = 0; i < 6; i++) {
          final bAngle = pi + (i - 2.5) * 0.4;
          final wave = sin(animTime * 6 + i) * 16;
          final tx = cos(bAngle) * (enemy.radius + 28) + wave;
          final ty = sin(bAngle) * (enemy.radius + 28) - wave;
          canvas.drawLine(Offset(cos(bAngle) * enemy.radius, sin(bAngle) * enemy.radius), Offset(tx, ty), tentaclePaint);
        }
        // White Venom Spider Emblem
        final venomEmblem = Paint()..color = AppColors.white..strokeWidth = 3.0..style = PaintingStyle.stroke;
        canvas.drawLine(const Offset(-15, -15), const Offset(15, -25), venomEmblem);
        canvas.drawLine(const Offset(-15, 15), const Offset(15, 25), venomEmblem);
        // Sharp Grinning Teeth Jaw
        final jawPaint = Paint()..color = AppColors.carnageCrimson;
        canvas.drawArc(Rect.fromCircle(center: const Offset(16, 0), radius: 18), -pi * 0.4, pi * 0.8, true, jawPaint);
        final teethPaint = Paint()..color = AppColors.white..strokeWidth = 2.0;
        for (int t = -8; t <= 8; t += 4) {
          canvas.drawLine(Offset(18, t.toDouble()), Offset(26, t.toDouble()), teethPaint);
        }
        break;
    }

    // Glowing Eyes
    final eyePaint = Paint()..color = isFlashing ? AppColors.black : AppColors.white;
    canvas.drawCircle(Offset(enemy.radius * 0.4, -6), 3.5, eyePaint);
    canvas.drawCircle(Offset(enemy.radius * 0.4, 6), 3.5, eyePaint);

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
      final hpBarWidth = max(40.0, enemy.radius * 2.0);
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
