class StageProgressModel {
  final int? id;
  final int userId;
  final int stageId;
  final int stars;
  final int highScore;
  final bool isUnlocked;
  final bool isCompleted;
  final int bestTimeSeconds;

  StageProgressModel({
    this.id,
    required this.userId,
    required this.stageId,
    this.stars = 0,
    this.highScore = 0,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.bestTimeSeconds = 0,
  });

  StageProgressModel copyWith({
    int? id,
    int? userId,
    int? stageId,
    int? stars,
    int? highScore,
    bool? isUnlocked,
    bool? isCompleted,
    int? bestTimeSeconds,
  }) {
    return StageProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stageId: stageId ?? this.stageId,
      stars: stars ?? this.stars,
      highScore: highScore ?? this.highScore,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'stage_id': stageId,
      'stars': stars,
      'high_score': highScore,
      'is_unlocked': isUnlocked ? 1 : 0,
      'is_completed': isCompleted ? 1 : 0,
      'best_time_seconds': bestTimeSeconds,
    };
  }

  factory StageProgressModel.fromMap(Map<String, dynamic> map) {
    return StageProgressModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      stageId: map['stage_id'] as int,
      stars: map['stars'] as int? ?? 0,
      highScore: map['high_score'] as int? ?? 0,
      isUnlocked: (map['is_unlocked'] as int? ?? 0) == 1,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      bestTimeSeconds: map['best_time_seconds'] as int? ?? 0,
    );
  }
}
