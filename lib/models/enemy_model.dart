import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

enum EnemyType {
  // Stage 1
  impScout,       // Street Thug (Brawler)
  shadowWolf,     // Cyber Scout Drone

  // Stage 2
  fireDrake,      // Rocket Mercenary
  magmaGolem,     // Heavy Brute Enforcer

  // Stage 3
  frostWraith,    // Symbiote Crawler
  cryoKnight,     // Symbiote Heavy Mutant

  // Stage 4
  stormHarpy,     // Oscorp Laser Drone
  thunderWarden,  // Shock Tech Trooper

  // Stage 5
  voidStalker,    // Symbiote Tendril Fiend
  voidArchmage,   // Oscorp Cyber Commander

  // Stage 6 (BOSS)
  dreadTitanBoss, // Venom / Carnage Symbiote Overlord
}

enum BossPhase {
  phase1, // Symbiote Great Slashes & Ground Tentacles
  phase2, // Carnage Symbiote Rage & Spikes
  phase3, // Apocalypse Tendril Storm & Sonic Shriek
}

class EnemyModel {
  final EnemyType type;
  final String name;
  final double maxHp;
  final double atk;
  final double def;
  final double moveSpeed;
  final double attackRange;
  final double attackCooldownSeconds;
  final Color primaryColor;
  final Color glowColor;
  final double radius;
  final bool isBoss;
  final int scoreValue;

  double x;
  double y;
  double facingAngle;
  double currentHp;
  double currentAttackCooldown;
  bool isFreezed;
  double freezeTimer;

  bool isTelegraphing;
  double telegraphTimer;
  double telegraphMaxTime;
  double hitFlashTimer;
  BossPhase bossPhase;

  EnemyModel({
    required this.type,
    required this.name,
    required this.maxHp,
    required this.atk,
    required this.def,
    required this.moveSpeed,
    required this.attackRange,
    required this.attackCooldownSeconds,
    required this.primaryColor,
    required this.glowColor,
    required this.radius,
    this.isBoss = false,
    this.scoreValue = 100,
    this.x = 1200.0,
    this.y = 800.0,
    this.facingAngle = 0.0,
    double? currentHp,
    this.currentAttackCooldown = 0.0,
    this.isFreezed = false,
    this.freezeTimer = 0.0,
    this.isTelegraphing = false,
    this.telegraphTimer = 0.0,
    this.telegraphMaxTime = 0.6,
    this.hitFlashTimer = 0.0,
    this.bossPhase = BossPhase.phase1,
  }) : currentHp = currentHp ?? maxHp;

  bool get isDead => currentHp <= 0;
  bool get isFrozen => isFreezed;
  double get speed => moveSpeed;
  double get attackCooldown => attackCooldownSeconds;
  int get xpValue => scoreValue;

  void takeDamage(double damage) {
    currentHp = (currentHp - damage).clamp(0.0, maxHp);
    hitFlashTimer = 0.15;
  }

  void freeze(double duration) {
    isFreezed = true;
    freezeTimer = duration;
  }

  void updateStatus(double dt) {
    if (hitFlashTimer > 0) {
      hitFlashTimer -= dt;
    }
    if (isFreezed) {
      freezeTimer -= dt;
      if (freezeTimer <= 0) {
        isFreezed = false;
        freezeTimer = 0.0;
      }
    }
    if (currentAttackCooldown > 0) {
      currentAttackCooldown = (currentAttackCooldown - dt).clamp(0.0, attackCooldownSeconds);
    }
  }

  void render(Canvas canvas, double screenX, double screenY) {
    canvas.save();
    canvas.translate(screenX, screenY);
    canvas.rotate(facingAngle);

    final auraPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset.zero, radius + 8, auraPaint);

    final bodyPaint = Paint()..color = (hitFlashTimer > 0) ? AppColors.white : primaryColor;
    canvas.drawCircle(Offset.zero, radius, bodyPaint);

    // Glowing Eyes
    final eyePaint = Paint()..color = AppColors.white;
    canvas.drawCircle(const Offset(8, -5), 3, eyePaint);
    canvas.drawCircle(const Offset(8, 5), 3, eyePaint);

    if (isFreezed) {
      final webWrapPaint = Paint()
        ..color = AppColors.webWhite
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset.zero, radius + 2, webWrapPaint);
      canvas.drawLine(Offset(-radius, 0), Offset(radius, 0), webWrapPaint);
    }

    canvas.restore();
  }

  static EnemyModel createByType(EnemyType type, {double statMultiplier = 1.0}) {
    switch (type) {
      case EnemyType.impScout:
        return EnemyModel(
          type: type,
          name: 'Street Thug',
          maxHp: 160 * statMultiplier,
          atk: 22 * statMultiplier,
          def: 6 * statMultiplier,
          moveSpeed: 140,
          attackRange: 40,
          attackCooldownSeconds: 1.5,
          primaryColor: AppColors.thugYellow,
          glowColor: AppColors.thugGlow,
          radius: 18,
          scoreValue: 120,
        );
      case EnemyType.shadowWolf:
        return EnemyModel(
          type: type,
          name: 'Cyber Scout Drone',
          maxHp: 190 * statMultiplier,
          atk: 28 * statMultiplier,
          def: 8 * statMultiplier,
          moveSpeed: 190,
          attackRange: 45,
          attackCooldownSeconds: 1.3,
          primaryColor: AppColors.droneCyan,
          glowColor: AppColors.droneGlow,
          radius: 20,
          scoreValue: 150,
        );
      case EnemyType.fireDrake:
        return EnemyModel(
          type: type,
          name: 'Rocket Mercenary',
          maxHp: 280 * statMultiplier,
          atk: 38 * statMultiplier,
          def: 12 * statMultiplier,
          moveSpeed: 130,
          attackRange: 60,
          attackCooldownSeconds: 1.6,
          primaryColor: AppColors.mercRed,
          glowColor: AppColors.mercGlow,
          radius: 22,
          scoreValue: 220,
        );
      case EnemyType.magmaGolem:
        return EnemyModel(
          type: type,
          name: 'Heavy Brute Enforcer',
          maxHp: 460 * statMultiplier,
          atk: 45 * statMultiplier,
          def: 24 * statMultiplier,
          moveSpeed: 85,
          attackRange: 55,
          attackCooldownSeconds: 2.2,
          primaryColor: AppColors.mechOrange,
          glowColor: AppColors.electricGold,
          radius: 30,
          scoreValue: 350,
        );
      case EnemyType.frostWraith:
        return EnemyModel(
          type: type,
          name: 'Symbiote Crawler',
          maxHp: 320 * statMultiplier,
          atk: 42 * statMultiplier,
          def: 14 * statMultiplier,
          moveSpeed: 175,
          attackRange: 50,
          attackCooldownSeconds: 1.4,
          primaryColor: AppColors.symbiotePurple,
          glowColor: AppColors.venomGlow,
          radius: 22,
          scoreValue: 280,
        );
      case EnemyType.cryoKnight:
        return EnemyModel(
          type: type,
          name: 'Symbiote Heavy Mutant',
          maxHp: 520 * statMultiplier,
          atk: 50 * statMultiplier,
          def: 26 * statMultiplier,
          moveSpeed: 110,
          attackRange: 60,
          attackCooldownSeconds: 2.0,
          primaryColor: AppColors.carnageCrimson,
          glowColor: AppColors.carnageGlow,
          radius: 28,
          scoreValue: 400,
        );
      case EnemyType.stormHarpy:
        return EnemyModel(
          type: type,
          name: 'Oscorp Laser Drone',
          maxHp: 360 * statMultiplier,
          atk: 48 * statMultiplier,
          def: 16 * statMultiplier,
          moveSpeed: 210,
          attackRange: 65,
          attackCooldownSeconds: 1.2,
          primaryColor: AppColors.neonCyan,
          glowColor: AppColors.droneGlow,
          radius: 22,
          scoreValue: 320,
        );
      case EnemyType.thunderWarden:
        return EnemyModel(
          type: type,
          name: 'Shock Tech Trooper',
          maxHp: 580 * statMultiplier,
          atk: 56 * statMultiplier,
          def: 30 * statMultiplier,
          moveSpeed: 125,
          attackRange: 55,
          attackCooldownSeconds: 1.8,
          primaryColor: AppColors.electricGold,
          glowColor: AppColors.thugGlow,
          radius: 28,
          scoreValue: 450,
        );
      case EnemyType.voidStalker:
        return EnemyModel(
          type: type,
          name: 'Symbiote Tendril Fiend',
          maxHp: 440 * statMultiplier,
          atk: 60 * statMultiplier,
          def: 22 * statMultiplier,
          moveSpeed: 195,
          attackRange: 60,
          attackCooldownSeconds: 1.3,
          primaryColor: AppColors.symbiotePurple,
          glowColor: AppColors.carnageCrimson,
          radius: 25,
          scoreValue: 500,
        );
      case EnemyType.voidArchmage:
        return EnemyModel(
          type: type,
          name: 'Oscorp Cyber Commander',
          maxHp: 650 * statMultiplier,
          atk: 68 * statMultiplier,
          def: 28 * statMultiplier,
          moveSpeed: 140,
          attackRange: 80,
          attackCooldownSeconds: 1.7,
          primaryColor: AppColors.neonMagenta,
          glowColor: AppColors.neonCyan,
          radius: 27,
          scoreValue: 650,
        );
      case EnemyType.dreadTitanBoss:
        return EnemyModel(
          type: type,
          name: 'Venom Symbiote Overlord',
          maxHp: 2800 * statMultiplier,
          atk: 85 * statMultiplier,
          def: 45 * statMultiplier,
          moveSpeed: 145,
          attackRange: 120,
          attackCooldownSeconds: 1.6,
          primaryColor: AppColors.symbioteBlack,
          glowColor: AppColors.venomGlow,
          radius: 52,
          isBoss: true,
          scoreValue: 5000,
        );
    }
  }
}
