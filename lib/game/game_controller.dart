import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../core/audio/audio_service.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/colors.dart';
import '../models/enemy_model.dart';
import '../models/hero_model.dart';
import '../models/projectile_model.dart';
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
  final ParticleSystem particleSystem = ParticleSystem();

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

  // Joystick Input
  double joystickAngle = 0.0;
  double joystickDistance = 0.0;
  bool isMoving = false;

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
    _ticker.start();
    _startWave(0);
    AudioService.instance.playBgm(stage.name);
  }

  void _startWave(int waveIdx) {
    if (waveIdx >= stage.waves.length) {
      _triggerVictory();
      return;
    }

    currentWaveIndex = waveIdx;
    final wave = stage.waves[waveIdx];
    currentWaveBanner = wave.waveTitle;
    waveTransitionTimer = 2.5;

    // Spawn enemies
    for (var spawnMap in wave.spawns) {
      spawnMap.forEach((enemyType, count) {
        for (int i = 0; i < count; i++) {
          final spawnPos = _getSpawnPosition();
          final enemy = EnemyModel.create(
            type: enemyType,
            x: spawnPos.dx,
            y: spawnPos.dy,
            stageMultiplier: stage.id,
          );
          enemies.add(enemy);
        }
      });
    }

    if (stage.isBoss) {
      AudioService.instance.playBossRoar();
      triggerScreenShake(intensity: 12.0, duration: 0.8);
    }
  }

  Offset _getSpawnPosition() {
    final angle = _random.nextDouble() * 2 * pi;
    final dist = _random.nextDouble() * 300.0 + 260.0;
    final sx = (hero.x + cos(angle) * dist).clamp(100.0, GameConstants.worldWidth - 100.0);
    final sy = (hero.y + sin(angle) * dist).clamp(100.0, GameConstants.worldHeight - 100.0);
    return Offset(sx, sy);
  }

  void _tick(Duration timestamp) {
    if (state != GameState.playing) return;

    if (_lastTime == Duration.zero) {
      _lastTime = timestamp;
      return;
    }

    double dt = (timestamp - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = timestamp;

    dt = dt.clamp(0.001, 0.05);

    _update(dt);
    notifyListeners();
  }

  void _update(double dt) {
    elapsedTime += dt;

    if (screenShakeDuration > 0) {
      screenShakeDuration -= dt;
      if (screenShakeDuration <= 0) {
        screenShakeIntensity = 0;
      }
    }

    if (waveTransitionTimer > 0) {
      waveTransitionTimer -= dt;
    }

    if (comboTimer > 0) {
      comboTimer -= dt;
      if (comboTimer <= 0) {
        comboCount = 0;
      }
    }

    _updateHero(dt);
    cameraX = hero.x;
    cameraY = hero.y;
    particleSystem.update(dt);

    for (int i = floatingTexts.length - 1; i >= 0; i--) {
      floatingTexts[i].update(dt);
      if (floatingTexts[i].isDead) {
        floatingTexts.removeAt(i);
      }
    }

    _updateProjectiles(dt);
    _updateEnemies(dt);

    if (enemies.isEmpty && !isWaveClearing) {
      if (currentWaveIndex + 1 < stage.waves.length) {
        _startWave(currentWaveIndex + 1);
      } else {
        _triggerVictory();
      }
    }

    if (hero.currentHp <= 0 && state == GameState.playing) {
      _triggerDefeat();
    }
  }

  void _updateHero(double dt) {
    hero.update(dt);

    if (isMoving && !hero.isDashing) {
      hero.facingAngle = joystickAngle;
      final moveSpeed = hero.speed * joystickDistance;
      hero.x += cos(joystickAngle) * moveSpeed * dt;
      hero.y += sin(joystickAngle) * moveSpeed * dt;
    }

    hero.x = hero.x.clamp(60.0, GameConstants.worldWidth - 60.0);
    hero.y = hero.y.clamp(60.0, GameConstants.worldHeight - 60.0);
  }

  void _updateProjectiles(double dt) {
    for (int i = projectiles.length - 1; i >= 0; i--) {
      final p = projectiles[i];
      p.update(dt);

      if (p.isPlayerOwned) {
        for (var enemy in enemies) {
          final dist = _getDistance(p.x, p.y, enemy.x, enemy.y);
          if (dist <= p.radius + enemy.radius) {
            _applyDamageToEnemy(enemy, p.damage, isCrit: p.isCrit);
            p.isDead = true;
            particleSystem.spawnSlashSparks(enemy.x, enemy.y, p.color, p.vx.sign);
            break;
          }
        }
      } else {
        final dist = _getDistance(p.x, p.y, hero.x, hero.y);
        if (dist <= p.radius + 20.0) {
          _applyDamageToHero(p.damage);
          p.isDead = true;
          particleSystem.spawnExplosion(hero.x, hero.y, p.color, AppColors.white, 30.0);
        }
      }

      if (p.isDead) {
        projectiles.removeAt(i);
      }
    }
  }

  void _updateEnemies(double dt) {
    for (int i = enemies.length - 1; i >= 0; i--) {
      final enemy = enemies[i];
      enemy.update(dt);

      if (enemy.isDead) {
        _onEnemyDefeated(enemy);
        enemies.removeAt(i);
        continue;
      }

      _runEnemyAI(enemy, dt);
    }
  }

  void _runEnemyAI(EnemyModel enemy, double dt) {
    if (enemy.isFrozen) return;

    final distToHero = _getDistance(enemy.x, enemy.y, hero.x, hero.y);
    final angleToHero = atan2(hero.y - enemy.y, hero.x - enemy.x);

    if (enemy.isBoss) {
      final hpPercent = enemy.currentHp / enemy.maxHp;
      if (hpPercent <= 0.30 && enemy.bossPhase != BossPhase.phase3) {
        enemy.bossPhase = BossPhase.phase3;
        enemy.atk += 40;
        enemy.speed += 30;
        triggerScreenShake(intensity: 15.0, duration: 1.0);
        particleSystem.spawnCelestialBurst(enemy.x, enemy.y);
        floatingTexts.add(FloatingText(
          x: enemy.x,
          y: enemy.y - 60,
          text: 'PHASE 3: APOCALYPSE RIFT!',
          color: AppColors.voidSecondary,
          fontSize: 22,
        ));
      } else if (hpPercent <= 0.65 && enemy.bossPhase == BossPhase.phase1) {
        enemy.bossPhase = BossPhase.phase2;
        enemy.atk += 25;
        triggerScreenShake(intensity: 10.0, duration: 0.6);
        particleSystem.spawnExplosion(enemy.x, enemy.y, AppColors.fireSecondary, AppColors.celestialGold, 120);
        floatingTexts.add(FloatingText(
          x: enemy.x,
          y: enemy.y - 60,
          text: 'PHASE 2: CHAOS ENRAGE!',
          color: AppColors.fireSecondary,
          fontSize: 22,
        ));

        for (int m = 0; m < 3; m++) {
          final mAngle = m * 2 * pi / 3;
          enemies.add(EnemyModel.create(
            type: EnemyType.bossMinion,
            x: enemy.x + cos(mAngle) * 80,
            y: enemy.y + sin(mAngle) * 80,
          ));
        }
      }
    }

    if (enemy.isTelegraphing) {
      if (enemy.telegraphTimer >= enemy.telegraphMaxTime) {
        enemy.isTelegraphing = false;
        enemy.telegraphTimer = 0.0;
        enemy.currentAttackCooldown = enemy.attackCooldown;
        _executeEnemyAttack(enemy);
      }
      return;
    }

    if (distToHero <= enemy.attackRange && enemy.currentAttackCooldown <= 0) {
      enemy.isTelegraphing = true;
      enemy.telegraphTimer = 0.0;
      return;
    }

    if (distToHero > enemy.attackRange * 0.8) {
      enemy.x += cos(angleToHero) * enemy.speed * dt;
      enemy.y += sin(angleToHero) * enemy.speed * dt;
    }

    for (var other in enemies) {
      if (other.id != enemy.id) {
        final d = _getDistance(enemy.x, enemy.y, other.x, other.y);
        if (d < enemy.radius + other.radius && d > 0) {
          final pushAngle = atan2(enemy.y - other.y, enemy.x - other.x);
          enemy.x += cos(pushAngle) * 40 * dt;
          enemy.y += sin(pushAngle) * 40 * dt;
        }
      }
    }
  }

  void _executeEnemyAttack(EnemyModel enemy) {
    final distToHero = _getDistance(enemy.x, enemy.y, hero.x, hero.y);
    final angleToHero = atan2(hero.y - enemy.y, hero.x - enemy.x);

    if (enemy.isBoss) {
      if (enemy.bossPhase == BossPhase.phase3) {
        for (int i = 0; i < 12; i++) {
          final pAngle = i * pi / 6 + elapsedTime;
          projectiles.add(ProjectileModel(
            x: enemy.x,
            y: enemy.y,
            vx: cos(pAngle) * 220,
            vy: sin(pAngle) * 220,
            radius: 12.0,
            damage: enemy.atk * 0.7,
            isPlayerOwned: false,
            element: ElementType.celestial,
            type: ProjectileType.chaosLaser,
            maxLifeTime: 4.0,
            color: AppColors.voidSecondary,
          ));
        }
        triggerScreenShake(intensity: 8.0, duration: 0.4);
      } else {
        if (distToHero <= enemy.attackRange * 1.3) {
          _applyDamageToHero(enemy.atk);
        }
        particleSystem.spawnExplosion(enemy.x, enemy.y, enemy.primaryColor, enemy.glowColor, 100);
        triggerScreenShake(intensity: 6.0, duration: 0.3);
      }
    } else if (enemy.type == EnemyType.fireDrake || enemy.type == EnemyType.darkArchmage || enemy.type == EnemyType.frostWraith) {
      projectiles.add(ProjectileModel(
        x: enemy.x,
        y: enemy.y,
        vx: cos(angleToHero) * 240,
        vy: sin(angleToHero) * 240,
        radius: 10.0,
        damage: enemy.atk,
        isPlayerOwned: false,
        element: enemy.element,
        type: ProjectileType.fireball,
        maxLifeTime: 3.0,
        color: enemy.primaryColor,
      ));
    } else {
      if (distToHero <= enemy.attackRange + 20.0) {
        _applyDamageToHero(enemy.atk);
        particleSystem.spawnSlashSparks(hero.x, hero.y, enemy.primaryColor, angleToHero);
      }
    }
  }

  void _onEnemyDefeated(EnemyModel enemy) {
    totalKills++;
    currentScore += (enemy.xpValue * 10 * (1 + comboCount * 0.1)).toInt();
    hero.addUltimateCharge(enemy.isBoss ? 50.0 : 8.0);

    particleSystem.spawnExplosion(enemy.x, enemy.y, enemy.primaryColor, enemy.glowColor, enemy.radius * 2);
    floatingTexts.add(FloatingText(
      x: enemy.x,
      y: enemy.y,
      text: '+${enemy.xpValue} XP',
      color: AppColors.celestialGold,
      fontSize: 14,
    ));
  }

  void performBasicAttack() {
    if (state != GameState.playing) return;

    hero.isAttacking = true;
    hero.attackTimer = 0.22;
    hero.attackComboIndex = (hero.attackComboIndex + 1) % 3;
    hero.comboResetTimer = 1.0;

    AudioService.instance.playSlash();

    final attackRange = 95.0;
    final attackArc = pi * 0.85;

    bool hitAny = false;
    for (var enemy in enemies) {
      final dist = _getDistance(hero.x, hero.y, enemy.x, enemy.y);
      if (dist <= attackRange + enemy.radius) {
        final angleToEnemy = atan2(enemy.y - hero.y, enemy.x - hero.x);
        final angleDiff = (angleToEnemy - hero.facingAngle).abs() % (2 * pi);
        final normalizedDiff = angleDiff > pi ? 2 * pi - angleDiff : angleDiff;

        if (normalizedDiff <= attackArc / 2) {
          hitAny = true;
          final isCrit = _random.nextDouble() < hero.critChance;
          final damage = hero.atk * (1.0 + hero.attackComboIndex * 0.25) * (isCrit ? hero.critMultiplier : 1.0);
          _applyDamageToEnemy(enemy, damage, isCrit: isCrit);

          enemy.x += cos(hero.facingAngle) * 35.0;
          enemy.y += sin(hero.facingAngle) * 35.0;

          particleSystem.spawnSlashSparks(enemy.x, enemy.y, AppColors.frostPrimary, hero.facingAngle);
        }
      }
    }

    if (hitAny) {
      _incrementCombo();
      hero.addUltimateCharge(3.0);
      triggerScreenShake(intensity: 3.0, duration: 0.12);
    }
  }

  void castSkill(SkillId id) {
    if (state != GameState.playing) return;

    final skill = hero.skills.firstWhere((s) => s.id == id);
    if (!skill.isReady || hero.currentMp < skill.manaCost) return;

    hero.currentMp -= skill.manaCost;
    skill.trigger();

    switch (id) {
      case SkillId.frostNova:
        AudioService.instance.playFrostNova();
        particleSystem.spawnFrostNova(hero.x, hero.y, skill.radius);
        triggerScreenShake(intensity: 6.0, duration: 0.25);

        for (var enemy in enemies) {
          final dist = _getDistance(hero.x, hero.y, enemy.x, enemy.y);
          if (dist <= skill.radius) {
            enemy.freeze(3.2);
            _applyDamageToEnemy(enemy, hero.atk * skill.damageMultiplier);
            floatingTexts.add(FloatingText(
              x: enemy.x,
              y: enemy.y - 30,
              text: 'FROZEN!',
              color: AppColors.frostPrimary,
              fontSize: 16,
            ));
          }
        }
        _incrementCombo(amount: 3);
        break;

      case SkillId.infernoComet:
        AudioService.instance.playInfernoComet();
        final targetX = hero.x + cos(hero.facingAngle) * 140.0;
        final targetY = hero.y + sin(hero.facingAngle) * 140.0;

        particleSystem.spawnExplosion(targetX, targetY, AppColors.fireSecondary, AppColors.celestialGold, skill.radius);
        triggerScreenShake(intensity: 9.0, duration: 0.35);

        for (var enemy in enemies) {
          final dist = _getDistance(targetX, targetY, enemy.x, enemy.y);
          if (dist <= skill.radius) {
            _applyDamageToEnemy(enemy, hero.atk * skill.damageMultiplier, isCrit: true);
            enemy.x += cos(atan2(enemy.y - targetY, enemy.x - targetX)) * 60;
            enemy.y += sin(atan2(enemy.y - targetY, enemy.x - targetX)) * 60;
          }
        }
        _incrementCombo(amount: 4);
        break;

      case SkillId.voidDash:
        AudioService.instance.playVoidDash();
        particleSystem.spawnVoidTrail(hero.x, hero.y);

        hero.isDashing = true;
        hero.dashTimer = 0.25;
        hero.isInvulnerable = true;
        hero.invulnerableTimer = 0.6;

        hero.x += cos(hero.facingAngle) * 200.0;
        hero.y += sin(hero.facingAngle) * 200.0;
        hero.x = hero.x.clamp(60.0, GameConstants.worldWidth - 60.0);
        hero.y = hero.y.clamp(60.0, GameConstants.worldHeight - 60.0);

        particleSystem.spawnVoidTrail(hero.x, hero.y);

        for (var enemy in enemies) {
          final dist = _getDistance(hero.x, hero.y, enemy.x, enemy.y);
          if (dist <= skill.radius) {
            _applyDamageToEnemy(enemy, hero.atk * skill.damageMultiplier);
          }
        }
        break;

      case SkillId.celestialCataclysm:
        castUltimate();
        break;
    }
  }

  void castUltimate() {
    if (state != GameState.playing) return;
    if (hero.ultimateCharge < 100.0) return;

    hero.ultimateCharge = 0.0;
    hero.isCastingUltimate = true;
    hero.ultimateCastTimer = 1.2;
    hero.isInvulnerable = true;
    hero.invulnerableTimer = 2.0;

    AudioService.instance.playUltimate();
    particleSystem.spawnCelestialBurst(hero.x, hero.y);
    triggerScreenShake(intensity: 16.0, duration: 1.0);

    for (var enemy in enemies) {
      final damage = hero.atk * 12.0;
      _applyDamageToEnemy(enemy, damage, isCrit: true);
      particleSystem.spawnSlashSparks(enemy.x, enemy.y, AppColors.celestialGold, _random.nextDouble() * 2 * pi);
    }

    _incrementCombo(amount: 10);
    floatingTexts.add(FloatingText(
      x: hero.x,
      y: hero.y - 70,
      text: 'CELESTIAL CATACLYSM!',
      color: AppColors.celestialGold,
      fontSize: 24,
      isCrit: true,
    ));
  }

  void usePotion() {
    if (hero.usePotion()) {
      floatingTexts.add(FloatingText(
        x: hero.x,
        y: hero.y - 40,
        text: '+HP / +MP RESTORED',
        color: AppColors.potionGreen,
        fontSize: 16,
      ));
      particleSystem.spawnExplosion(hero.x, hero.y, AppColors.potionGreen, AppColors.white, 40);
    }
  }

  void _applyDamageToEnemy(EnemyModel enemy, double damage, {bool isCrit = false}) {
    enemy.takeDamage(damage);
    totalDamageDealt += damage;

    floatingTexts.add(FloatingText(
      x: enemy.x + (_random.nextDouble() - 0.5) * 20,
      y: enemy.y - enemy.radius - 10,
      text: damage.toInt().toString(),
      color: isCrit ? AppColors.criticalYellow : AppColors.white,
      fontSize: isCrit ? 22 : 16,
      isCrit: isCrit,
    ));
  }

  void _applyDamageToHero(double rawDamage) {
    if (hero.isInvulnerable || state != GameState.playing) return;

    final effectiveDamage = max(1.0, rawDamage - hero.def);
    hero.currentHp = max(0.0, hero.currentHp - effectiveDamage);

    hero.isInvulnerable = true;
    hero.invulnerableTimer = 0.4;

    AudioService.instance.playHit();
    triggerScreenShake(intensity: 7.0, duration: 0.2);

    floatingTexts.add(FloatingText(
      x: hero.x + (_random.nextDouble() - 0.5) * 20,
      y: hero.y - 30,
      text: '-${effectiveDamage.toInt()}',
      color: AppColors.healthRed,
      fontSize: 18,
    ));
  }

  void _incrementCombo({int amount = 1}) {
    comboCount += amount;
    comboTimer = 2.8;
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
    isMoving = distance > 0.05;
  }

  void releaseJoystick() {
    isMoving = false;
    joystickDistance = 0.0;
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

  void _triggerVictory() {
    state = GameState.victory;
    _ticker.stop();
    AudioService.instance.playLevelClear();
    onGameOver();
    notifyListeners();
  }

  void _triggerDefeat() {
    state = GameState.defeat;
    _ticker.stop();
    AudioService.instance.playLevelFailed();
    onGameOver();
    notifyListeners();
  }

  double _getDistance(double x1, double y1, double x2, double y2) {
    return GameUtils.getDistance(x1, y1, x2, y2);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
