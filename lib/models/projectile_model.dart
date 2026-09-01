import 'dart:ui';
import '../core/constants/game_constants.dart';

enum ProjectileType {
  fireball,
  iceShard,
  voidOrb,
  lightningBolt,
  chaosLaser,
  meteorStrike,
  bladeWave,
}

class ProjectileModel {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  double damage;
  bool isCrit;
  bool isPlayerOwned;
  ElementType element;
  ProjectileType type;
  double lifeTime;
  double maxLifeTime;
  Color color;
  bool isDead;
  double aoeRadius;

  ProjectileModel({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.damage,
    this.isCrit = false,
    required this.isPlayerOwned,
    required this.element,
    required this.type,
    required this.maxLifeTime,
    required this.color,
    this.aoeRadius = 0.0,
  })  : lifeTime = maxLifeTime,
        isDead = false;

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    lifeTime -= dt;
    if (lifeTime <= 0) {
      isDead = true;
    }
  }
}
