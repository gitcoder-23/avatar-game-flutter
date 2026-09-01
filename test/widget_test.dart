import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avatar_game/main.dart';
import 'package:avatar_game/models/hero_model.dart';
import 'package:avatar_game/models/user_model.dart';
import 'package:avatar_game/models/enemy_model.dart';
import 'package:avatar_game/models/stage_model.dart';
import 'package:avatar_game/core/constants/game_constants.dart';
import 'package:avatar_game/utils/function.dart';

void main() {
  testWidgets('App smoke test loads AvatarGameApp and transitions from Splash', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.reset());

    await tester.pumpWidget(const AvatarGameApp());
    expect(find.text('A V A T A R'), findsOneWidget);
    expect(find.text('THE ELEMENTAL ODYSSEY'), findsOneWidget);

    // Pump through the 3.2s splash timer
    await tester.pump(const Duration(milliseconds: 3300));
    await tester.pumpAndSettle();

    // Verify Login Screen appears
    expect(find.text('ENTER REALM'), findsOneWidget);
    expect(find.text('WARRIOR LOGIN'), findsOneWidget);
  });

  test('UserModel calculate bonuses and next level XP correctly', () {
    final user = UserModel(
      username: 'test_warrior',
      heroLevel: 3,
      atkLevel: 4,
      hpLevel: 3,
      defLevel: 2,
      mpLevel: 2,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );

    expect(user.requiredXpForNextLevel, 1500);
    expect(user.bonusAtk, 36.0); // (4-1)*12
    expect(user.bonusMaxHp, 120.0); // (3-1)*60
    expect(user.bonusDef, 6.0); // (2-1)*6
    expect(user.bonusMaxMp, 30.0); // (2-1)*30
  });

  test('HeroModel initializes from User and handles cooldowns and healing', () {
    final user = UserModel(
      username: 'hero',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );

    final hero = HeroModel.fromUser(user);
    expect(hero.currentHp, GameConstants.baseHeroHp);
    expect(hero.currentMp, GameConstants.baseHeroMp);
    expect(hero.skills.length, 4);

    // Test healing
    hero.currentHp = 100.0;
    hero.heal(200.0);
    expect(hero.currentHp, 300.0);

    // Test skill cooldowns
    final frost = hero.skills.firstWhere((s) => s.id == SkillId.frostNova);
    frost.trigger();
    expect(frost.isReady, false);
    frost.updateCooldown(5.0);
    expect(frost.isReady, true);
  });

  test('EnemyModel takes damage, freezes, and triggers death state', () {
    final imp = EnemyModel.create(type: EnemyType.forestImp, x: 100, y: 100);
    expect(imp.isDead, false);

    imp.freeze(2.0);
    expect(imp.isFrozen, true);

    imp.takeDamage(500.0);
    expect(imp.isDead, true);
    expect(imp.currentHp, 0.0);
  });

  test('All 6 Stages are configured with valid waves and Stage 6 is Boss', () {
    for (int i = 1; i <= 6; i++) {
      final stage = StageModel.getStageById(i);
      expect(stage.id, i);
      expect(stage.waves.isNotEmpty, true);
      if (i == 6) {
        expect(stage.isBoss, true);
        expect(stage.waves.first.spawns.first.containsKey(EnemyType.dreadTitanBoss), true);
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
