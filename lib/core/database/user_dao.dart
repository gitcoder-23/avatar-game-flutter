import 'dart:math';
import '../../models/user_model.dart';
import '../../models/stage_progress_model.dart';
import '../../utils/function.dart';
import 'db_helper.dart';

class UserDAO {
  static final UserDAO instance = UserDAO._init();
  UserDAO._init();

  Future<UserModel?> register({
    required String username,
    required String password,
    String heroName = 'Avatar Kael',
  }) async {
    final db = await DBHelper.instance.database;

    final existing = await db.query(
      'users',
      where: 'LOWER(username) = ?',
      whereArgs: [username.trim().toLowerCase()],
    );

    if (existing.isNotEmpty) {
      throw Exception('Username "$username" already taken!');
    }

    final salt = GameUtils.generateSalt();
    final passwordHash = GameUtils.hashPassword(password, salt);
    final now = DateTime.now();

    final userId = await db.insert('users', {
      'username': username.trim(),
      'password_hash': passwordHash,
      'salt': salt,
      'hero_name': heroName,
      'hero_level': 1,
      'hero_xp': 0,
      'gold': 500,
      'crystals': 50,
      'atk_level': 1,
      'hp_level': 1,
      'def_level': 1,
      'mp_level': 1,
      'tutorial_completed': 0,
      'sound_enabled': 1,
      'music_enabled': 1,
      'created_at': now.toIso8601String(),
      'last_login': now.toIso8601String(),
    });

    for (int stageId = 1; stageId <= 6; stageId++) {
      await db.insert('stage_progress', {
        'user_id': userId,
        'stage_id': stageId,
        'stars': 0,
        'high_score': 0,
        'is_unlocked': stageId == 1 ? 1 : 0,
        'is_completed': 0,
        'best_time_seconds': 0,
      });
    }

    return getUserById(userId);
  }

  Future<UserModel?> login({
    required String username,
    required String password,
  }) async {
    final db = await DBHelper.instance.database;

    final result = await db.query(
      'users',
      where: 'LOWER(username) = ?',
      whereArgs: [username.trim().toLowerCase()],
    );

    if (result.isEmpty) {
      throw Exception('Invalid username or password!');
    }

    final userMap = result.first;
    final storedHash = userMap['password_hash'] as String;
    final salt = userMap['salt'] as String;

    final inputHash = GameUtils.hashPassword(password, salt);
    if (storedHash != inputHash) {
      throw Exception('Invalid username or password!');
    }

    final userId = userMap['id'] as int;
    final now = DateTime.now();

    await db.update(
      'users',
      {'last_login': now.toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );

    return getUserById(userId);
  }

  Future<UserModel?> getUserById(int userId) async {
    final db = await DBHelper.instance.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    if (user.id == null) return;
    final db = await DBHelper.instance.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<List<StageProgressModel>> getStageProgress(int userId) async {
    final db = await DBHelper.instance.database;
    final result = await db.query(
      'stage_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'stage_id ASC',
    );

    return result.map((e) => StageProgressModel.fromMap(e)).toList();
  }

  Future<void> updateStageResult({
    required int userId,
    required int stageId,
    required int stars,
    required int score,
    required int timeSeconds,
    required int rewardGold,
    required int rewardXp,
  }) async {
    final db = await DBHelper.instance.database;

    final existing = await db.query(
      'stage_progress',
      where: 'user_id = ? AND stage_id = ?',
      whereArgs: [userId, stageId],
    );

    int prevStars = 0;
    int prevHighScore = 0;
    int prevBestTime = 0;

    if (existing.isNotEmpty) {
      prevStars = existing.first['stars'] as int? ?? 0;
      prevHighScore = existing.first['high_score'] as int? ?? 0;
      prevBestTime = existing.first['best_time_seconds'] as int? ?? 0;
    }

    final newStars = max(prevStars, stars);
    final newHighScore = max(prevHighScore, score);
    final newBestTime = prevBestTime == 0 ? timeSeconds : min(prevBestTime, timeSeconds);

    await db.update(
      'stage_progress',
      {
        'stars': newStars,
        'high_score': newHighScore,
        'is_completed': 1,
        'best_time_seconds': newBestTime,
      },
      where: 'user_id = ? AND stage_id = ?',
      whereArgs: [userId, stageId],
    );

    if (stageId < 6) {
      await db.update(
        'stage_progress',
        {'is_unlocked': 1},
        where: 'user_id = ? AND stage_id = ?',
        whereArgs: [userId, stageId + 1],
      );
    }

    final user = await getUserById(userId);
    if (user != null) {
      int newGold = user.gold + rewardGold;
      int newXp = user.heroXp + rewardXp;
      int newLevel = user.heroLevel;

      while (newXp >= GameUtils.calculateRequiredXp(newLevel)) {
        newXp -= GameUtils.calculateRequiredXp(newLevel);
        newLevel++;
      }

      await updateUser(user.copyWith(
        gold: newGold,
        heroXp: newXp,
        heroLevel: newLevel,
      ));
    }
  }

  Future<void> markTutorialCompleted(int userId) async {
    final db = await DBHelper.instance.database;
    await db.update(
      'users',
      {'tutorial_completed': 1},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
