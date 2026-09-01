import '../utils/function.dart';

class UserModel {
  final int? id;
  final String username;
  final String heroName;
  final int heroLevel;
  final int heroXp;
  final int gold;
  final int crystals;
  final int atkLevel;
  final int hpLevel;
  final int defLevel;
  final int mpLevel;
  final bool tutorialCompleted;
  final bool soundEnabled;
  final bool musicEnabled;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    this.id,
    required this.username,
    this.heroName = 'Avatar Kael',
    this.heroLevel = 1,
    this.heroXp = 0,
    this.gold = 500,
    this.crystals = 50,
    this.atkLevel = 1,
    this.hpLevel = 1,
    this.defLevel = 1,
    this.mpLevel = 1,
    this.tutorialCompleted = false,
    this.soundEnabled = true,
    this.musicEnabled = true,
    required this.createdAt,
    required this.lastLogin,
  });

  int get requiredXpForNextLevel => GameUtils.calculateRequiredXp(heroLevel);

  double get bonusMaxHp => (hpLevel - 1) * 60.0;
  double get bonusMaxMp => (mpLevel - 1) * 30.0;
  double get bonusAtk => (atkLevel - 1) * 12.0;
  double get bonusDef => (defLevel - 1) * 6.0;

  int get upgradeCostHp => hpLevel * 150;
  int get upgradeCostMp => mpLevel * 120;
  int get upgradeCostAtk => atkLevel * 200;
  int get upgradeCostDef => defLevel * 150;

  UserModel copyWith({
    int? id,
    String? username,
    String? heroName,
    int? heroLevel,
    int? heroXp,
    int? gold,
    int? crystals,
    int? atkLevel,
    int? hpLevel,
    int? defLevel,
    int? mpLevel,
    bool? tutorialCompleted,
    bool? soundEnabled,
    bool? musicEnabled,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      heroName: heroName ?? this.heroName,
      heroLevel: heroLevel ?? this.heroLevel,
      heroXp: heroXp ?? this.heroXp,
      gold: gold ?? this.gold,
      crystals: crystals ?? this.crystals,
      atkLevel: atkLevel ?? this.atkLevel,
      hpLevel: hpLevel ?? this.hpLevel,
      defLevel: defLevel ?? this.defLevel,
      mpLevel: mpLevel ?? this.mpLevel,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'hero_name': heroName,
      'hero_level': heroLevel,
      'hero_xp': heroXp,
      'gold': gold,
      'crystals': crystals,
      'atk_level': atkLevel,
      'hp_level': hpLevel,
      'def_level': defLevel,
      'mp_level': mpLevel,
      'tutorial_completed': tutorialCompleted ? 1 : 0,
      'sound_enabled': soundEnabled ? 1 : 0,
      'music_enabled': musicEnabled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      heroName: map['hero_name'] as String? ?? 'Avatar Kael',
      heroLevel: map['hero_level'] as int? ?? 1,
      heroXp: map['hero_xp'] as int? ?? 0,
      gold: map['gold'] as int? ?? 500,
      crystals: map['crystals'] as int? ?? 50,
      atkLevel: map['atk_level'] as int? ?? 1,
      hpLevel: map['hp_level'] as int? ?? 1,
      defLevel: map['def_level'] as int? ?? 1,
      mpLevel: map['mp_level'] as int? ?? 1,
      tutorialCompleted: (map['tutorial_completed'] as int? ?? 0) == 1,
      soundEnabled: (map['sound_enabled'] as int? ?? 1) == 1,
      musicEnabled: (map['music_enabled'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastLogin: DateTime.parse(map['last_login'] as String),
    );
  }
}
