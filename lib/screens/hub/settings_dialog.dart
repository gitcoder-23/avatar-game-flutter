import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/database/user_dao.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/game_theme.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';

class SettingsDialog extends StatefulWidget {
  final UserModel user;
  final Function(UserModel updatedUser) onUserUpdated;

  const SettingsDialog({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _soundEnabled;
  late bool _musicEnabled;

  @override
  void initState() {
    super.initState();
    _soundEnabled = widget.user.soundEnabled;
    _musicEnabled = widget.user.musicEnabled;
  }

  void _saveSettings() async {
    final updated = widget.user.copyWith(
      soundEnabled: _soundEnabled,
      musicEnabled: _musicEnabled,
    );
    await UserDAO.instance.updateUser(updated);
    AudioService.instance.updateSettings(
      soundEnabled: _soundEnabled,
      musicEnabled: _musicEnabled,
    );
    widget.onUserUpdated(updated);
    if (mounted) Navigator.pop(context);
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: Container(
          width: 320,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: GameTheme.glassCardDecoration(
            radius: 24,
            borderColor: AppColors.frostPrimary,
            glowColor: AppColors.frostPrimary,
          ),
          child: Material(
            color: AppColors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    Icon(Icons.settings_rounded, color: AppColors.frostPrimary, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'REALM SETTINGS',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sound SFX toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: AppColors.frostPrimary,
                  title: const Text('Sound Effects (SFX)', style: TextStyle(color: AppColors.white)),
                  subtitle: const Text('Impacts, slashes & spell bursts', style: TextStyle(color: AppColors.white54, fontSize: 12)),
                  value: _soundEnabled,
                  onChanged: (val) {
                    setState(() {
                      _soundEnabled = val;
                    });
                  },
                ),
                const Divider(color: AppColors.white12),

                // Music BGM toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: AppColors.frostPrimary,
                  title: const Text('Background Music (BGM)', style: TextStyle(color: AppColors.white)),
                  subtitle: const Text('Epic fantasy combat soundtracks', style: TextStyle(color: AppColors.white54, fontSize: 12)),
                  value: _musicEnabled,
                  onChanged: (val) {
                    setState(() {
                      _musicEnabled = val;
                    });
                  },
                ),
                const Divider(color: AppColors.white12),
                const SizedBox(height: 18),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.frostPrimary,
                      foregroundColor: AppColors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _saveSettings,
                    child: const Text('SAVE PREFERENCES', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),

                // Logout button
                TextButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, color: AppColors.healthRed, size: 18),
                  label: const Text('LOGOUT WARRIOR', style: TextStyle(color: AppColors.healthRed)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
