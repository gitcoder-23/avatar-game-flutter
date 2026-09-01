import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/theme/colors.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Start menu background audio immediately upon opening the app
    AudioService.instance.init();
    AudioService.instance.playMenuBgm();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _animController.forward();

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Background City Night Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.cityNightGradient,
              ),
            ),
          ),

          // Main Center Content (Landscape 2-Column: Character Image & Title Branding)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: Superhero Character Art with glowing border
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) => ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.spiderRedLight, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.spiderRed.withValues(alpha: 0.3 + _glowAnimation.value * 0.4),
                                blurRadius: 20 + _glowAnimation.value * 15,
                                spreadRadius: 2 + _glowAnimation.value * 4,
                              ),
                              BoxShadow(
                                color: AppColors.spiderBlue.withValues(alpha: 0.2 + _glowAnimation.value * 0.3),
                                blurRadius: 30 + _glowAnimation.value * 20,
                                spreadRadius: 4 + _glowAnimation.value * 6,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.asset(
                              'assets/images/super_hero_splash.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.bgDarkCard,
                                  child: const Center(
                                    child: Icon(
                                      Icons.shield_moon_rounded,
                                      color: AppColors.spiderRed,
                                      size: 64,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 32),

                    // Right: Title, Subtitle, Progress Bar
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // App Tag Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.spiderRed.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.spiderRed.withValues(alpha: 0.6)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.flash_on_rounded, color: AppColors.electricGold, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'ACTION HERO : SPIDER SYMBIOTE',
                                    style: TextStyle(
                                      color: AppColors.spiderRedLight,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Main Title
                            ShaderMask(
                              shaderCallback: (bounds) => AppColors.spiderGradient.createShader(bounds),
                              child: const Text(
                                'ACTION HERO',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 6.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),

                            const Text(
                              'SYMBIOTE STRIKE • VENOM APEX',
                              style: TextStyle(
                                color: AppColors.carnageCrimson,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3.0,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Loading Progress Bar
                            SizedBox(
                              width: 240,
                              child: LinearProgressIndicator(
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.spiderRed),
                                backgroundColor: AppColors.white12,
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'INITIALIZING MANHATTAN RADAR & AUDIO...',
                              style: TextStyle(
                                color: AppColors.white38,
                                fontSize: 9,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
