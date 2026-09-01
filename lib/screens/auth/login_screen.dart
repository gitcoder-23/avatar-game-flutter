import 'package:flutter/material.dart';
import '../../core/database/user_dao.dart';
import '../../core/theme/colors.dart';
import '../../utils/function.dart';
import '../../widgets/widgets.dart';
import '../hub/stage_select_screen.dart';
import '../intro/lore_intro_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await UserDAO.instance.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (user != null && mounted) {
        if (!user.tutorialCompleted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LoreIntroScreen(user: user),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StageSelectScreen(user: user),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _fillGuestUser() async {
    setState(() {
      _usernameController.text = 'spider_hero';
      _passwordController.text = 'spider123';
    });

    try {
      await UserDAO.instance.register(
        username: 'spider_hero',
        password: 'spider123',
        heroName: 'Spider-Hero (Classic Suit)',
      );
    } catch (_) {}

    _handleLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Background City Night Sky
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.cityNightGradient,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left Column: Spider-Hero Brand
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.spiderGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.spiderRed.withValues(alpha: 0.6),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.shield_moon_rounded, color: AppColors.white, size: 40),
                            ),
                          ),
                          const SizedBox(height: 12),

                          ShaderMask(
                            shaderCallback: (bounds) => AppColors.spiderGradient.createShader(bounds),
                            child: const Text(
                              'SPIDER-HERO',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 6.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),

                          const Text(
                            'SYMBIOTE STRIKE : VENOM CARNAGE',
                            style: TextStyle(
                              color: AppColors.carnageCrimson,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.black45,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.spiderRed.withValues(alpha: 0.4)),
                            ),
                            child: const Text(
                              '🕸️ WEB-ZIP • VENOM SYMBIOTE • 3D SKYLINE 🌆',
                              style: TextStyle(color: AppColors.white70, fontSize: 9, letterSpacing: 1.0),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Right Column: Auth Card
                    Expanded(
                      flex: 5,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 380),
                        child: GlassCard(
                          radius: 18,
                          borderColor: AppColors.spiderRed,
                          glowColor: AppColors.spiderGlow,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'HERO HEADQUARTERS LOGIN',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                if (_errorMessage != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.healthRed.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.healthRed),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline_rounded, color: AppColors.healthRed, size: 16),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: const TextStyle(color: AppColors.white, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],

                                // Username field
                                CustomTextField(
                                  controller: _usernameController,
                                  label: 'Hero Codename',
                                  prefixIcon: Icons.person_rounded,
                                  focusColor: AppColors.spiderRedLight,
                                  validator: GameUtils.validateUsername,
                                ),
                                const SizedBox(height: 10),

                                // Password field
                                CustomTextField(
                                  controller: _passwordController,
                                  label: 'Security Passkey',
                                  prefixIcon: Icons.lock_rounded,
                                  obscureText: _obscurePassword,
                                  focusColor: AppColors.spiderRedLight,
                                  validator: GameUtils.validatePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: AppColors.white54,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: GlowingButton(
                                        text: 'PATROL NYC',
                                        height: 42,
                                        fontSize: 12,
                                        isLoading: _isLoading,
                                        backgroundColor: AppColors.spiderRed,
                                        textColor: AppColors.white,
                                        glowColor: AppColors.spiderGlow,
                                        onPressed: _handleLogin,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: GlowingButton(
                                        text: 'DEMO PLAY',
                                        icon: Icons.flash_on_rounded,
                                        isOutlined: true,
                                        height: 42,
                                        fontSize: 12,
                                        backgroundColor: AppColors.electricGold,
                                        textColor: AppColors.electricGold,
                                        onPressed: _fillGuestUser,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Register link
                                Center(
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      const Text('New Hero? ', style: TextStyle(color: AppColors.white60, fontSize: 11)),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                          );
                                        },
                                        child: const Text(
                                          'SUIT UP & REGISTER',
                                          style: TextStyle(
                                            color: AppColors.spiderRedLight,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
