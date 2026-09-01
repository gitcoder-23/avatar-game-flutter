import 'package:flutter/material.dart';
import '../../core/database/user_dao.dart';
import '../../core/theme/colors.dart';
import '../../utils/function.dart';
import '../../widgets/widgets.dart';
import '../intro/lore_intro_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _heroNameController = TextEditingController(text: 'Avatar Kael');
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  final List<String> _heroPresets = [
    'Avatar Kael (Frost)',
    'Avatar Ignis (Fire)',
    'Avatar Zephyr (Storm)',
    'Avatar Nyx (Void)',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _heroNameController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await UserDAO.instance.register(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        heroName: _heroNameController.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoreIntroScreen(user: user),
          ),
        );
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
                gradient: AppColors.registerNebulaBackground,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left Column: Hero Awakening Showcase
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.voidGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.voidPrimary.withValues(alpha: 0.5),
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

                          const Text(
                            'WARRIOR AWAKENING',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 4),

                          const Text(
                            'CHOOSE YOUR ELEMENTAL PATH',
                            style: TextStyle(
                              color: AppColors.voidGlow,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),

                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.white70,
                              side: const BorderSide(color: AppColors.white24),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                            label: const Text('BACK TO LOGIN', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Right Column: Glassmorphic Register Form
                    Expanded(
                      flex: 5,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: GlassCard(
                          radius: 18,
                          borderColor: AppColors.voidPrimary,
                          glowColor: AppColors.voidPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'FORGE AVATAR PROFILE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                if (_errorMessage != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.healthRed.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.healthRed),
                                    ),
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: AppColors.white, fontSize: 11),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],

                                // Username field
                                CustomTextField(
                                  controller: _usernameController,
                                  label: 'Unique Username',
                                  prefixIcon: Icons.person_rounded,
                                  focusColor: AppColors.voidGlow,
                                  validator: GameUtils.validateUsername,
                                ),
                                const SizedBox(height: 8),

                                // Password field
                                CustomTextField(
                                  controller: _passwordController,
                                  label: 'Secret Passkey',
                                  prefixIcon: Icons.lock_rounded,
                                  obscureText: _obscurePassword,
                                  focusColor: AppColors.voidGlow,
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
                                const SizedBox(height: 8),

                                // Hero Class Dropdown
                                DropdownButtonFormField<String>(
                                  initialValue: _heroPresets.first,
                                  dropdownColor: AppColors.bgDarkCard,
                                  style: const TextStyle(color: AppColors.white, fontSize: 13),
                                  decoration: InputDecoration(
                                    labelText: 'Avatar Class',
                                    labelStyle: const TextStyle(color: AppColors.white60, fontSize: 12),
                                    prefixIcon: const Icon(Icons.shield_rounded, color: AppColors.voidGlow, size: 18),
                                    filled: true,
                                    fillColor: AppColors.black30,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: AppColors.white24),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: AppColors.voidGlow, width: 1.5),
                                    ),
                                  ),
                                  items: _heroPresets.map((preset) {
                                    return DropdownMenuItem(
                                      value: preset,
                                      child: Text(preset, style: const TextStyle(color: AppColors.white, fontSize: 13)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      _heroNameController.text = val;
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Glowing Register Button
                                GlowingButton(
                                  text: 'AWAKEN AVATAR',
                                  height: 42,
                                  fontSize: 12,
                                  isLoading: _isLoading,
                                  backgroundColor: AppColors.voidPrimary,
                                  textColor: AppColors.white,
                                  glowColor: AppColors.voidGlow,
                                  onPressed: _handleRegister,
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
