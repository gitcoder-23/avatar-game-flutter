import 'package:flutter/material.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/colors.dart';

class SkillModel {
  final SkillId id;
  final String name;
  final String description;
  final ElementType element;
  final double cooldownSeconds;
  final double manaCost;
  final double damageMultiplier;
  final double radius;
  final IconData icon;
  final Color color;

  double currentCooldown;

  SkillModel({
    required this.id,
    required this.name,
    required this.description,
    required this.element,
    required this.cooldownSeconds,
    required this.manaCost,
    required this.damageMultiplier,
    required this.radius,
    required this.icon,
    required this.color,
    this.currentCooldown = 0.0,
  });

  bool get isReady => currentCooldown <= 0.0;
  double get cooldownProgress => currentCooldown / cooldownSeconds;

  void updateCooldown(double dt) {
    if (currentCooldown > 0.0) {
      currentCooldown = (currentCooldown - dt).clamp(0.0, cooldownSeconds);
    }
  }

  void trigger() {
    currentCooldown = cooldownSeconds;
  }

  static List<SkillModel> getDefaultSkills() {
    return [
      SkillModel(
        id: SkillId.frostNova,
        name: 'Frost Nova',
        description: 'Blasts glacial energy in a wide circular perimeter, freezing and slowing all nearby foes.',
        element: ElementType.frost,
        cooldownSeconds: 4.5,
        manaCost: 25.0,
        damageMultiplier: 2.2,
        radius: 180.0,
        icon: Icons.ac_unit_rounded,
        color: AppColors.frostPrimary,
      ),
      SkillModel(
        id: SkillId.infernoComet,
        name: 'Inferno Comet',
        description: 'Summons a blazing meteorite that crashes with explosive area-of-effect damage.',
        element: ElementType.fire,
        cooldownSeconds: 6.0,
        manaCost: 40.0,
        damageMultiplier: 4.5,
        radius: 220.0,
        icon: Icons.local_fire_department_rounded,
        color: AppColors.fireSecondary,
      ),
      SkillModel(
        id: SkillId.voidDash,
        name: 'Void Blink',
        description: 'Instantly teleports through space, leaving a void vortex that damages pursuers with invulnerability.',
        element: ElementType.voidElement,
        cooldownSeconds: 3.0,
        manaCost: 15.0,
        damageMultiplier: 1.5,
        radius: 100.0,
        icon: Icons.flash_on_rounded,
        color: AppColors.voidSecondary,
      ),
      SkillModel(
        id: SkillId.celestialCataclysm,
        name: 'Celestial Cataclysm',
        description: 'THE ULTIMATE: Channel all four primal elements to unleash an apocalyptic orbital laser barrage.',
        element: ElementType.celestial,
        cooldownSeconds: 20.0,
        manaCost: 100.0,
        damageMultiplier: 12.0,
        radius: 400.0,
        icon: Icons.auto_awesome_rounded,
        color: AppColors.celestialGold,
      ),
    ];
  }
}
