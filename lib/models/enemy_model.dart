import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/colors.dart';

enum EnemyType {
  // Stage 1
  forestImp,
  shadowWolf,
  // Stage 2
  fireDrake,
  magmaGolem,
  // Stage 3
  frostWraith,
  cryoKnight,
  // Stage 4
  stormHarpy,
  thunderWarden,
  // Stage 5
  voidStalker,
  darkArchmage,
  // Stage 6 Boss
  dreadTitanBoss,
  bossMinion,
}

enum BossPhase {
  phase1, // Titanic Cleaves & Ground Tremors
  phase2, // Enrage Mode, Meteors & Minions
  phase3, // Apocalypse Laser & Bullet Hell
}

class EnemyModel {
  String id;
  String name;
  EnemyType type;
  ElementType element;
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  double maxHp;
  double currentHp;
  double atk;
  double def;
  double speed;
  Color primaryColor;
  Color glowColor;

  // AI & States
  bool isBoss;
  BossPhase bossPhase;
  double attackCooldown;
  double currentAttackCooldown;
  double attackRange;
  bool isTelegraphing;
  double telegraphTimer;
  double telegraphMaxTime;
  double hitFlashTimer;
  bool isFrozen;
  double freezeTimer;

  // Rewards
  int xpValue;
  int goldValue;
  bool isDead;

  EnemyModel({
    required this.id,
    required this.name,
    required this.type,
    required this.element,
    required this.x,
    required this.y,
    this.vx = 0,
    this.vy = 0,
    required this.radius,
    required this.maxHp,
    required this.atk,
    required this.def,
    required this.speed,
    required this.primaryColor,
    required this.glowColor,
    this.isBoss = false,
    this.bossPhase = BossPhase.phase1,
    required this.attackCooldown,
    required this.attackRange,
    this.telegraphMaxTime = 0.6,
    required this.xpValue,
    required this.goldValue,
  })  : currentHp = maxHp,
        currentAttackCooldown = Random().nextDouble() * attackCooldown,
        isTelegraphing = false,
        telegraphTimer = 0.0,
        hitFlashTimer = 0.0,
        isFrozen = false,
        freezeTimer = 0.0,
        isDead = false;

  void takeDamage(double damage) {
    final effectiveDamage = max(1.0, damage - def);
    currentHp = max(0.0, currentHp - effectiveDamage);
    hitFlashTimer = 0.15;
    if (currentHp <= 0) {
      isDead = true;
    }
  }

  void freeze(double duration) {
    isFrozen = true;
    freezeTimer = duration;
  }

  void update(double dt) {
    if (hitFlashTimer > 0) {
      hitFlashTimer -= dt;
    }

    if (isFrozen) {
      freezeTimer -= dt;
      if (freezeTimer <= 0) {
        isFrozen = false;
      }
      return; // Frozen enemies can't move or attack
    }

    if (currentAttackCooldown > 0) {
      currentAttackCooldown -= dt;
    }

    if (isTelegraphing) {
      telegraphTimer += dt;
    }
  }

  static EnemyModel create({
    required EnemyType type,
    required double x,
    required double y,
    int stageMultiplier = 1,
  }) {
    final randId = '${type.name}_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9999)}';
    final mult = 1.0 + (stageMultiplier - 1) * 0.35;

    switch (type) {
      case EnemyType.forestImp:
        return EnemyModel(
          id: randId,
          name: 'Forest Imp',
          type: type,
          element: ElementType.storm,
          x: x,
          y: y,
          radius: 20.0,
          maxHp: 90.0 * mult,
          atk: 14.0 * mult,
          def: 4.0 * mult,
          speed: 130.0,
          primaryColor: AppColors.impGreen,
          glowColor: AppColors.impGlow,
          attackCooldown: 1.8,
          attackRange: 55.0,
          xpValue: 35,
          goldValue: 25,
        );
      case EnemyType.shadowWolf:
        return EnemyModel(
          id: randId,
          name: 'Shadow Wolf',
          type: type,
          element: ElementType.storm,
          x: x,
          y: y,
          radius: 26.0,
          maxHp: 150.0 * mult,
          atk: 22.0 * mult,
          def: 8.0 * mult,
          speed: 180.0,
          primaryColor: AppColors.wolfGreen,
          glowColor: AppColors.wolfGlow,
          attackCooldown: 1.4,
          attackRange: 65.0,
          xpValue: 55,
          goldValue: 40,
        );
      case EnemyType.fireDrake:
        return EnemyModel(
          id: randId,
          name: 'Fire Drake',
          type: type,
          element: ElementType.fire,
          x: x,
          y: y,
          radius: 24.0,
          maxHp: 200.0 * mult,
          atk: 32.0 * mult,
          def: 10.0 * mult,
          speed: 140.0,
          primaryColor: AppColors.drakeOrange,
          glowColor: AppColors.drakeGlow,
          attackCooldown: 2.2,
          attackRange: 160.0,
          xpValue: 80,
          goldValue: 60,
        );
      case EnemyType.magmaGolem:
        return EnemyModel(
          id: randId,
          name: 'Magma Golem',
          type: type,
          element: ElementType.fire,
          x: x,
          y: y,
          radius: 36.0,
          maxHp: 420.0 * mult,
          atk: 45.0 * mult,
          def: 22.0 * mult,
          speed: 80.0,
          primaryColor: AppColors.golemRust,
          glowColor: AppColors.golemGlow,
          attackCooldown: 2.8,
          attackRange: 80.0,
          xpValue: 120,
          goldValue: 90,
        );
      case EnemyType.frostWraith:
        return EnemyModel(
          id: randId,
          name: 'Frost Wraith',
          type: type,
          element: ElementType.frost,
          x: x,
          y: y,
          radius: 24.0,
          maxHp: 260.0 * mult,
          atk: 38.0 * mult,
          def: 12.0 * mult,
          speed: 150.0,
          primaryColor: AppColors.frostPrimary,
          glowColor: AppColors.frostGlow,
          attackCooldown: 2.0,
          attackRange: 180.0,
          xpValue: 110,
          goldValue: 80,
        );
      case EnemyType.cryoKnight:
        return EnemyModel(
          id: randId,
          name: 'Cryo Knight',
          type: type,
          element: ElementType.frost,
          x: x,
          y: y,
          radius: 34.0,
          maxHp: 550.0 * mult,
          atk: 52.0 * mult,
          def: 30.0 * mult,
          speed: 110.0,
          primaryColor: AppColors.knightBlue,
          glowColor: AppColors.knightGlow,
          attackCooldown: 2.2,
          attackRange: 75.0,
          xpValue: 160,
          goldValue: 120,
        );
      case EnemyType.stormHarpy:
        return EnemyModel(
          id: randId,
          name: 'Storm Harpy',
          type: type,
          element: ElementType.storm,
          x: x,
          y: y,
          radius: 26.0,
          maxHp: 380.0 * mult,
          atk: 58.0 * mult,
          def: 16.0 * mult,
          speed: 210.0,
          primaryColor: AppColors.harpyYellow,
          glowColor: AppColors.harpyGlow,
          attackCooldown: 1.6,
          attackRange: 90.0,
          xpValue: 200,
          goldValue: 150,
        );
      case EnemyType.thunderWarden:
        return EnemyModel(
          id: randId,
          name: 'Thunder Warden',
          type: type,
          element: ElementType.storm,
          x: x,
          y: y,
          radius: 38.0,
          maxHp: 800.0 * mult,
          atk: 70.0 * mult,
          def: 38.0 * mult,
          speed: 120.0,
          primaryColor: AppColors.wardenAmber,
          glowColor: AppColors.wardenGlow,
          attackCooldown: 2.4,
          attackRange: 110.0,
          xpValue: 280,
          goldValue: 220,
        );
      case EnemyType.voidStalker:
        return EnemyModel(
          id: randId,
          name: 'Void Stalker',
          type: type,
          element: ElementType.voidElement,
          x: x,
          y: y,
          radius: 28.0,
          maxHp: 650.0 * mult,
          atk: 82.0 * mult,
          def: 24.0 * mult,
          speed: 230.0,
          primaryColor: AppColors.stalkerPurple,
          glowColor: AppColors.voidGlow,
          attackCooldown: 1.3,
          attackRange: 70.0,
          xpValue: 350,
          goldValue: 280,
        );
      case EnemyType.darkArchmage:
        return EnemyModel(
          id: randId,
          name: 'Dark Archmage',
          type: type,
          element: ElementType.voidElement,
          x: x,
          y: y,
          radius: 32.0,
          maxHp: 950.0 * mult,
          atk: 110.0 * mult,
          def: 28.0 * mult,
          speed: 100.0,
          primaryColor: AppColors.archmagePurple,
          glowColor: AppColors.archmageGlow,
          attackCooldown: 2.8,
          attackRange: 240.0,
          xpValue: 500,
          goldValue: 400,
        );
      case EnemyType.bossMinion:
        return EnemyModel(
          id: randId,
          name: 'Chaos Spawn',
          type: type,
          element: ElementType.voidElement,
          x: x,
          y: y,
          radius: 22.0,
          maxHp: 300.0,
          atk: 40.0,
          def: 10.0,
          speed: 160.0,
          primaryColor: AppColors.healthRed,
          glowColor: AppColors.healthRedDim,
          attackCooldown: 1.5,
          attackRange: 60.0,
          xpValue: 80,
          goldValue: 50,
        );
      case EnemyType.dreadTitanBoss:
        return EnemyModel(
          id: 'boss_malakor',
          name: 'Malakor, Dread Titan',
          type: type,
          element: ElementType.celestial,
          x: x,
          y: y,
          radius: 65.0,
          maxHp: 4500.0,
          atk: 135.0,
          def: 45.0,
          speed: 100.0,
          primaryColor: AppColors.bossPrimary,
          glowColor: AppColors.celestialGold,
          isBoss: true,
          bossPhase: BossPhase.phase1,
          attackCooldown: 3.0,
          attackRange: 180.0,
          telegraphMaxTime: 0.9,
          xpValue: 5000,
          goldValue: 5000,
        );
    }
  }
}
