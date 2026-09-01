import 'package:flutter/material.dart';
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

    Future.delayed(const Duration(milliseconds: 3000), () {
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
          // Background Gradient City Night
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.cityNightGradient,
              ),
            ),
          ),

          // Glowing Spider Emblem Core in Center
          Center(
            child: SingleChildScrollView(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.spiderGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.spiderRed.withValues(alpha: _glowAnimation.value * 0.8),
                                  blurRadius: 36,
                                  spreadRadius: 8,
                                ),
                                BoxShadow(
                                  color: AppColors.spiderBlue.withValues(alpha: _glowAnimation.value * 0.6),
                                  blurRadius: 50,
                                  spreadRadius: 12,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.shield_moon_rounded,
                                color: AppColors.white,
                                size: 62,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Game Title
                        ShaderMask(
                          shaderCallback: (bounds) => AppColors.spiderGradient.createShader(bounds),
                          child: const Text(
                            'SPIDER-HERO',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          'SYMBIOTE STRIKE : VENOM CARNAGE',
                          style: TextStyle(
                            color: AppColors.carnageCrimson,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Loading Indicator
                        SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.spiderRed),
                            backgroundColor: AppColors.white12,
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'INITIALIZING MANHATTAN CRIME RADAR...',
                          style: TextStyle(
                            color: AppColors.white38,
                            fontSize: 10,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
