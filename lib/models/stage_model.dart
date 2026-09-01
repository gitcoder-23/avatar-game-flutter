import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import 'enemy_model.dart';

class WaveConfig {
  final int waveNumber;
  final List<Map<EnemyType, int>> spawns;
  final double delayBetweenSpawnsSeconds;

  const WaveConfig({
    required this.waveNumber,
    required this.spawns,
    this.delayBetweenSpawnsSeconds = 2.0,
  });

  int get totalEnemies {
    int total = 0;
    for (var spawnMap in spawns) {
      for (var count in spawnMap.values) {
        total += count;
      }
    }
    return total;
  }
}

class StageModel {
  final int id;
  final String name;
  final String subtitle;
  final String description;
  final String bgRune;
  final Color primaryColor;
  final Color secondaryColor;
  final List<WaveConfig> waves;
  final int rewardGold;
  final int rewardXp;
  final bool isBoss;

  const StageModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.bgRune,
    required this.primaryColor,
    required this.secondaryColor,
    required this.waves,
    required this.rewardGold,
    required this.rewardXp,
    this.isBoss = false,
  });

  int get totalWaves => waves.length;

  static List<StageModel> getAllStages() {
    return [
      // Stage 1
      const StageModel(
        id: 1,
        name: 'Queens Rooftops',
        subtitle: 'Street Gang Outbreak',
        description: 'Sweep across Queens apartment rooftops, subduing street brawlers and cyber scout drones with swift 3D web combos.',
        bgRune: '🕷️',
        primaryColor: AppColors.spiderBlueLight,
        secondaryColor: AppColors.spiderRed,
        rewardGold: 300,
        rewardXp: 400,
        waves: [
          WaveConfig(
            waveNumber: 1,
            spawns: [
              {EnemyType.impScout: 3},
            ],
          ),
          WaveConfig(
            waveNumber: 2,
            spawns: [
              {EnemyType.impScout: 3, EnemyType.shadowWolf: 2},
            ],
          ),
        ],
      ),

      // Stage 2
      const StageModel(
        id: 2,
        name: 'Manhattan Skyscraper Ridge',
        subtitle: 'Armored Mercenary Ambush',
        description: 'Navigate high-altitude 3D construction skyscrapers while taking down rocket mercenaries and armored brute enforcers.',
        bgRune: '🏗️',
        primaryColor: AppColors.thugYellow,
        secondaryColor: AppColors.mercRed,
        rewardGold: 550,
        rewardXp: 750,
        waves: [
          WaveConfig(
            waveNumber: 1,
            spawns: [
              {EnemyType.fireDrake: 3},
            ],
          ),
          WaveConfig(
            waveNumber: 2,
            spawns: [
              {EnemyType.fireDrake: 3, EnemyType.magmaGolem: 2},
            ],
          ),
        ],
      ),

      // Stage 3 (BOSS: ELECTRO)
      const StageModel(
        id: 3,
        name: 'Times Square Power Grid',
        subtitle: 'BOSS: ELECTRO ⚡',
        description: 'High-voltage showdown above Times Square! Dodge floating electric lightning plasma orbs and high-voltage shockwaves!',
        bgRune: '⚡',
        primaryColor: AppColors.electricGold,
        secondaryColor: AppColors.neonCyan,
        rewardGold: 1000,
        rewardXp: 1500,
        isBoss: true,
        waves: [
          WaveConfig(
            waveNumber: 1,
            spawns: [
              {EnemyType.stormHarpy: 2, EnemyType.thunderWarden: 1},
            ],
          ),
          WaveConfig(
            waveNumber: 2,
            spawns: [
              {EnemyType.stormHarpy: 1, EnemyType.dreadTitanBoss: 1},
            ],
          ),
        ],
      ),

      // Stage 4
      const StageModel(
        id: 4,
        name: 'Financial District Docks',
        subtitle: 'Symbiote Alien Swarm',
        description: 'Alien mutagen has escaped across the harbor! Battle feral symbiote mutants and cyber commanders before they infect the subway.',
        bgRune: '🌊',
        primaryColor: AppColors.symbiotePurple,
        secondaryColor: AppColors.carnageCrimson,
        rewardGold: 1400,
        rewardXp: 2000,
        waves: [
          WaveConfig(
            waveNumber: 1,
            spawns: [
              {EnemyType.frostWraith: 3},
            ],
          ),
          WaveConfig(
            waveNumber: 2,
            spawns: [
              {EnemyType.frostWraith: 3, EnemyType.cryoKnight: 2},
            ],
          ),
        ],
      ),

      // Stage 5 (BOSS: DR. OCTOPUS)
      const StageModel(
        id: 5,
        name: 'Oscorp Tower Lab Apex',
        subtitle: 'BOSS: DR. OCTOPUS 🐙',
        description: 'Infiltrate Dr. Otto Octavius\' lab! Dodge 4 articulated 3D mechanical titanium tentacles, ground smashes, and heavy debris throws!',
        bgRune: '🐙',
        primaryColor: AppColors.neonCyan,
        secondaryColor: AppColors.healthRed,
        rewardGold: 2200,
        rewardXp: 3200,
        isBoss: true,
        waves: [
          WaveConfig(
            waveNumber: 1,
            spawns: [
              {EnemyType.voidStalker: 2, EnemyType.voidArchmage: 1},
            ],
          ),
          WaveConfig(
            waveNumber: 2,
            spawns: [
              {EnemyType.dreadTitanBoss: 1},
            ],
          ),
        ],
      ),

      // Stage 6 (FINAL BOSS: VENOM)
      const StageModel(
        id: 6,
        name: 'Manhattan Apex Cataclysm',
        subtitle: 'FINAL BOSS: VENOM 🕷️🖤',
        description: 'The ultimate 3D rooftop showdown! Dodge colossal writhing symbiote tentacles, avoid sonic screech fissures, and save New York!',
        bgRune: '💀',
        primaryColor: AppColors.bossPhase3,
        secondaryColor: AppColors.bossPrimary,
        rewardGold: 4500,
        rewardXp: 6000,
        isBoss: true,
        waves: [
          WaveConfig(
            waveNumber: 1,
            spawns: [
              {EnemyType.dreadTitanBoss: 1},
            ],
          ),
        ],
      ),
    ];
  }

  static StageModel getStageById(int stageId) {
    final stages = getAllStages();
    return stages.firstWhere(
      (s) => s.id == stageId,
      orElse: () => stages.first,
    );
  }
}
