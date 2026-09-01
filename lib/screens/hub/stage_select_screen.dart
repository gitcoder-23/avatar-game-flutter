import 'package:flutter/material.dart';
import '../../core/database/user_dao.dart';
import '../../core/theme/colors.dart';
import '../../models/stage_model.dart';
import '../../models/stage_progress_model.dart';
import '../../models/user_model.dart';
import '../../utils/function.dart';
import '../../widgets/widgets.dart';
import '../game/game_play_screen.dart';
import 'hero_upgrade_screen.dart';
import 'settings_dialog.dart';

class StageSelectScreen extends StatefulWidget {
  final UserModel user;

  const StageSelectScreen({
    super.key,
    required this.user,
  });

  @override
  State<StageSelectScreen> createState() => _StageSelectScreenState();
}

class _StageSelectScreenState extends State<StageSelectScreen> {
  late UserModel _user;
  List<StageProgressModel> _progressList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadData();
  }

  void _loadData() async {
    if (_user.id != null) {
      final updatedUser = await UserDAO.instance.getUserById(_user.id!);
      final progress = await UserDAO.instance.getStageProgress(_user.id!);
      if (mounted) {
        setState(() {
          if (updatedUser != null) _user = updatedUser;
          _progressList = progress;
          _isLoading = false;
        });
      }
    }
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (_) => SettingsDialog(
        user: _user,
        onUserUpdated: (u) => setState(() => _user = u),
      ),
    );
  }

  void _openHeroSanctuary() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HeroUpgradeScreen(
          user: _user,
          onUserUpdated: (u) => setState(() => _user = u),
        ),
      ),
    );
    _loadData();
  }

  void _enterStage(StageModel stage) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GamePlayScreen(user: _user, stage: stage),
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Background Cosmic Nebula
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.nebulaBackground,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 12),

                // World Map Title Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CELESTIAL REALMS',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                          Text(
                            'Select a corrupted domain to purge',
                            style: TextStyle(color: AppColors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                      GlowingButton(
                        text: 'HERO CODEX',
                        icon: Icons.shield_moon_rounded,
                        isOutlined: true,
                        backgroundColor: AppColors.frostPrimary,
                        textColor: AppColors.frostPrimary,
                        height: 42,
                        fontSize: 12,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        onPressed: _openHeroSanctuary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 6-Stage List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.frostPrimary))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            final stageId = index + 1;
                            final stage = StageModel.getStageById(stageId);
                            final progress = _progressList.firstWhere(
                              (p) => p.stageId == stageId,
                              orElse: () => StageProgressModel(
                                userId: _user.id ?? 0,
                                stageId: stageId,
                                isUnlocked: stageId == 1,
                              ),
                            );

                            return _buildStageCard(stage, progress);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      radius: 18,
      borderColor: AppColors.borderGlass,
      child: Row(
        children: [
          // Hero Avatar & Level
          GestureDetector(
            onTap: _openHeroSanctuary,
            child: Stack(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.frostGradient,
                    border: Border.all(color: AppColors.white, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.shield_moon_rounded, color: AppColors.white, size: 24),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: LevelBadge(level: _user.heroLevel),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Hero Name & Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user.heroName,
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  'Quad-Elemental Avatar',
                  style: TextStyle(color: AppColors.frostPrimary.withValues(alpha: 0.8), fontSize: 11),
                ),
              ],
            ),
          ),

          // Reusable Currency Badges
          Row(
            children: [
              CurrencyBadge(icon: Icons.monetization_on_rounded, amount: _user.gold, color: AppColors.goldCurrency),
              const SizedBox(width: 6),
              CurrencyBadge(icon: Icons.diamond_rounded, amount: _user.crystals, color: AppColors.crystalCurrency),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.settings_rounded, color: AppColors.white70, size: 22),
                onPressed: _openSettings,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageCard(StageModel stage, StageProgressModel progress) {
    final isUnlocked = progress.isUnlocked;
    final isBoss = stage.isBoss;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      radius: 20,
      borderColor: isUnlocked ? stage.primaryColor : AppColors.white12,
      glowColor: isUnlocked ? stage.primaryColor : AppColors.transparent,
      child: Row(
        children: [
          // Stage Rune / Element Icon
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked ? stage.primaryColor.withValues(alpha: 0.2) : AppColors.white10,
              border: Border.all(
                color: isUnlocked ? stage.primaryColor : AppColors.white24,
                width: 2,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: stage.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                isUnlocked ? stage.bgRune : '🔒',
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Stage Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'STAGE ${stage.id}',
                      style: TextStyle(
                        color: isUnlocked ? stage.primaryColor : AppColors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    if (isBoss) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.healthRed,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'BOSS FIGHT',
                          style: TextStyle(color: AppColors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  stage.name,
                  style: TextStyle(
                    color: isUnlocked ? AppColors.white : AppColors.white38,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stage.subtitle,
                  style: const TextStyle(color: AppColors.white54, fontSize: 11),
                ),
                const SizedBox(height: 8),

                // Reusable Star Rating & High Score
                if (isUnlocked)
                  Row(
                    children: [
                      StarRating(earnedStars: progress.stars, starSize: 18),
                      const SizedBox(width: 12),
                      if (progress.highScore > 0)
                        Text(
                          'Best: ${GameUtils.formatNumber(progress.highScore)} pts',
                          style: const TextStyle(color: AppColors.white60, fontSize: 11),
                        ),
                    ],
                  )
                else
                  const Text(
                    'Defeat previous stage to unlock',
                    style: TextStyle(color: AppColors.white24, fontSize: 11),
                  ),
              ],
            ),
          ),

          // Reusable Action Button
          if (isUnlocked)
            GlowingButton(
              text: 'BATTLE',
              height: 42,
              fontSize: 13,
              backgroundColor: stage.primaryColor,
              textColor: AppColors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              onPressed: () => _enterStage(stage),
            )
          else
            const Icon(Icons.lock_rounded, color: AppColors.white24, size: 28),
        ],
      ),
    );
  }
}
