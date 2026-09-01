import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/database/user_dao.dart';
import '../../core/theme/colors.dart';
import '../../models/stage_model.dart';
import '../../models/user_model.dart';
import '../../utils/function.dart';
import '../../widgets/widgets.dart';

class StageResultModal extends StatefulWidget {
  final bool isVictory;
  final StageModel stage;
  final UserModel user;
  final int score;
  final int timeSeconds;
  final int maxCombo;
  final int kills;
  final double hpPercent;
  final VoidCallback onRetry;
  final VoidCallback onNextStage;
  final VoidCallback onReturnHub;

  const StageResultModal({
    super.key,
    required this.isVictory,
    required this.stage,
    required this.user,
    required this.score,
    required this.timeSeconds,
    required this.maxCombo,
    required this.kills,
    required this.hpPercent,
    required this.onRetry,
    required this.onNextStage,
    required this.onReturnHub,
  });

  @override
  State<StageResultModal> createState() => _StageResultModalState();
}

class _StageResultModalState extends State<StageResultModal> {
  int _starsEarned = 0;
  int _rewardGold = 0;
  int _rewardXp = 0;

  @override
  void initState() {
    super.initState();
    _calculateAndSave();
  }

  void _calculateAndSave() async {
    if (widget.isVictory) {
      _starsEarned = GameUtils.calculateStars(
        isVictory: true,
        hpPercent: widget.hpPercent,
        timeSeconds: widget.timeSeconds,
      );

      _rewardGold = widget.stage.rewardGold;
      _rewardXp = widget.stage.rewardXp;

      if (widget.user.id != null) {
        await UserDAO.instance.updateStageResult(
          userId: widget.user.id!,
          stageId: widget.stage.id,
          stars: _starsEarned,
          score: widget.score,
          timeSeconds: widget.timeSeconds,
          rewardGold: _rewardGold,
          rewardXp: _rewardXp,
        );
      }
    } else {
      _starsEarned = 0;
      _rewardGold = (widget.stage.rewardGold * 0.2).toInt();
      _rewardXp = (widget.stage.rewardXp * 0.2).toInt();
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isVictory ? AppColors.frostPrimary : AppColors.healthRed;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: GlassCard(
              radius: 20,
              borderColor: themeColor,
              glowColor: themeColor,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Column: Result Icon, Title & Stars
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isVictory ? Icons.emoji_events_rounded : Icons.dangerous_rounded,
                          color: themeColor,
                          size: 52,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.isVictory ? 'VICTORY!' : 'DEFEAT',
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Text(
                          widget.stage.name,
                          style: const TextStyle(
                            color: AppColors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (widget.isVictory)
                          StarRating(earnedStars: _starsEarned, starSize: 26),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Right Column: Battle Statistics & Actions
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.black45,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.white12),
                          ),
                          child: Column(
                            children: [
                              _statRow('Score', GameUtils.formatNumber(widget.score)),
                              const Divider(color: AppColors.white10, height: 8),
                              _statRow('Time / Combo', '${GameUtils.formatDuration(widget.timeSeconds)}  •  ${widget.maxCombo}x'),
                              const Divider(color: AppColors.white10, height: 8),
                              _statRow('Gold / XP', '+${GameUtils.formatNumber(_rewardGold)} 🪙  •  +${GameUtils.formatNumber(_rewardXp)} ✨', color: AppColors.goldCurrency),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: GlowingButton(
                                text: 'RETRY',
                                icon: Icons.refresh_rounded,
                                isOutlined: true,
                                height: 38,
                                fontSize: 11,
                                backgroundColor: AppColors.white70,
                                textColor: AppColors.white,
                                onPressed: widget.onRetry,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (widget.isVictory && widget.stage.id < 6)
                              Expanded(
                                child: GlowingButton(
                                  text: 'NEXT STAGE',
                                  icon: Icons.skip_next_rounded,
                                  height: 38,
                                  fontSize: 11,
                                  backgroundColor: AppColors.frostPrimary,
                                  textColor: AppColors.black,
                                  onPressed: widget.onNextStage,
                                ),
                              )
                            else
                              Expanded(
                                child: GlowingButton(
                                  text: 'WORLD MAP',
                                  icon: Icons.map_rounded,
                                  height: 38,
                                  fontSize: 11,
                                  backgroundColor: AppColors.bgSlateCard,
                                  textColor: AppColors.white,
                                  onPressed: widget.onReturnHub,
                                ),
                              ),
                          ],
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
    );
  }

  Widget _statRow(String label, String value, {Color color = AppColors.white}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.white60, fontSize: 11)),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
