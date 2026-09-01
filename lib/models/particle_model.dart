import 'dart:ui';

enum ParticleShape {
  circle,
  spark,
  slash,
  ring,
  star,
}

class ParticleModel {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double maxLife;
  double life;
  Color color;
  ParticleShape shape;
  double rotation;
  double rotationSpeed;
  double scaleDecay;

  ParticleModel({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.maxLife,
    required this.color,
    this.shape = ParticleShape.circle,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
    this.scaleDecay = 1.0,
  }) : life = maxLife;

  bool get isDead => life <= 0;
  double get lifeProgress => (life / maxLife).clamp(0.0, 1.0);

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    vx *= 0.96; // drag
    vy *= 0.96;
    rotation += rotationSpeed * dt;
    life -= dt;
  }
}
