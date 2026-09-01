import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avatar_game/main.dart';
import 'package:avatar_game/models/hero_model.dart';
import 'package:avatar_game/models/user_model.dart';
import 'package:avatar_game/models/enemy_model.dart';
import 'package:avatar_game/models/stage_model.dart';
import 'package:avatar_game/game/engine_3d/vector3d.dart';
import 'package:avatar_game/game/engine_3d/camera3d.dart';
import 'package:avatar_game/game/engine_3d/mesh_builder.dart';
import 'package:avatar_game/utils/function.dart';

void main() {
  testWidgets('App smoke test loads SpiderHeroApp and transitions from Splash', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.reset());

    await tester.pumpWidget(const AvatarGameApp());
    expect(find.text('CHRONICLES'), findsOneWidget);
    expect(find.text('SYMBIOTE STRIKE • VENOM APEX'), findsOneWidget);

    // Fast-forward past splash duration (3000ms + 800ms fade)
    await tester.pump(const Duration(milliseconds: 3200));
    await tester.pumpAndSettle();

    // Verify Login Screen appears
    expect(find.text('HERO HEADQUARTERS LOGIN'), findsOneWidget);
    expect(find.text('PATROL NYC'), findsOneWidget);
  });

  test('3D Vector3D and Camera3D calculations', () {
    final v1 = Vector3D(10, 20, 30);
    final v2 = Vector3D(5, 5, 5);

    final vSum = v1 + v2;
    expect(vSum.x, 15.0);
    expect(vSum.y, 25.0);
    expect(vSum.z, 35.0);

    final dot = v1.dot(v2);
    expect(dot, 50.0 + 100.0 + 150.0);

    final rotY = v1.rotateY(pi / 2);
    expect(rotY.x.toStringAsFixed(1), '30.0');

    final camera = Camera3D();
    camera.update(Vector3D.zero(), 0.0, 0.016);
    expect(camera.position.length > 0, true);
  });

  test('3D MeshBuilder generates valid polygonal structures', () {
    final cityPolys = MeshBuilder.buildCityEnvironment(0.0);
    expect(cityPolys.isNotEmpty, true);

    final heroPolys = MeshBuilder.buildSpiderMan3D(
      pos: Vector3D.zero(),
      facingAngle: 0.0,
      isMoving: true,
      isAttacking: true,
      isDashing: true,
      animTime: 0.5,
    );
    expect(heroPolys.isNotEmpty, true);

    // Electro 3D Boss
    final electroPolys = MeshBuilder.buildElectro3D(
      pos: Vector3D.zero(),
      facingAngle: 0.0,
      animTime: 0.5,
    );
    expect(electroPolys.isNotEmpty, true);

    // Dr. Octopus 3D Boss (4 tentacles)
    final docOckPolys = MeshBuilder.buildDrOctopus3D(
      pos: Vector3D.zero(),
      facingAngle: 0.0,
      animTime: 0.5,
    );
    expect(docOckPolys.isNotEmpty, true);

    // Venom 3D Boss
    final venomPolys = MeshBuilder.buildVenom3D(
      pos: Vector3D.zero(),
      facingAngle: 0.0,
      animTime: 0.5,
    );
    expect(venomPolys.isNotEmpty, true);
  });

  test('UserModel calculate bonuses and next level XP correctly', () {
    final now = DateTime.now();
    final user = UserModel(
      username: 'spider_test',
      heroName: 'Spider-Hero',
      heroLevel: 3,
      heroXp: 200,
      gold: 1000,
      crystals: 100,
      atkLevel: 2,
      hpLevel: 2,
      defLevel: 2,
      mpLevel: 2,
      createdAt: now,
      lastLogin: now,
    );

    expect(user.requiredXpForNextLevel, 1500); // 3 * 500
    expect(user.bonusAtk, 12.0);
    expect(user.bonusMaxHp, 60.0);
    expect(user.bonusDef, 6.0);
    expect(user.bonusMaxMp, 30.0);
  });

  test('HeroModel initializes from User and handles cooldowns and healing', () {
    final now = DateTime.now();
    final user = UserModel(
      username: 'spider_test',
      heroName: 'Spider-Hero',
      createdAt: now,
      lastLogin: now,
    );

    final hero = HeroModel.fromUser(user);
    expect(hero.skills.length, 3);
    expect(hero.potCount, 3);

    // Test taking damage
    hero.takeDamage(100.0);
    expect(hero.currentHp, hero.maxHp - 100.0);

    // Test healing
    hero.heal(50.0);
    expect(hero.currentHp, hero.maxHp - 50.0);

    // Test skill trigger & cooldown
    final skill = hero.skills.first;
    expect(skill.isReady, true);
    skill.trigger();
    expect(skill.isReady, false);
    skill.updateCooldown(skill.cooldownSeconds);
    expect(skill.isReady, true);
  });

  test('EnemyModel takes damage, freezes, and triggers death state', () {
    final enemy = EnemyModel.createByType(EnemyType.impScout);
    expect(enemy.isDead, false);

    enemy.freeze(3.0);
    expect(enemy.isFreezed, true);
    enemy.updateStatus(3.5);
    expect(enemy.isFreezed, false);

    enemy.takeDamage(enemy.maxHp + 50);
    expect(enemy.isDead, true);
  });

  test('All 6 Stages are configured with Electro, Dr. Octopus, and Venom Bosses', () {
    for (int i = 1; i <= 6; i++) {
      final stage = StageModel.getStageById(i);
      expect(stage.id, i);
      expect(stage.waves.isNotEmpty, true);
      if (i == 3) {
        expect(stage.isBoss, true);
        expect(stage.subtitle.contains('ELECTRO'), true);
      } else if (i == 5) {
        expect(stage.isBoss, true);
        expect(stage.subtitle.contains('DR. OCTOPUS'), true);
      } else if (i == 6) {
        expect(stage.isBoss, true);
        expect(stage.subtitle.contains('VENOM'), true);
      }
    }
  });

  test('GameUtils functions perform correct calculations and formatting', () {
    // Distance
    expect(GameUtils.getDistance(0, 0, 3, 4), 5.0);

    // Damage mitigation
    expect(GameUtils.calculateMitigatedDamage(100.0, 30.0), 70.0);
    expect(GameUtils.calculateMitigatedDamage(10.0, 50.0), 1.0);

    // Duration formatting
    expect(GameUtils.formatDuration(75), '01:15');
    expect(GameUtils.formatDuration(360), '06:00');

    // Number formatting
    expect(GameUtils.formatNumber(1500000), '1,500,000');
    expect(GameUtils.formatCompactNumber(1250), '1.3k');
    expect(GameUtils.formatCompactNumber(2500000), '2.5M');

    // Password hashing
    final salt = GameUtils.generateSalt();
    final hash1 = GameUtils.hashPassword('secret', salt);
    final hash2 = GameUtils.hashPassword('secret', salt);
    expect(hash1, hash2);

    // Star calculation
    expect(GameUtils.calculateStars(isVictory: true, hpPercent: 0.8, timeSeconds: 60), 3);
    expect(GameUtils.calculateStars(isVictory: true, hpPercent: 0.3, timeSeconds: 150), 1);
    expect(GameUtils.calculateStars(isVictory: false, hpPercent: 0.9, timeSeconds: 30), 0);
  });
}
