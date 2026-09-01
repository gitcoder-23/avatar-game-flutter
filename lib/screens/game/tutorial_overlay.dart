import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../widgets/widgets.dart';

class TutorialStep {
  final String title;
  final String description;
  final Alignment targetAlignment;
  final IconData icon;
  final Color glowColor;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.targetAlignment,
    required this.icon,
    required this.glowColor,
  });
}

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialOverlay({
    super.key,
    required this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> with SingleTickerProviderStateMixin {
  int _currentStepIndex = 0;
  late AnimationController _pulseController;

  final List<TutorialStep> _steps = const [
    TutorialStep(
      title: '1. Virtual Movement Joystick',
      description: 'Drag the glowing analog joystick on the bottom-left to navigate your Avatar freely in 360 degrees.',
      targetAlignment: Alignment(-0.75, 0.75),
      icon: Icons.navigation_rounded,
      glowColor: AppColors.frostPrimary,
    ),
    TutorialStep(
      title: '2. Basic Elemental Slash',
      description: 'Tap the main attack button on the bottom-right to unleash rapid 3-hit elemental blade combos with knockback!',
      targetAlignment: Alignment(0.85, 0.75),
      icon: Icons.colorize_rounded,
      glowColor: AppColors.frostPrimary,
    ),
    TutorialStep(
      title: '3. Skill 1: Frost Nova',
      description: 'Freezes all nearby monsters in ice for over 3 seconds, rendering them defenseless to your combos.',
      targetAlignment: Alignment(0.60, 0.58),
      icon: Icons.ac_unit_rounded,
      glowColor: AppColors.frostGlow,
    ),
    TutorialStep(
      title: '4. Skill 2: Inferno Comet',
      description: 'Calls down a blazing celestial meteorite that detonates with massive area-of-effect critical fire damage.',
      targetAlignment: Alignment(0.78, 0.44),
      icon: Icons.local_fire_department_rounded,
      glowColor: AppColors.fireSecondary,
    ),
    TutorialStep(
      title: '5. Skill 3: Void Blink Dash',
      description: 'Teleports your Avatar forward with complete invulnerability frames to dodge boss shockwaves and laser beams.',
      targetAlignment: Alignment(0.95, 0.44),
      icon: Icons.flash_on_rounded,
      glowColor: AppColors.voidSecondary,
    ),
    TutorialStep(
      title: '6. Celestial Cataclysm Ultimate',
      description: 'Build your combo meter to charge 100% Ultimate energy and summon the quad-elemental apocalypse!',
      targetAlignment: Alignment(0.55, 0.88),
      icon: Icons.auto_awesome_rounded,
      glowColor: AppColors.celestialGold,
    ),
    TutorialStep(
      title: '7. Elixir of Life & Mana',
      description: 'Tap the potion icon to instantly restore 50% HP and 50% Mana during intense boss clashes.',
      targetAlignment: Alignment(-0.85, -0.85),
      icon: Icons.medical_services_rounded,
      glowColor: AppColors.potionGreen,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStepIndex];

    return Material(
      color: AppColors.black78,
      child: Stack(
        children: [
          // Spotlight Glow Circle
          Align(
            alignment: step.targetAlignment,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + _pulseController.value * 0.25;
                return Container(
                  width: 80 * scale,
                  height: 80 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: step.glowColor,
                      width: 3.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: step.glowColor.withValues(alpha: 0.8),
                        blurRadius: 24,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.touch_app_rounded,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
          ),

          // Dialog Card (Landscape Optimized & Centered)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: GlassCard(
                  radius: 18,
                  borderColor: step.glowColor,
                  glowColor: step.glowColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: step.glowColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: step.glowColor),
                            ),
                            child: Icon(step.icon, color: step.glowColor, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TUTORIAL (${_currentStepIndex + 1}/${_steps.length})',
                                  style: TextStyle(
                                    color: step.glowColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  step.title,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        step.description,
                        style: const TextStyle(
                          color: AppColors.white70,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: widget.onComplete,
                            child: const Text(
                              'SKIP ALL',
                              style: TextStyle(color: AppColors.white54, fontSize: 11),
                            ),
                          ),
                          GlowingButton(
                            text: _currentStepIndex == _steps.length - 1 ? 'START BATTLE!' : 'NEXT HINT',
                            icon: _currentStepIndex == _steps.length - 1 ? Icons.check_circle : Icons.arrow_forward_rounded,
                            height: 36,
                            fontSize: 11,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            backgroundColor: step.glowColor,
                            textColor: AppColors.black,
                            onPressed: _nextStep,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
