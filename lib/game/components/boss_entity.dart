import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../models/enemy_model.dart';

class BossEntity {
  final EnemyModel model;
  double x;
  double y;
  double facingAngle;
  BossPhase bossPhase;
  double phaseTransitionTimer;
  double specialAttackTimer;
  double tentacleAnimTimer;

  BossEntity({
    required this.model,
    this.x = 1200.0,
    this.y = 400.0,
    this.facingAngle = 0.0,
    this.bossPhase = BossPhase.phase1,
    this.phaseTransitionTimer = 0.0,
    this.specialAttackTimer = 5.0,
    this.tentacleAnimTimer = 0.0,
  });

  factory BossEntity.create(double x, double y) {
    return BossEntity(
      model: EnemyModel.createByType(EnemyType.dreadTitanBoss),
      x: x,
      y: y,
    );
  }

  void update(double dt, double heroX, double heroY) {
    model.updateStatus(dt);
    tentacleAnimTimer += dt;

    final dx = heroX - x;
    final dy = heroY - y;
    facingAngle = atan2(dy, dx);

    final hpPercent = model.currentHp / model.maxHp;
    if (hpPercent <= 0.30 && bossPhase != BossPhase.phase3) {
      bossPhase = BossPhase.phase3;
      phaseTransitionTimer = 2.0;
    } else if (hpPercent <= 0.65 && bossPhase == BossPhase.phase1) {
      bossPhase = BossPhase.phase2;
      phaseTransitionTimer = 2.0;
    }

    if (phaseTransitionTimer > 0) {
      phaseTransitionTimer -= dt;
    }

    specialAttackTimer -= dt;
    if (specialAttackTimer <= 0) {
      specialAttackTimer = bossPhase == BossPhase.phase3 ? 4.0 : 6.5;
    }
  }

  void render(Canvas canvas, double screenX, double screenY) {
    canvas.save();
    canvas.translate(screenX, screenY);

    // Giant Shadow
    final shadowPaint = Paint()
      ..color = AppColors.shadowDeep
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 38), width: 110, height: 42),
      shadowPaint,
    );

    canvas.rotate(facingAngle);

    // Symbiote Aura
    Color auraColor;
    switch (bossPhase) {
      case BossPhase.phase1:
        auraColor = AppColors.venomGlow;
        break;
      case BossPhase.phase2:
        auraColor = AppColors.carnageCrimson;
        break;
      case BossPhase.phase3:
        auraColor = AppColors.spiderRedLight;
        break;
    }

    final auraPaint = Paint()
      ..color = auraColor.withValues(alpha: 0.4 + sin(tentacleAnimTimer * 5) * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26);
    canvas.drawCircle(Offset.zero, 64, auraPaint);

    // Writhing Symbiote Tentacles out of Back
    _drawWrithingTentacles(canvas, auraColor);

    // Massive Symbiote Body
    final bodyPaint = Paint()..color = AppColors.symbioteBlack;
    canvas.drawCircle(Offset.zero, 50, bodyPaint);

    // Jagged Venom White Spider Emblem
    final emblemPaint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    _drawVenomSpiderEmblem(canvas, emblemPaint);

    // Roaring Fangs & Symbiote Mouth
    _drawVenomFace(canvas);

    // Phase 2 & 3 Tendril Claws
    if (bossPhase != BossPhase.phase1) {
      final clawPaint = Paint()
        ..color = (bossPhase == BossPhase.phase3 ? AppColors.spiderRed : AppColors.carnageCrimson)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(const Offset(38, -25), const Offset(62, -35), clawPaint);
      canvas.drawLine(const Offset(42, -15), const Offset(68, -18), clawPaint);
      canvas.drawLine(const Offset(38, 25), const Offset(62, 35), clawPaint);
      canvas.drawLine(const Offset(42, 15), const Offset(68, 18), clawPaint);
    }

    // HP Bar over Boss
    final barWidth = 90.0;
    final barHeight = 8.0;
    final hpPercent = (model.currentHp / model.maxHp).clamp(0.0, 1.0);

    final bgBarPaint = Paint()..color = AppColors.black;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, -68), width: barWidth, height: barHeight),
        const Radius.circular(4),
      ),
      bgBarPaint,
    );

    final hpBarPaint = Paint()..color = auraColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-barWidth / 2, -68 - barHeight / 2, barWidth * hpPercent, barHeight),
        const Radius.circular(4),
      ),
      hpBarPaint,
    );

    canvas.restore();
  }

  void _drawWrithingTentacles(Canvas canvas, Color color) {
    final tentaclePaint = Paint()
      ..color = AppColors.symbioteBlack
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final tentacleGlow = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 9.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (int i = 0; i < 6; i++) {
      final baseAngle = pi + (i - 2.5) * 0.45;
      final wave = sin(tentacleAnimTimer * 4 + i) * 22;
      final start = Offset(cos(baseAngle) * 35, sin(baseAngle) * 35);
      final control = Offset(cos(baseAngle) * 75 + wave, sin(baseAngle) * 75 - wave);
      final end = Offset(cos(baseAngle) * 110 - wave, sin(baseAngle) * 110 + wave);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

      canvas.drawPath(path, tentacleGlow);
      canvas.drawPath(path, tentaclePaint);
    }
  }

  void _drawVenomSpiderEmblem(Canvas canvas, Paint paint) {
    // Sharp Jagged Chest Lines
    canvas.drawLine(const Offset(-15, -20), const Offset(15, -30), paint);
    canvas.drawLine(const Offset(-15, 20), const Offset(15, 30), paint);
    canvas.drawLine(const Offset(-20, -10), const Offset(20, -15), paint);
    canvas.drawLine(const Offset(-20, 10), const Offset(20, 15), paint);
  }

  void _drawVenomFace(Canvas canvas) {
    // Jagged Glowing Eyes
    final eyePaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    final rightEye = Path()
      ..moveTo(15, -24)
      ..lineTo(38, -32)
      ..lineTo(30, -12)
      ..close();
    canvas.drawPath(rightEye, eyePaint);

    final leftEye = Path()
      ..moveTo(15, 24)
      ..lineTo(38, 32)
      ..lineTo(30, 12)
      ..close();
    canvas.drawPath(leftEye, eyePaint);

    // Razor-Sharp Teeth Jaw
    final mouthPath = Path()
      ..moveTo(25, -16)
      ..quadraticBezierTo(44, 0, 25, 16)
      ..quadraticBezierTo(32, 0, 25, -16);
    canvas.drawPath(mouthPath, Paint()..color = AppColors.carnageCrimson);

    final teethPaint = Paint()
      ..color = AppColors.venomTeeth
      ..strokeWidth = 2.0;
    for (int t = -12; t <= 12; t += 4) {
      canvas.drawLine(Offset(26, t.toDouble()), Offset(34, t.toDouble()), teethPaint);
    }
  }
}
