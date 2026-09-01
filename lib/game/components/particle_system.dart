import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../models/particle_model.dart';

class ParticleSystem {
  final List<ParticleModel> particles = [];
  final Random _random = Random();

  void update(double dt) {
    for (int i = particles.length - 1; i >= 0; i--) {
      particles[i].update(dt);
      if (particles[i].isDead) {
        particles.removeAt(i);
      }
    }
  }

  void spawnSlashSparks(double x, double y, Color color, double angle) {
    for (int i = 0; i < 14; i++) {
      final speed = _random.nextDouble() * 260 + 120;
      final spread = (_random.nextDouble() - 0.5) * 1.2;
      final partAngle = angle + spread;
      particles.add(
        ParticleModel(
          x: x,
          y: y,
          vx: cos(partAngle) * speed,
          vy: sin(partAngle) * speed,
          size: _random.nextDouble() * 5 + 3,
          maxLife: 0.35 + _random.nextDouble() * 0.2,
          color: color,
          shape: ParticleShape.spark,
        ),
      );
    }
  }

  void spawnExplosion(double x, double y, Color primaryColor, Color glowColor, double radius) {
    // Ring wave
    particles.add(
      ParticleModel(
        x: x,
        y: y,
        vx: 0,
        vy: 0,
        size: radius,
        maxLife: 0.5,
        color: glowColor,
        shape: ParticleShape.ring,
      ),
    );

    // Embers
    for (int i = 0; i < 28; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = _random.nextDouble() * 320 + 80;
      particles.add(
        ParticleModel(
          x: x,
          y: y,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          size: _random.nextDouble() * 6 + 3,
          maxLife: 0.4 + _random.nextDouble() * 0.4,
          color: _random.nextBool() ? primaryColor : glowColor,
          shape: ParticleShape.circle,
        ),
      );
    }
  }

  void spawnFrostNova(double x, double y, double radius) {
    // Expansion ice ring
    particles.add(
      ParticleModel(
        x: x,
        y: y,
        vx: 0,
        vy: 0,
        size: radius,
        maxLife: 0.6,
        color: AppColors.frostGlow,
        shape: ParticleShape.ring,
      ),
    );

    // Ice shards
    for (int i = 0; i < 24; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = _random.nextDouble() * 240 + 60;
      particles.add(
        ParticleModel(
          x: x,
          y: y,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          size: _random.nextDouble() * 6 + 4,
          maxLife: 0.5 + _random.nextDouble() * 0.3,
          color: AppColors.frostPrimary,
          shape: ParticleShape.star,
          rotation: _random.nextDouble() * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 8,
        ),
      );
    }
  }

  void spawnVoidTrail(double x, double y) {
    for (int i = 0; i < 8; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = _random.nextDouble() * 90 + 20;
      particles.add(
        ParticleModel(
          x: x,
          y: y,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          size: _random.nextDouble() * 8 + 4,
          maxLife: 0.4,
          color: AppColors.voidSecondary,
          shape: ParticleShape.circle,
        ),
      );
    }
  }

  void spawnCelestialBurst(double x, double y) {
    // Expanding starburst rings
    particles.add(
      ParticleModel(
        x: x,
        y: y,
        vx: 0,
        vy: 0,
        size: 380,
        maxLife: 0.8,
        color: AppColors.celestialGold,
        shape: ParticleShape.ring,
      ),
    );
    particles.add(
      ParticleModel(
        x: x,
        y: y,
        vx: 0,
        vy: 0,
        size: 480,
        maxLife: 1.0,
        color: AppColors.frostPrimary,
        shape: ParticleShape.ring,
      ),
    );

    for (int i = 0; i < 60; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = _random.nextDouble() * 450 + 100;
      particles.add(
        ParticleModel(
          x: x,
          y: y,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          size: _random.nextDouble() * 8 + 3,
          maxLife: 0.6 + _random.nextDouble() * 0.5,
          color: _random.nextBool() ? AppColors.celestialGold : AppColors.frostGlow,
          shape: ParticleShape.spark,
          rotation: angle,
        ),
      );
    }
  }

  void render(Canvas canvas, [double cameraX = 0, double cameraY = 0]) {
    final Paint circlePaint = Paint()..style = PaintingStyle.fill;
    final Paint ringPaint = Paint()..style = PaintingStyle.stroke;
    final Paint sparkPaint = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    for (var p in particles) {
      final alpha = (p.lifeProgress * 255).clamp(0, 255).toInt();
      if (alpha <= 0) continue;

      final sx = p.x - cameraX;
      final sy = p.y - cameraY;

      switch (p.shape) {
        case ParticleShape.circle:
          circlePaint.color = p.color.withValues(alpha: alpha / 255);
          canvas.drawCircle(Offset(sx, sy), p.size * p.lifeProgress, circlePaint);
          break;
        case ParticleShape.ring:
          ringPaint.color = p.color.withValues(alpha: alpha / 255);
          ringPaint.strokeWidth = 3.0 * p.lifeProgress;
          final currentRadius = p.size * (1.0 - p.lifeProgress * 0.5);
          canvas.drawCircle(Offset(sx, sy), currentRadius, ringPaint);
          break;
        case ParticleShape.spark:
          sparkPaint.color = p.color.withValues(alpha: alpha / 255);
          sparkPaint.strokeWidth = p.size * 0.6;
          final endX = sx + p.vx * 0.04;
          final endY = sy + p.vy * 0.04;
          canvas.drawLine(Offset(sx, sy), Offset(endX, endY), sparkPaint);
          break;
        case ParticleShape.star:
          circlePaint.color = p.color.withValues(alpha: alpha / 255);
          canvas.save();
          canvas.translate(sx, sy);
          canvas.rotate(p.rotation);
          final rect = Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size);
          canvas.drawRect(rect, circlePaint);
          canvas.restore();
          break;
        case ParticleShape.slash:
          sparkPaint.color = p.color.withValues(alpha: alpha / 255);
          sparkPaint.strokeWidth = 4.0;
          canvas.drawCircle(Offset(sx, sy), p.size, sparkPaint);
          break;
      }
    }
  }

  void clear() {
    particles.clear();
  }
}
