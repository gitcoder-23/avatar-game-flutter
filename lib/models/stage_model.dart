import 'package:flutter/material.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/colors.dart';
import 'enemy_model.dart';

class WaveConfig {
  final int waveNumber;
  final List<Map<EnemyType, int>> spawns;
  final String waveTitle;

  WaveConfig({
    required this.waveNumber,
    required this.spawns,
    required this.waveTitle,
  });
}

class StageModel {
  final int id;
  final String name;
  final String subtitle;
  final ElementType element;
  final Color primaryColor;
  final Color secondaryColor;
  final String bgRune;
  final int totalWaves;
  final bool isBoss;
  final int rewardGold;
  final int rewardXp;
  final String description;
  final List<WaveConfig> waves;

  StageModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.element,
    required this.primaryColor,
    required this.secondaryColor,
    required this.bgRune,
    required this.totalWaves,
    required this.isBoss,
    required this.rewardGold,
    required this.rewardXp,
    required this.description,
    required this.waves,
  });

  static StageModel getStageById(int id) {
    switch (id) {
      case 1:
        return StageModel(
          id: 1,
          name: 'Whispering Woods',
          subtitle: 'Corrupted Glade of Shadows',
          element: ElementType.storm,
          primaryColor: AppColors.natureGreen,
          secondaryColor: AppColors.natureDark,
          bgRune: '🍃',
          totalWaves: 3,
          isBoss: false,
          rewardGold: 300,
          rewardXp: 250,
          description: 'Goblins and feral shadow wolves roam the enchanted forest. Cleanse the corruption.',
          waves: [
            WaveConfig(
              waveNumber: 1,
              waveTitle: 'Wave 1: Imp Scouts Encounter',
              spawns: [
                {EnemyType.forestImp: 4},
              ],
            ),
            WaveConfig(
              waveNumber: 2,
              waveTitle: 'Wave 2: Pack of Shadow Wolves',
              spawns: [
                {EnemyType.forestImp: 3},
                {EnemyType.shadowWolf: 3},
              ],
            ),
            WaveConfig(
              waveNumber: 3,
              waveTitle: 'Wave 3: Alpha Ambush',
              spawns: [
                {EnemyType.forestImp: 5},
                {EnemyType.shadowWolf: 4},
              ],
            ),
          ],
        );
      case 2:
        return StageModel(
          id: 2,
          name: 'Blazing Caverns',
          subtitle: 'Infernal Molten Depths',
          element: ElementType.fire,
          primaryColor: AppColors.fireSecondary,
          secondaryColor: AppColors.fireDark,
          bgRune: '🔥',
          totalWaves: 3,
          isBoss: false,
          rewardGold: 500,
          rewardXp: 450,
          description: 'Lava streams flow as Fire Drakes and Magma Golems unleash scorching attacks.',
          waves: [
            WaveConfig(
              waveNumber: 1,
              waveTitle: 'Wave 1: Molten Drakes',
              spawns: [
                {EnemyType.fireDrake: 4},
              ],
            ),
            WaveConfig(
              waveNumber: 2,
              waveTitle: 'Wave 2: Magma Golem March',
              spawns: [
                {EnemyType.fireDrake: 3},
                {EnemyType.magmaGolem: 2},
              ],
            ),
            WaveConfig(
              waveNumber: 3,
              waveTitle: 'Wave 3: Infernal Cataclysm',
              spawns: [
                {EnemyType.fireDrake: 4},
                {EnemyType.magmaGolem: 3},
              ],
            ),
          ],
        );
      case 3:
        return StageModel(
          id: 3,
          name: 'Sunken Frost Temple',
          subtitle: 'Frozen Glacial Sanctuary',
          element: ElementType.frost,
          primaryColor: AppColors.frostPrimary,
          secondaryColor: AppColors.frostDark,
          bgRune: '❄️',
          totalWaves: 3,
          isBoss: false,
          rewardGold: 750,
          rewardXp: 700,
          description: 'Cryo Knights wielding ice halberds guard the ancient frozen elemental fountain.',
          waves: [
            WaveConfig(
              waveNumber: 1,
              waveTitle: 'Wave 1: Frost Wraiths',
              spawns: [
                {EnemyType.frostWraith: 5},
              ],
            ),
            WaveConfig(
              waveNumber: 2,
              waveTitle: 'Wave 2: Cryo Vanguard',
              spawns: [
                {EnemyType.frostWraith: 3},
                {EnemyType.cryoKnight: 2},
              ],
            ),
            WaveConfig(
              waveNumber: 3,
              waveTitle: 'Wave 3: Glacial Phalanx',
              spawns: [
                {EnemyType.frostWraith: 4},
                {EnemyType.cryoKnight: 3},
              ],
            ),
          ],
        );
      case 4:
        return StageModel(
          id: 4,
          name: 'Tempest Peak Citadel',
          subtitle: 'Skyward Thunder Bastion',
          element: ElementType.storm,
          primaryColor: AppColors.stormPrimary,
          secondaryColor: AppColors.stormDark,
          bgRune: '⚡',
          totalWaves: 4,
          isBoss: false,
          rewardGold: 1100,
          rewardXp: 1000,
          description: 'High altitude lightning wardens and thunder harpies strike from the stormy heavens.',
          waves: [
            WaveConfig(
              waveNumber: 1,
              waveTitle: 'Wave 1: Harpy Flight',
              spawns: [
                {EnemyType.stormHarpy: 5},
              ],
            ),
            WaveConfig(
              waveNumber: 2,
              waveTitle: 'Wave 2: Lightning Bastion',
              spawns: [
                {EnemyType.stormHarpy: 4},
                {EnemyType.thunderWarden: 2},
              ],
            ),
            WaveConfig(
              waveNumber: 3,
              waveTitle: 'Wave 3: Thunder Strike Force',
              spawns: [
                {EnemyType.stormHarpy: 5},
                {EnemyType.thunderWarden: 3},
              ],
            ),
            WaveConfig(
              waveNumber: 4,
              waveTitle: 'Wave 4: Tempest Overload',
              spawns: [
                {EnemyType.stormHarpy: 6},
                {EnemyType.thunderWarden: 4},
              ],
            ),
          ],
        );
      case 5:
        return StageModel(
          id: 5,
          name: 'Void Abyss',
          subtitle: 'Nether Rift of Shadows',
          element: ElementType.voidElement,
          primaryColor: AppColors.voidSecondary,
          secondaryColor: AppColors.voidDark,
          bgRune: '🔮',
          totalWaves: 4,
          isBoss: false,
          rewardGold: 1600,
          rewardXp: 1500,
          description: 'Dark archmages warp the fabric of reality with void rifts and phantom illusions.',
          waves: [
            WaveConfig(
              waveNumber: 1,
              waveTitle: 'Wave 1: Shadow Stalkers',
              spawns: [
                {EnemyType.voidStalker: 6},
              ],
            ),
            WaveConfig(
              waveNumber: 2,
              waveTitle: 'Wave 2: Dark Archmage Ritual',
              spawns: [
                {EnemyType.voidStalker: 4},
                {EnemyType.darkArchmage: 2},
              ],
            ),
            WaveConfig(
              waveNumber: 3,
              waveTitle: 'Wave 3: Nether Rift Incursion',
              spawns: [
                {EnemyType.voidStalker: 5},
                {EnemyType.darkArchmage: 3},
              ],
            ),
            WaveConfig(
              waveNumber: 4,
              waveTitle: 'Wave 4: Void Singularity',
              spawns: [
                {EnemyType.voidStalker: 6},
                {EnemyType.darkArchmage: 4},
              ],
            ),
          ],
        );
      case 6:
      default:
        return StageModel(
          id: 6,
          name: 'The Celestial Core',
          subtitle: 'BOSS FIGHT: Malakor, Dread Titan',
          element: ElementType.celestial,
          primaryColor: AppColors.healthRed,
          secondaryColor: AppColors.celestialGold,
          bgRune: '👑',
          totalWaves: 1,
          isBoss: true,
          rewardGold: 5000,
          rewardXp: 5000,
          description: 'The ultimate showdown against the 3-Phase Primordial Dread Titan to save Aethelgard.',
          waves: [
            WaveConfig(
              waveNumber: 1,
              waveTitle: 'FINAL CLASH: TITAN MALAKOR',
              spawns: [
                {EnemyType.dreadTitanBoss: 1},
              ],
            ),
          ],
        );
    }
  }
}
