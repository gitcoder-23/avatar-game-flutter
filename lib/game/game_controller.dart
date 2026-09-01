import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../core/audio/audio_service.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/colors.dart';
import '../models/enemy_model.dart';
import '../models/hero_model.dart';
import '../models/projectile_model.dart';
import '../models/skill_model.dart';
import '../models/stage_model.dart';
import '../models/user_model.dart';
import '../utils/function.dart';
import 'components/floating_text.dart';
import 'components/particle_system.dart';

enum GameState {
  playing,
  paused,
  victory,
  defeat,
}

class GameController extends ChangeNotifier {
  final BuildContext context;
  final UserModel user;
  final StageModel stage;
  final VoidCallback onGameOver;

  late Ticker _ticker;
  Duration _lastTime = Duration.zero;

  late HeroModel hero;
  final List<EnemyModel> enemies = [];
  final List<ProjectileModel> projectiles = [];
  final List<FloatingText> floatingTexts = [];
  final ParticleSystem particles = ParticleSystem();

  GameState state = GameState.playing;

  // Wave & Stage Management
  int currentWaveIndex = 0;
  bool isWaveClearing = false;
  double waveTransitionTimer = 0.0;
  String currentWaveBanner = '';

  // Stats & Combat
  int currentScore = 0;
  int comboCount = 0;
  double comboTimer = 0.0;
  int maxCombo = 0;
  int totalKills = 0;
  double totalDamageDealt = 0.0;
  double elapsedTime = 0.0;

  // Camera & Screen Effects
  double cameraX = 0.0;
  double cameraY = 0.0;
  double screenShakeIntensity = 0.0;
  double screenShakeDuration = 0.0;

  // Virtual Joystick State
  double joystickAngle = 0.0;
  double joystickDistance = 0.0;
  bool isJoystickActive = false;

  final Random _random = Random();

  GameController({
    required this.context,
    required this.user,
    required this.stage,
    required this.onGameOver,
    required TickerProvider vsync,
  }) {
    hero = HeroModel.fromUser(user);
    _ticker = vsync.createTicker(_tick);
  }

  void start() {
    state = GameState.playing;
    _lastTime = Duration.zero;
    _startWave(0);
    _ticker.start();
  }

  void pauseGame() {
    if (state == GameState.playing) {
      state = GameState.paused;
      _ticker.stop();
      notifyListeners();
    }
  }

  void resumeGame() {
    if (state == GameState.paused) {
      state = GameState.playing;
      _lastTime = Duration.zero;
      _ticker.start();
      notifyListeners();
    }
  }

  void _tick(Duration timestamp) {
    if (state != GameState.playing) return;

    if (_lastTime == Duration.zero) {
      _lastTime = timestamp;
      return;
    }

    final dt = (timestamp - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = timestamp;

    if (dt > 0.1) return; // Prevent spike delta

    _update(dt);
    notifyListeners();
  }

  void _update(double dt) {
    elapsedTime += dt;

    // 1. Screen Shake Decay
    if (screenShakeDuration > 0) {
      screenShakeDuration -= dt;
      if (screenShakeDuration <= 0) {
        screenShakeIntensity = 0.0;
      }
    }

    // 2. Update Hero Position & Cooldowns
    _updateHero(dt);

    // 3. Update Camera to Track Hero
    _updateCamera();

    // 4. Update Projectiles
    _updateProjectiles(dt);

    // 5. Update Enemies & AI
    _updateEnemies(dt);

    // 6. Update Particle Physics
    particles.update(dt);

    // 7. Update Floating Text
    for (var ft in floatingTexts) {
      ft.update(dt);
    }
    floatingTexts.removeWhere((ft) => ft.isDead);

    // 8. Update Combo Timer
    if (comboCount > 0) {
      comboTimer -= dt;
      if (comboTimer <= 0) {
        comboCount = 0;
      }
    }

    // 9. Wave Transition Timer
    if (waveTransitionTimer > 0) {
      waveTransitionTimer -= dt;
    }

    // 10. Check Wave Completion
    _checkWaveStatus();
  }

  void _updateHero(double dt) {
    hero.updateSkills(dt);

    // Regeneration
    hero.currentMp = (hero.currentMp + 15.0 * dt).clamp(0.0, hero.maxMp);

    // Joystick Movement
    if (isJoystickActive && joystickDistance > 0.1) {
      final moveSpeed = hero.moveSpeed * joystickDistance;
      hero.vx = cos(joystickAngle) * moveSpeed;
      hero.vy = sin(joystickAngle) * moveSpeed;
      hero.facingAngle = joystickAngle;
      hero.isMoving = true;
    } else {
      hero.vx = 0.0;
      hero.vy = 0.0;
      hero.isMoving = false;
    }

    hero.x += hero.vx * dt;
    hero.y += hero.vy * dt;

    // Clamp inside world bounds
    final clamped = GameUtils.clampToWorld(
      hero.x,
      hero.y,
      minX: 60.0,
      maxX: GameConstants.worldWidth - 60.0,
      minY: 60.0,
      maxY: GameConstants.worldHeight - 60.0,
    );
    hero.x = clamped.$1;
    hero.y = clamped.$2;

    if (hero.isInvulnerable) {
      hero.invulnerableTimer -= dt;
      if (hero.invulnerableTimer <= 0) {
        hero.isInvulnerable = false;
      }
    }

    if (hero.isAttacking) {
      hero.attackTimer -= dt;
      if (hero.attackTimer <= 0) {
        hero.isAttacking = false;
      }
    }
  }

  void _updateCamera() {
    final size = MediaQuery.of(context).size;
    double targetCamX = hero.x - size.width / 2;
    double targetCamY = hero.y - size.height / 2;

    if (screenShakeDuration > 0) {
      targetCamX += (_random.nextDouble() * 2 - 1) * screenShakeIntensity;
      targetCamY += (_random.nextDouble() * 2 - 1) * screenShakeIntensity;
    }

    cameraX = targetCamX.clamp(0.0, max(0.0, GameConstants.worldWidth - size.width));
    cameraY = targetCamY.clamp(0.0, max(0.0, GameConstants.worldHeight - size.height));
  }

  void _updateProjectiles(double dt) {
    for (var proj in projectiles) {
      proj.update(dt);

      if (proj.isPlayerOwned) {
        for (var enemy in enemies) {
          final dist = GameUtils.getDistance(proj.x, proj.y, enemy.x, enemy.y);
          if (dist <= proj.radius + enemy.radius) {
            proj.isDead = true;
            _applyDamageToEnemy(enemy, proj.damage);
            particles.spawnSlashSparks(enemy.x, enemy.y, AppColors.webFluidBlue, proj.vx);
            break;
          }
        }
      } else {
        final dist = GameUtils.getDistance(proj.x, proj.y, hero.x, hero.y);
        if (dist <= proj.radius + 24.0) {
          proj.isDead = true;
          _applyDamageToHero(proj.damage);
          particles.spawnSlashSparks(hero.x, hero.y, AppColors.spiderRed, proj.vx);
        }
      }
    }

    projectiles.removeWhere((p) => p.isDead);
  }

  void _updateEnemies(double dt) {
    for (var enemy in enemies) {
      enemy.updateStatus(dt);

      final distToHero = GameUtils.getDistance(enemy.x, enemy.y, hero.x, hero.y);
      final angleToHero = GameUtils.calculateAngle(enemy.x, enemy.y, hero.x, hero.y);
      enemy.facingAngle = angleToHero;

      if (enemy.isFreezed) continue;

      if (distToHero <= enemy.attackRange) {
        if (enemy.currentAttackCooldown <= 0) {
          enemy.currentAttackCooldown = enemy.attackCooldownSeconds;
          _executeEnemyAttack(enemy);
        }
      } else {
        enemy.x += cos(angleToHero) * enemy.moveSpeed * dt;
        enemy.y += sin(angleToHero) * enemy.moveSpeed * dt;
      }

      // Clamp in world
      enemy.x = enemy.x.clamp(60.0, GameConstants.worldWidth - 60.0);
      enemy.y = enemy.y.clamp(60.0, GameConstants.worldHeight - 60.0);
    }

    enemies.removeWhere((e) => e.isDead);
  }

  void _executeEnemyAttack(EnemyModel enemy) {
    final distToHero = GameUtils.getDistance(enemy.x, enemy.y, hero.x, hero.y);

    if (enemy.isBoss) {
      _applyDamageToHero(enemy.atk);
      triggerScreenShake(intensity: 12.0, duration: 0.35);
      particles.spawnExplosion(enemy.x, enemy.y, AppColors.carnageCrimson, AppColors.venomGlow, 80);
    } else if (distToHero <= enemy.attackRange + 25.0) {
      _applyDamageToHero(enemy.atk);
      particles.spawnSlashSparks(hero.x, hero.y, enemy.primaryColor, enemy.facingAngle);
    }
  }

  void performBasicAttack() {
    if (state != GameState.playing) return;

    hero.isAttacking = true;
    hero.attackTimer = 0.2;
    hero.comboResetTimer = GameConstants.comboWindowSeconds;

    AudioService.instance.playSlash();
    GameUtils.hapticMedium();

    final attackRange = GameConstants.basicAttackRange;
    bool hitAny = false;

    for (var enemy in enemies) {
      final dist = GameUtils.getDistance(hero.x, hero.y, enemy.x, enemy.y);
      if (dist <= attackRange + enemy.radius) {
        final angleToEnemy = GameUtils.calculateAngle(hero.x, hero.y, enemy.x, enemy.y);
        final angleDiff = GameUtils.normalizeAngleDifference(angleToEnemy, hero.facingAngle);

        if (angleDiff <= pi * 0.5) {
          hitAny = true;
          final isCrit = GameUtils.rollCritical(hero.critChance, _random);
          final damage = hero.atk * (1.0 + comboCount * 0.1) * (isCrit ? hero.critMultiplier : 1.0);
          _applyDamageToEnemy(enemy, damage, isCrit: isCrit);

          // Knockback
          enemy.x += cos(hero.facingAngle) * 45.0;
          enemy.y += sin(hero.facingAngle) * 45.0;

          // Spawn Comic Words
          final comicWord = GameConstants.comicHitWords[_random.nextInt(GameConstants.comicHitWords.length)];
          floatingTexts.add(FloatingText(
            text: comicWord,
            x: enemy.x,
            y: enemy.y - 35,
            color: isCrit ? AppColors.criticalYellow : AppColors.webFluidBlue,
            fontSize: isCrit ? 22 : 16,
            isComicPop: true,
            isCritical: isCrit,
          ));

          particles.spawnSlashSparks(enemy.x, enemy.y, AppColors.spiderRedLight, hero.facingAngle);
        }
      }
    }

    if (hitAny) {
      _incrementCombo();
      hero.addUltimateCharge(5.0);
      triggerScreenShake(intensity: 4.0, duration: 0.12);
    }
  }

  void castSkill(SkillId id) {
    if (state != GameState.playing) return;

    final skill = hero.skills.firstWhere((s) => s.id == id);
    if (!skill.isReady || hero.currentMp < skill.manaCost) return;

    hero.currentMp -= skill.manaCost;
    skill.trigger();
    GameUtils.hapticHeavy();

    switch (id) {
      case SkillId.frostNova: // Web Net Cluster
        AudioService.instance.playFrostNova();
        particles.spawnFrostNova(hero.x, hero.y, skill.areaOfEffectRadius);
        triggerScreenShake(intensity: 6.0, duration: 0.25);

        for (var enemy in enemies) {
          final dist = GameUtils.getDistance(hero.x, hero.y, enemy.x, enemy.y);
          if (dist <= skill.areaOfEffectRadius) {
            enemy.freeze(3.5);
            _applyDamageToEnemy(enemy, hero.atk * skill.damageMultiplier);
            floatingTexts.add(FloatingText(
              text: 'WEB TRAPPED!',
              x: enemy.x,
              y: enemy.y - 30,
              color: AppColors.webFluidBlue,
              fontSize: 16,
              isComicPop: true,
            ));
          }
        }
        _incrementCombo(amount: 3);
        break;

      case SkillId.infernoComet: // Symbiote Tendril Surge
        AudioService.instance.playInfernoComet();
        particles.spawnExplosion(hero.x, hero.y, AppColors.carnageCrimson, AppColors.venomGlow, skill.areaOfEffectRadius);
        triggerScreenShake(intensity: 9.0, duration: 0.35);

        for (var enemy in enemies) {
          final dist = GameUtils.getDistance(hero.x, hero.y, enemy.x, enemy.y);
          if (dist <= skill.areaOfEffectRadius) {
            _applyDamageToEnemy(enemy, hero.atk * skill.damageMultiplier, isCrit: true);
            enemy.x += cos(GameUtils.calculateAngle(hero.x, hero.y, enemy.x, enemy.y)) * 80;
            enemy.y += sin(GameUtils.calculateAngle(hero.x, hero.y, enemy.x, enemy.y)) * 80;
          }
        }
        floatingTexts.add(FloatingText(
          text: 'SYMBIOTE SPIKE!',
          x: hero.x,
          y: hero.y - 40,
          color: AppColors.carnageCrimson,
          fontSize: 20,
          isComicPop: true,
        ));
        _incrementCombo(amount: 4);
        break;

      case SkillId.voidDash: // Web-Zip Strike
        AudioService.instance.playVoidDash();
        hero.isInvulnerable = true;
        hero.invulnerableTimer = 0.8;

        // Find nearest enemy in front
        EnemyModel? target;
        double nearestDist = 500.0;
        for (var enemy in enemies) {
          final d = GameUtils.getDistance(hero.x, hero.y, enemy.x, enemy.y);
          if (d < nearestDist) {
            nearestDist = d;
            target = enemy;
          }
        }

        if (target != null) {
          hero.x = target.x - cos(hero.facingAngle) * 50;
          hero.y = target.y - sin(hero.facingAngle) * 50;
          _applyDamageToEnemy(target, hero.atk * skill.damageMultiplier * 1.5, isCrit: true);
          target.x += cos(hero.facingAngle) * 90;
          target.y += sin(hero.facingAngle) * 90;
        } else {
          hero.x += cos(hero.facingAngle) * 260.0;
          hero.y += sin(hero.facingAngle) * 260.0;
        }

        particles.spawnVoidTrail(hero.x, hero.y);
        floatingTexts.add(FloatingText(
          text: 'WEB-ZIP SLAM!',
          x: hero.x,
          y: hero.y - 45,
          color: AppColors.spiderRedLight,
          fontSize: 18,
          isComicPop: true,
        ));
        triggerScreenShake(intensity: 7.0, duration: 0.25);
        _incrementCombo(amount: 2);
        break;

      case SkillId.celestialNova:
        castUltimate();
        break;
    }
  }

  void castUltimate() {
    if (state != GameState.playing) return;
    if (hero.ultimateCharge < 100.0) return;

    hero.ultimateCharge = 0.0;
    hero.isInvulnerable = true;
    hero.invulnerableTimer = 2.0;

    AudioService.instance.playUltimate();
    GameUtils.hapticHeavy();
    particles.spawnCelestialBurst(hero.x, hero.y);
    triggerScreenShake(intensity: 18.0, duration: 1.0);

    for (var enemy in enemies) {
      final damage = hero.atk * 10.0;
      _applyDamageToEnemy(enemy, damage, isCrit: true);
      particles.spawnSlashSparks(enemy.x, enemy.y, AppColors.carnageCrimson, _random.nextDouble() * 2 * pi);
    }

    _incrementCombo(amount: 10);
    floatingTexts.add(FloatingText(
      text: 'VENOM CARNAGE APOCALYPSE!',
      x: hero.x,
      y: hero.y - 70,
      color: AppColors.carnageCrimson,
      fontSize: 24,
      isCritical: true,
      isComicPop: true,
    ));
  }

  void usePotion() {
    if (hero.potCount <= 0) return;
    hero.potCount--;
    hero.currentHp = (hero.currentHp + hero.maxHp * 0.5).clamp(0.0, hero.maxHp);
    hero.currentMp = (hero.currentMp + hero.maxMp * 0.5).clamp(0.0, hero.maxMp);

    floatingTexts.add(FloatingText(
      text: '+50% RECOVERY',
      x: hero.x,
      y: hero.y - 30,
      color: AppColors.potionGreen,
      fontSize: 16,
    ));
    GameUtils.hapticLight();
  }

  void _applyDamageToEnemy(EnemyModel enemy, double rawDamage, {bool isCrit = false}) {
    final dmg = GameUtils.calculateMitigatedDamage(rawDamage, enemy.def);
    enemy.takeDamage(dmg);
    totalDamageDealt += dmg;

    floatingTexts.add(FloatingText(
      text: '-${dmg.toInt()}',
      x: enemy.x + (_random.nextDouble() * 20 - 10),
      y: enemy.y - 20,
      color: isCrit ? AppColors.criticalYellow : AppColors.white,
      fontSize: isCrit ? 20 : 14,
      isCritical: isCrit,
    ));

    if (enemy.isDead) {
      _onEnemyDefeated(enemy);
    }
  }

  void _applyDamageToHero(double rawDamage) {
    if (hero.isInvulnerable) return;

    final dmg = GameUtils.calculateMitigatedDamage(rawDamage, hero.def);
    hero.takeDamage(dmg);
    triggerScreenShake(intensity: 5.0, duration: 0.2);
    GameUtils.hapticMedium();

    floatingTexts.add(FloatingText(
      text: '-${dmg.toInt()}',
      x: hero.x,
      y: hero.y - 20,
      color: AppColors.healthRed,
      fontSize: 15,
    ));

    if (hero.isDead) {
      _triggerDefeat();
    }
  }

  void _onEnemyDefeated(EnemyModel enemy) {
    totalKills++;
    currentScore += enemy.scoreValue * (1 + comboCount ~/ 5);
    hero.addUltimateCharge(enemy.isBoss ? 50.0 : 10.0);

    particles.spawnExplosion(enemy.x, enemy.y, enemy.primaryColor, enemy.glowColor, enemy.radius * 2);
  }

  void _incrementCombo({int amount = 1}) {
    comboCount += amount;
    comboTimer = GameConstants.comboWindowSeconds;
    if (comboCount > maxCombo) {
      maxCombo = comboCount;
    }
  }

  void triggerScreenShake({required double intensity, required double duration}) {
    screenShakeIntensity = intensity;
    screenShakeDuration = duration;
  }

  void updateJoystick(double angle, double distance) {
    joystickAngle = angle;
    joystickDistance = distance;
    isJoystickActive = true;
  }

  void releaseJoystick() {
    isJoystickActive = false;
    joystickDistance = 0.0;
  }

  void _startWave(int index) {
    if (index >= stage.waves.length) {
      _triggerVictory();
      return;
    }

    currentWaveIndex = index;
    final wave = stage.waves[index];

    waveTransitionTimer = 2.5;
    currentWaveBanner = stage.isBoss ? 'FINAL BOSS: VENOM' : 'DISTRICT WAVE ${index + 1} / ${stage.totalWaves}';

    for (var spawnMap in wave.spawns) {
      spawnMap.forEach((type, count) {
        for (int i = 0; i < count; i++) {
          final spawnX = 200.0 + _random.nextDouble() * (GameConstants.worldWidth - 400.0);
          final spawnY = 200.0 + _random.nextDouble() * (GameConstants.worldHeight - 400.0);
          final enemy = EnemyModel.createByType(type);
          enemy.x = spawnX;
          enemy.y = spawnY;
          enemies.add(enemy);
        }
      });
    }
  }

  void _checkWaveStatus() {
    if (enemies.isEmpty && !isWaveClearing) {
      if (currentWaveIndex + 1 < stage.waves.length) {
        _startWave(currentWaveIndex + 1);
      } else {
        _triggerVictory();
      }
    }
  }

  void _triggerVictory() {
    state = GameState.victory;
    _ticker.stop();
    AudioService.instance.playVictory();
    onGameOver();
  }

  void _triggerDefeat() {
    state = GameState.defeat;
    _ticker.stop();
    AudioService.instance.playDefeat();
    onGameOver();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
