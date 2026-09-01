import 'package:flutter/material.dart';

class FloatingText {
  double x;
  double y;
  double vy;
  String text;
  Color color;
  double fontSize;
  double maxLife;
  double life;
  bool isCrit;

  FloatingText({
    required this.x,
    required this.y,
    required this.text,
    required this.color,
    this.fontSize = 16.0,
    this.maxLife = 0.8,
    this.vy = -60.0,
    this.isCrit = false,
  }) : life = maxLife;

  bool get isDead => life <= 0;
  double get lifeProgress => (life / maxLife).clamp(0.0, 1.0);

  void update(double dt) {
    y += vy * dt;
    vy *= 0.95;
    life -= dt;
  }
}
