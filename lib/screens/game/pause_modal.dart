import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../widgets/widgets.dart';

class PauseModal extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const PauseModal({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: GlassCard(
              radius: 20,
              borderColor: AppColors.frostPrimary,
              glowColor: AppColors.frostPrimary,
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pause_circle_filled_rounded,
                        color: AppColors.frostPrimary,
                        size: 32,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'BATTLE PAUSED',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GlowingButton(
                          text: 'RESUME',
                          icon: Icons.play_arrow_rounded,
                          height: 40,
                          fontSize: 12,
                          backgroundColor: AppColors.frostPrimary,
                          textColor: AppColors.black,
                          onPressed: onResume,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GlowingButton(
                          text: 'RETRY',
                          icon: Icons.refresh_rounded,
                          isOutlined: true,
                          height: 40,
                          fontSize: 12,
                          backgroundColor: AppColors.stormPrimary,
                          textColor: AppColors.stormPrimary,
                          onPressed: onRestart,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GlowingButton(
                          text: 'EXIT HUB',
                          icon: Icons.exit_to_app_rounded,
                          height: 40,
                          fontSize: 12,
                          backgroundColor: AppColors.bgSlateCard,
                          textColor: AppColors.white,
                          onPressed: onQuit,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
