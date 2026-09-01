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
          // Background Gradient Nebula
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.nebulaBackground,
              ),
            ),
          ),

          // Glowing Rune Core in Center (Optimized for Cinema Landscape)
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
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.celestialGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.frostPrimary.withValues(alpha: _glowAnimation.value * 0.8),
                                  blurRadius: 36,
                                  spreadRadius: 8,
                                ),
                                BoxShadow(
                                  color: AppColors.firePrimary.withValues(alpha: _glowAnimation.value * 0.5),
                                  blurRadius: 50,
                                  spreadRadius: 12,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.shield_moon_rounded,
                                color: AppColors.black87,
                                size: 56,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Game Title
                        ShaderMask(
                          shaderCallback: (bounds) => AppColors.celestialGradient.createShader(bounds),
                          child: const Text(
                            'A V A T A R',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 12.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        Text(
                          'THE ELEMENTAL ODYSSEY',
                          style: TextStyle(
                            color: AppColors.frostPrimary.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4.0,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Loading Indicator
                        SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.frostPrimary),
                            backgroundColor: AppColors.white12,
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'INITIALIZING 60FPS GAME ENGINE...',
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
