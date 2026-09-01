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
    required this.glowColor,
    required this.primaryColor,
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
      chapter: 'COMIC ISSUE #1',
      title: 'THE ALIEN SYMBIOTE METEOR',
      narrative:
          'Deep in the night sky over New York City, a classified Oscorp space shuttle crashed into Manhattan, releasing an aggressive extraterrestrial Symbiote entity.',
      icon: Icons.public_off_rounded,
      primaryColor: AppColors.spiderRed,
      glowColor: AppColors.spiderGlow,
    ),
    LoreSlide(
      chapter: 'COMIC ISSUE #2',
      title: 'MANHATTAN UNDER SIEGE',
      narrative:
          'The Symbiote rapidly bonded with street gangs, Oscorp cyber drones, and subway mutagens. Chaos erupted across Queens, Times Square, and the Financial District.',
      icon: Icons.warning_rounded,
      primaryColor: AppColors.symbiotePurple,
      glowColor: AppColors.venomGlow,
    ),
    LoreSlide(
      chapter: 'COMIC ISSUE #3',
      title: 'RISE OF VENOM & CARNAGE',
      narrative:
          'At the apex of Oscorp Tower, the primary organism matured into VENOM—a hulking Symbiote Overlord armed with colossal tendrils, razor fangs, and lethal shockwaves.',
      icon: Icons.dangerous_rounded,
      primaryColor: AppColors.carnageCrimson,
      glowColor: AppColors.carnageGlow,
    ),
    LoreSlide(
      chapter: 'COMIC ISSUE #4',
      title: 'SPIDER-HERO STRIKE',
      narrative:
          'Suit up, Web-Slinger! Master Web-Zip strikes, radial Web-Net clusters, and your own Symbiote Tendril powers to purge the 6 City Districts and defeat Venom!',
      icon: Icons.shield_moon_rounded,
      primaryColor: AppColors.spiderBlueLight,
      glowColor: AppColors.webFluidBlue,
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
          // Background City Night
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.cityNightGradient,
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
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.spiderGradient,
                            ),
                            child: const Icon(Icons.shield_moon_rounded, size: 16, color: AppColors.white),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'SPIDER-HERO CHRONICLES',
                            style: TextStyle(
                              color: AppColors.spiderRedLight,
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
                          'SKIP TO DISTRICTS',
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
                              color: isActive ? AppColors.spiderRed : AppColors.white24,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),

                      // Next / Start Button
                      GlowingButton(
                        text: _currentPage == _slides.length - 1 ? 'START DISTRICT 1: TUTORIAL' : 'NEXT ISSUE',
                        icon: _currentPage == _slides.length - 1 ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded,
                        height: 38,
                        fontSize: 12,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        backgroundColor: AppColors.spiderRed,
                        textColor: AppColors.white,
                        glowColor: AppColors.spiderGlow,
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
