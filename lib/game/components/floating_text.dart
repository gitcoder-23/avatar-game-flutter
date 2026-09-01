import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class FloatingText {
  final String text;
  double x;
  double y;
  final Color color;
  final double fontSize;
  final bool isCritical;
  final bool isComicPop;
  double lifeTimer;
  final double maxLifeTime;

  FloatingText({
    required this.text,
    required this.x,
    required this.y,
    required this.color,
    this.fontSize = 16.0,
    this.isCritical = false,
    this.isComicPop = false,
    this.lifeTimer = 0.8,
    this.maxLifeTime = 0.8,
  });

  bool get isDead => lifeTimer <= 0;

  void update(double dt) {
    lifeTimer -= dt;
    y -= 45.0 * dt; // Float upwards
  }

  void render(Canvas canvas, double screenX, double screenY) {
    final opacity = (lifeTimer / maxLifeTime).clamp(0.0, 1.0);
    final scale = isCritical || isComicPop ? 1.0 + (1.0 - opacity) * 0.4 : 1.0;

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color.withValues(alpha: opacity),
        fontSize: fontSize * scale,
        fontWeight: FontWeight.w900,
        letterSpacing: isComicPop ? 2.0 : 1.0,
        fontFamily: 'Roboto',
        shadows: [
          Shadow(
            color: AppColors.black.withValues(alpha: opacity),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
          if (isCritical || isComicPop)
            Shadow(
              color: color.withValues(alpha: opacity * 0.8),
              blurRadius: 14,
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
      Offset(screenX - textPainter.width / 2, screenY - textPainter.height / 2),
    );
  }
}
