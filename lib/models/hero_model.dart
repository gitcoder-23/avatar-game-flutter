import 'dart:math';
import '../core/constants/game_constants.dart';
import 'skill_model.dart';
import 'user_model.dart';

class HeroModel {
  String name;
  double x;
  double y;
  double vx;
  double vy;
  double facingAngle; // in radians
  double currentHp;
  double maxHp;
  double currentMp;
  double maxMp;
  double atk;
  double def;
  double speed;
  double critChance;
  double critMultiplier;

  // Combat states
  bool isAttacking = false;
  double attackTimer = 0.0;
  int attackComboIndex = 0;
  double comboResetTimer = 0.0;

  bool isMoving = false;
  bool isDashing = false;
  double dashTimer = 0.0;
  bool isInvulnerable = false;
  double invulnerableTimer = 0.0;

  bool isCastingUltimate = false;
  double ultimateCastTimer = 0.0;

  double ultimateCharge = 0.0; // 0.0 to 100.0
  int potCount = 3;

  List<SkillModel> skills;

  HeroModel({
    required this.name,
    this.x = GameConstants.worldWidth / 2,
    this.y = GameConstants.worldHeight / 2,
    this.vx = 0,
    this.vy = 0,
    this.facingAngle = 0.0,
    required this.maxHp,
    required this.currentHp,
    required this.maxMp,
    required this.currentMp,
    required this.atk,
    required this.def,
    required this.speed,
    required this.critChance,
    required this.critMultiplier,
    required this.skills,
  });

  String get heroName => name;
  double get moveSpeed => speed;
  bool get isDead => currentHp <= 0.0;

  factory HeroModel.fromUser(UserModel user) {
    final maxHp = GameConstants.baseHeroHp + user.bonusMaxHp;
    final maxMp = GameConstants.baseHeroMp + user.bonusMaxMp;
    final atk = GameConstants.baseHeroAtk + user.bonusAtk;
    final def = GameConstants.baseHeroDef + user.bonusDef;

    return HeroModel(
      name: user.heroName,
      maxHp: maxHp,
      currentHp: maxHp,
      maxMp: maxMp,
      currentMp: maxMp,
      atk: atk,
      def: def,
      speed: GameConstants.baseHeroSpeed,
      critChance: GameConstants.baseHeroCritChance,
      critMultiplier: GameConstants.baseHeroCritMultiplier,
      skills: SkillModel.getDefaultSkills(),
    );
  }

  void updateSkills(double dt) {
    for (var skill in skills) {
      skill.updateCooldown(dt);
    }
  }

  void update(double dt) {
    // Regenerate MP slowly
    if (currentMp < maxMp) {
      currentMp = min(maxMp, currentMp + 4.0 * dt);
    }

    // Update Skills cooldowns
    updateSkills(dt);

    // Update Attack state
    if (isAttacking) {
      attackTimer -= dt;
      if (attackTimer <= 0) {
        isAttacking = false;
      }
    }

    // Combo reset timer
    if (comboResetTimer > 0) {
      comboResetTimer -= dt;
      if (comboResetTimer <= 0) {
        attackComboIndex = 0;
      }
    }

    // Update Dash
    if (isDashing) {
      dashTimer -= dt;
      if (dashTimer <= 0) {
        isDashing = false;
      }
    }

    // Invulnerability timer
    if (invulnerableTimer > 0) {
      invulnerableTimer -= dt;
      if (invulnerableTimer <= 0) {
        isInvulnerable = false;
      }
    }

    // Ultimate cast timer
    if (isCastingUltimate) {
      ultimateCastTimer -= dt;
      if (ultimateCastTimer <= 0) {
        isCastingUltimate = false;
      }
    }
  }

  void takeDamage(double amount) {
    currentHp = max(0.0, currentHp - amount);
  }

  void heal(double amount) {
    currentHp = min(maxHp, currentHp + amount);
  }

  void restoreMp(double amount) {
    currentMp = min(maxMp, currentMp + amount);
  }

  void addUltimateCharge(double amount) {
    ultimateCharge = min(100.0, ultimateCharge + amount);
  }

  bool usePotion() {
    if (potCount > 0 && (currentHp < maxHp || currentMp < maxMp)) {
      potCount--;
      heal(maxHp * 0.5);
      restoreMp(maxMp * 0.5);
      return true;
    }
    return false;
  }
}
