import 'package:flutter/material.dart';
import '../core/constants/game_constants.dart';
import '../core/theme/colors.dart';

enum SkillId {
  frostNova,     // Web Net Cluster (Entangle / Stun)
  infernoComet,  // Symbiote Tendril Spike (Radial Burst)
  voidDash,      // Web-Zip Strike (Grapple Pull / Invulnerability)
  celestialNova, // Venom Carnage Cataclysm (Ultimate)
}

class SkillModel {
  final SkillId id;
  final String name;
  final String description;
  final IconData icon;
  final double manaCost;
  final double cooldownSeconds;
  final double damageMultiplier;
  final double areaOfEffectRadius;
  final ElementType element;
  final Color color;

  double currentCooldown;

  SkillModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.manaCost,
    required this.cooldownSeconds,
    required this.damageMultiplier,
    required this.areaOfEffectRadius,
    required this.element,
    required this.color,
    this.currentCooldown = 0.0,
  });

  bool get isReady => currentCooldown <= 0.0;

  double get cooldownProgress => (currentCooldown / cooldownSeconds).clamp(0.0, 1.0);

  void trigger() {
    currentCooldown = cooldownSeconds;
  }

  void updateCooldown(double dt) {
    if (currentCooldown > 0) {
      currentCooldown = (currentCooldown - dt).clamp(0.0, cooldownSeconds);
    }
  }

  void reset() {
    currentCooldown = 0.0;
  }

  static List<SkillModel> getDefaultSkills() {
    return [
      SkillModel(
        id: SkillId.frostNova,
        name: 'Web Net Cluster',
        description: 'Fires high-tensile sticky spider webbing in a 360° radius, trapping and immobilizing all nearby enemies for 3.5s.',
        icon: Icons.grain_rounded,
        manaCost: 35.0,
        cooldownSeconds: 5.0,
        damageMultiplier: 2.2,
        areaOfEffectRadius: 210.0,
        element: ElementType.spiderWeb,
        color: AppColors.webFluidBlue,
      ),
      SkillModel(
        id: SkillId.infernoComet,
        name: 'Symbiote Tendril Surge',
        description: 'Erupts chaotic black and crimson Symbiote tendril spikes around Spider-Hero, piercing enemies with critical bleed damage.',
        icon: Icons.alt_route_rounded,
        manaCost: 55.0,
        cooldownSeconds: 7.0,
        damageMultiplier: 3.5,
        areaOfEffectRadius: 240.0,
        element: ElementType.symbiote,
        color: AppColors.carnageCrimson,
      ),
      SkillModel(
        id: SkillId.voidDash,
        name: 'Web-Zip Strike',
        description: 'Fires a high-velocity web line pulling Spider-Hero forward with complete invulnerability, delivering a devastating aerial dropkick.',
        icon: Icons.flash_on_rounded,
        manaCost: 25.0,
        cooldownSeconds: 3.0,
        damageMultiplier: 1.8,
        areaOfEffectRadius: 120.0,
        element: ElementType.spiderWeb,
        color: AppColors.spiderRedLight,
      ),
    ];
  }
}
