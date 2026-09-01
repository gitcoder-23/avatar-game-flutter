import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../models/stage_model.dart';
import '../../models/user_model.dart';
import '../../widgets/widgets.dart';
import '../game/game_play_screen.dart';
import '../hub/stage_select_screen.dart';

class LoreSlide {
  final String chapter;
  final String title;
  final String narrative;
  final IconData icon;
  final Color primaryColor;
  final Color glowColor;

  const LoreSlide({
    required this.chapter,
    required this.title,
    required this.narrative,
    required this.icon,
    required this.primaryColor,
    required this.glowColor,
  });
}

class LoreIntroScreen extends StatefulWidget {
  final UserModel user;

  const LoreIntroScreen({
    super.key,
    required this.user,
  });

  @override
  State<LoreIntroScreen> createState() => _LoreIntroScreenState();
}

class _LoreIntroScreenState extends State<LoreIntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<LoreSlide> _slides = const [
    LoreSlide(
      chapter: 'PROLOGUE I',
      title: 'THE SHATTERING OF AETHELGARD',
      narrative:
          'For eons, the Quad-Elemental Nexus kept peace across the celestial realm. But darkness stirred deep within the void, tearing open dimensional fissures across the sacred domains.',
      icon: Icons.public_off_rounded,
      primaryColor: AppColors.frostPrimary,
      glowColor: AppColors.frostGlow,
    ),
    LoreSlide(
      chapter: 'PROLOGUE II',
      title: 'RISE OF DREAD TITAN MALAKOR',
      narrative:
          'At the Celestial Core, Malakor—the Primordial Dread Titan—awoke, corrupting the creatures of Whispering Woods, Blazing Caverns, Frost Temples, Tempest Citadel, and the Void Abyss.',
      icon: Icons.warning_rounded,
      primaryColor: AppColors.healthRed,
      glowColor: AppColors.healthRedLight,
    ),
    LoreSlide(
      chapter: 'PROLOGUE III',
      title: 'AWAKENING OF THE AVATAR',
      narrative:
          'You are chosen as the Avatar, the sole warrior imbued with the Quad-Element Catalyst. Master the powers of Frost Nova, Inferno Meteor, and Void Blink to reclaim the celestial realm.',
      icon: Icons.auto_awesome_rounded,
      primaryColor: AppColors.celestialGold,
      glowColor: AppColors.stormGlow,
    ),
    LoreSlide(
      chapter: 'PROLOGUE IV',
      title: 'THE SIX-STAGE CRUSADE',
      narrative:
          'Conquer all 5 elemental strongholds, build your blade combo mastery, and confront Malakor in the ultimate 3-Phase Boss Showdown at the Celestial Core!',
      icon: Icons.military_tech_rounded,
      primaryColor: AppColors.voidSecondary,
      glowColor: AppColors.voidGlow,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _startInitialStage();
    }
  }

  void _startInitialStage() {
    final stage1 = StageModel.getStageById(1);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GamePlayScreen(
          user: widget.user.copyWith(tutorialCompleted: false),
          stage: stage1,
        ),
      ),
    );
  }

  void _goToWorldMap() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StageSelectScreen(user: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Background Nebula
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.nebulaBackground,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Top Header Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.frostGradient,
                            ),
                            child: const Icon(Icons.shield_moon_rounded, size: 14, color: AppColors.white),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AVATAR CHRONICLES',
                            style: TextStyle(
                              color: AppColors.frostPrimary.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _goToWorldMap,
                        icon: const Icon(Icons.skip_next_rounded, color: AppColors.white60, size: 16),
                        label: const Text(
                          'SKIP TO MAP',
                          style: TextStyle(color: AppColors.white60, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // PageView Slider (Landscape 2-Column Responsive Card)
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final slide = _slides[index];
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: GlassCard(
                              radius: 18,
                              borderColor: slide.primaryColor,
                              glowColor: slide.glowColor,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Left: Glowing Emblem & Chapter Badge
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: slide.primaryColor.withValues(alpha: 0.15),
                                          border: Border.all(color: slide.primaryColor, width: 2.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: slide.glowColor.withValues(alpha: 0.4),
                                              blurRadius: 18,
                                              spreadRadius: 3,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(slide.icon, color: AppColors.white, size: 36),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: slide.primaryColor.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: slide.primaryColor.withValues(alpha: 0.5)),
                                        ),
                                        child: Text(
                                          slide.chapter,
                                          style: TextStyle(
                                            color: slide.primaryColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 20),

                                  // Right: Narrative Text in Scrollable Box
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            slide.title,
                                            style: const TextStyle(
                                              color: AppColors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            slide.narrative,
                                            style: const TextStyle(
                                              color: AppColors.white70,
                                              fontSize: 13,
                                              height: 1.45,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bottom Bar: Dots Indicator & Action Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots Indicator
                      Row(
                        children: List.generate(_slides.length, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isActive ? 22 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.frostPrimary : AppColors.white24,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),

                      // Next / Start Button
                      GlowingButton(
                        text: _currentPage == _slides.length - 1 ? 'START TUTORIAL' : 'NEXT CHAPTER',
                        icon: _currentPage == _slides.length - 1 ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded,
                        height: 38,
                        fontSize: 12,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        backgroundColor: AppColors.frostPrimary,
                        textColor: AppColors.black,
                        onPressed: _nextPage,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
