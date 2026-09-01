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
        description: 'Sweep across Queens apartment rooftops, subduing street brawlers and cyber scout drones with swift web combos.',
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
          WaveConfig(
            waveNumber: 3,
            spawns: [
              {EnemyType.impScout: 4, EnemyType.shadowWolf: 3},
            ],
          ),
        ],
      ),

      // Stage 2
      const StageModel(
        id: 2,
        name: 'Manhattan Skyscraper Ridge',
        subtitle: 'Armored Mercenary Ambush',
        description: 'Navigate high-altitude construction steel beams while taking down rocket mercenaries and armored brute enforcers.',
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
              {EnemyType.fireDrake: 3, EnemyType.magmaGolem: 1},
            ],
          ),
          WaveConfig(
            waveNumber: 3,
            spawns: [
              {EnemyType.fireDrake: 4, EnemyType.magmaGolem: 2},
            ],
          ),
        ],
      ),

      // Stage 3
      const StageModel(
        id: 3,
        name: 'Subway Underground Depths',
        subtitle: 'First Symbiote Infestation',
        description: 'Descend into the dark NYC subway tunnels where alien symbiote organisms are transforming subjects into feral mutants.',
        bgRune: '🚇',
        primaryColor: AppColors.symbiotePurple,
        secondaryColor: AppColors.carnageCrimson,
        rewardGold: 850,
        rewardXp: 1200,
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
              {EnemyType.frostWraith: 3, EnemyType.cryoKnight: 1},
            ],
          ),
          WaveConfig(
            waveNumber: 3,
            spawns: [
              {EnemyType.frostWraith: 4, EnemyType.cryoKnight: 2},
            ],
          ),
        ],
      ),

      // Stage 4
      const StageModel(
        id: 4,
        name: 'Oscorp Advanced Tech Labs',
        subtitle: 'Cyber Defense Grid',
        description: 'Infiltrate Oscorp research facilities guarded by lethal laser drones, energy shields, and high-voltage shock troopers.',
        bgRune: '⚡',
        primaryColor: AppColors.neonCyan,
        secondaryColor: AppColors.electricGold,
        rewardGold: 1250,
        rewardXp: 1800,
        waves: [
          WaveConfig(
            waveNumber: 1,
            spawns: [
              {EnemyType.stormHarpy: 3},
            ],
          ),
          WaveConfig(
            waveNumber: 2,
            spawns: [
              {EnemyType.stormHarpy: 3, EnemyType.thunderWarden: 2},
            ],
          ),
          WaveConfig(
            waveNumber: 3,
            spawns: [
              {EnemyType.stormHarpy: 4, EnemyType.thunderWarden: 2},
            ],
          ),
        ],
      ),

      // Stage 5
      const StageModel(
        id: 5,
        name: 'Times Square Catastrophe',
        subtitle: 'Carnage Symbiote Epidemic',
        description: 'Times Square has been overrun by massive symbiote tendrils and cyber commanders preparing for full alien assimilation.',
        bgRune: '🌆',
        primaryColor: AppColors.carnageCrimson,
        secondaryColor: AppColors.symbioteBlack,
        rewardGold: 1800,
        rewardXp: 2600,
        waves: [
          WaveConfig(
            waveNumber: 1,
            spawns: [
              {EnemyType.voidStalker: 3},
            ],
          ),
          WaveConfig(
            waveNumber: 2,
            spawns: [
              {EnemyType.voidStalker: 3, EnemyType.voidArchmage: 2},
            ],
          ),
          WaveConfig(
            waveNumber: 3,
            spawns: [
              {EnemyType.voidStalker: 4, EnemyType.voidArchmage: 2},
            ],
          ),
        ],
      ),

      // Stage 6 (BOSS)
      const StageModel(
        id: 6,
        name: 'Oscorp Tower Apex',
        subtitle: 'VENOM SYMBIOTE OVERLORD',
        description: 'The ultimate rooftop showdown against Venom! Dodge colossal tendril sweeps, avoid sonic shockwaves, and save New York!',
        bgRune: '💀',
        primaryColor: AppColors.bossPhase3,
        secondaryColor: AppColors.bossPrimary,
        rewardGold: 3500,
        rewardXp: 5000,
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
