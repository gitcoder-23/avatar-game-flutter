import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/database/user_dao.dart';
import '../../core/theme/colors.dart';
import '../../game/game_controller.dart';
import '../../game/game_painter.dart';
import '../../game/joystick/virtual_joystick.dart';
import '../../models/enemy_model.dart';
import '../../models/skill_model.dart';
import '../../models/stage_model.dart';
import '../../models/user_model.dart';
import '../../widgets/widgets.dart';
import 'pause_modal.dart';
import 'stage_result_modal.dart';
import 'tutorial_overlay.dart';

class GamePlayScreen extends StatefulWidget {
  final UserModel user;
  final StageModel stage;

  const GamePlayScreen({
    super.key,
    required this.user,
    required this.stage,
  });

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> with TickerProviderStateMixin {
  late GameController _controller;
  late AnimationController _animTimerController;
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _showTutorial = !widget.user.tutorialCompleted;

    // Start stage-specific background music (High-tempo action or Venom Boss theme)
    AudioService.instance.playStageBgm(widget.stage.id, widget.stage.isBoss);

    _controller = GameController(
      context: context,
      user: widget.user,
      stage: widget.stage,
      onGameOver: () {
        setState(() {});
      },
      vsync: this,
    );

    _animTimerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )..repeat();

    _controller.start();
  }

  @override
  void dispose() {
    _animTimerController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTutorialComplete() async {
    setState(() {
      _showTutorial = false;
      _controller.waveTransitionTimer = 0.0;
    });
    if (widget.user.id != null) {
      await UserDAO.instance.markTutorialCompleted(widget.user.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Custom 60FPS Game Painter Canvas
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animTimerController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: GamePainter(
                      controller: _controller,
                      animTime: _animTimerController.value * 100,
                    ),
                  );
                },
              ),
            ),

            // 2. Top HUD Bar
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: _buildTopHud(),
            ),

            // 3. Boss Top HP Bar (if Boss Stage)
            if (widget.stage.isBoss && _controller.enemies.any((e) => e.isBoss))
              Positioned(
                top: 75,
                left: 32,
                right: 32,
                child: _buildBossHpBar(),
              ),

            // 4. Wave Banner Overlay (Dismissible & Top-Aligned, never blocking center)
            if (!_showTutorial && _controller.waveTransitionTimer > 0)
              Positioned(
                top: widget.stage.isBoss ? 135 : 72,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _controller.waveTransitionTimer = 0.0;
                      });
                    },
                    child: _buildWaveBanner(),
                  ),
                ),
              ),
            if (_controller.comboCount > 1)
              Positioned(
                top: 130,
                left: 20,
                child: _buildComboCounter(),
              ),

            // 6. Bottom-Left Virtual Joystick
            Positioned(
              bottom: 24,
              left: 24,
              child: VirtualJoystick(
                onMove: (angle, dist) => _controller.updateJoystick(angle, dist),
                onRelease: () => _controller.releaseJoystick(),
              ),
            ),

            // 7. Bottom-Right Action & Skill Buttons
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildActionControls(),
            ),

            // 8. Tutorial Overlay
            if (_showTutorial)
              Positioned.fill(
                child: TutorialOverlay(
                  onComplete: _onTutorialComplete,
                ),
              ),

            // 9. Pause Modal
            if (_controller.state == GameState.paused)
              Positioned.fill(
                child: PauseModal(
                  onResume: () => _controller.resumeGame(),
                  onRestart: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GamePlayScreen(user: widget.user, stage: widget.stage),
                      ),
                    );
                  },
                  onQuit: () => Navigator.pop(context),
                ),
              ),

            // 10. Victory / Defeat Modal
            if (_controller.state == GameState.victory || _controller.state == GameState.defeat)
              Positioned.fill(
                child: StageResultModal(
                  isVictory: _controller.state == GameState.victory,
                  stage: widget.stage,
                  user: widget.user,
                  score: _controller.currentScore,
                  timeSeconds: _controller.elapsedTime.toInt(),
                  maxCombo: _controller.maxCombo,
                  kills: _controller.totalKills,
                  hpPercent: _controller.hero.currentHp / _controller.hero.maxHp,
                  onRetry: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GamePlayScreen(user: widget.user, stage: widget.stage),
                      ),
                    );
                  },
                  onNextStage: () {
                    final nextStageId = widget.stage.id + 1;
                    final nextStage = StageModel.getStageById(nextStageId);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GamePlayScreen(user: widget.user, stage: nextStage),
                      ),
                    );
                  },
                  onReturnHub: () => Navigator.pop(context),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHud() {
    final hero = _controller.hero;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Avatar & Level Badge
        Stack(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.frostGradient,
                border: Border.all(color: AppColors.white, width: 2),
                boxShadow: [
                  BoxShadow(color: AppColors.frostPrimary.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: const Center(
                child: Icon(Icons.shield_moon_rounded, color: AppColors.white, size: 28),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: LevelBadge(level: widget.user.heroLevel),
            ),
          ],
        ),
        const SizedBox(width: 12),

        // Reusable HP & MP Gauges
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatBar(
                current: hero.currentHp,
                max: hero.maxHp,
                color: AppColors.healthRed,
                icon: Icons.favorite_rounded,
                label: 'HP',
              ),
              const SizedBox(height: 4),
              StatBar(
                current: hero.currentMp,
                max: hero.maxMp,
                color: AppColors.manaBlue,
                icon: Icons.bolt_rounded,
                label: 'MP',
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Potion Button
        GestureDetector(
          onTap: () => _controller.usePotion(),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            radius: 12,
            borderColor: AppColors.potionGreen,
            child: Row(
              children: [
                const Icon(Icons.medical_services_rounded, color: AppColors.potionGreen, size: 18),
                const SizedBox(width: 4),
                Text(
                  'x${hero.potCount}',
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Pause Button
        GestureDetector(
          onTap: () => _controller.pauseGame(),
          child: const GlassCard(
            padding: EdgeInsets.all(8),
            radius: 12,
            borderColor: AppColors.white30,
            child: Icon(Icons.pause_rounded, color: AppColors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildBossHpBar() {
    final boss = _controller.enemies.firstWhere((e) => e.isBoss);
    final hpPercent = (boss.currentHp / boss.maxHp).clamp(0.0, 1.0);

    String phaseText = 'PHASE 1: SYMBIOTE CLAW';
    Color phaseColor = AppColors.bossPrimary;
    switch (boss.bossPhase) {
      case BossPhase.phase1:
        phaseText = 'PHASE 1: SYMBIOTE CLAW';
        phaseColor = AppColors.bossPrimary;
        break;
      case BossPhase.phase2:
        phaseText = 'PHASE 2: CARNAGE RAGE';
        phaseColor = AppColors.bossPhase2;
        break;
      case BossPhase.phase3:
        phaseText = 'PHASE 3: APOCALYPSE TENDRIL';
        phaseColor = AppColors.bossPhase3;
        break;
    }

    return GlassCard(
      padding: const EdgeInsets.all(8),
      radius: 14,
      borderColor: phaseColor,
      glowColor: phaseColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.healthRed, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    boss.name.toUpperCase(),
                    style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                phaseText,
                style: TextStyle(color: phaseColor, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.white24),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: hpPercent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: phaseColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBanner() {
    String dialogueSpeaker = 'SPIDER-MAN';
    String dialogueQuote = 'Hostile street thugs & Oscorp drones incoming! Web them up!';
    Color bannerColor = AppColors.spiderRedLight;
    IconData speakerIcon = Icons.shield_moon_rounded;

    if (widget.stage.isBoss) {
      dialogueSpeaker = 'VENOM OVERLORD';
      dialogueQuote = 'WE WILL RIP THIS CITY APART, SPIDER-MAN!';
      bannerColor = AppColors.carnageCrimson;
      speakerIcon = Icons.dangerous_rounded;
    } else if (_controller.currentWaveIndex == 1) {
      dialogueSpeaker = 'SPIDER-MAN';
      dialogueQuote = 'Reinforcements closing in! Charge up the Symbiote Surge!';
      bannerColor = AppColors.webFluidBlue;
    } else if (_controller.currentWaveIndex == 2) {
      dialogueSpeaker = 'SPIDER-MAN';
      dialogueQuote = 'Final wave of this district! Unleash the Web-Zip Slam!';
      bannerColor = AppColors.electricGold;
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        radius: 18,
        borderColor: bannerColor,
        glowColor: bannerColor,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bannerColor.withValues(alpha: 0.2),
                border: Border.all(color: bannerColor),
              ),
              child: Icon(speakerIcon, color: bannerColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dialogueSpeaker,
                        style: TextStyle(color: bannerColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      Text(
                        _controller.currentWaveBanner,
                        style: const TextStyle(color: AppColors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dialogueQuote,
                    style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComboCounter() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      radius: 12,
      borderColor: AppColors.comboOrange,
      glowColor: AppColors.comboOrange,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flash_on_rounded, color: AppColors.comboOrange, size: 20),
          const SizedBox(width: 4),
          Text(
            'COMBO x${_controller.comboCount}!',
            style: const TextStyle(
              color: AppColors.comboOrange,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionControls() {
    final hero = _controller.hero;
    final frostSkill = hero.skills.firstWhere((s) => s.id == SkillId.frostNova);
    final fireSkill = hero.skills.firstWhere((s) => s.id == SkillId.infernoComet);
    final voidSkill = hero.skills.firstWhere((s) => s.id == SkillId.voidDash);

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Positioned(
            bottom: 30,
            right: 120,
            child: _buildSkillButton(frostSkill),
          ),
          Positioned(
            bottom: 100,
            right: 100,
            child: _buildSkillButton(fireSkill),
          ),
          Positioned(
            bottom: 120,
            right: 20,
            child: _buildSkillButton(voidSkill),
          ),
          Positioned(
            bottom: 0,
            right: 110,
            child: _buildUltimateButton(),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _buildAttackButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillButton(SkillModel skill) {
    return GestureDetector(
      onTap: () => _controller.castSkill(skill.id),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.bgGlassDark,
          border: Border.all(
            color: skill.isReady ? skill.color : AppColors.white24,
            width: 2,
          ),
          boxShadow: skill.isReady
              ? [
                  BoxShadow(
                    color: skill.color.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(skill.icon, color: skill.isReady ? AppColors.white : AppColors.white38, size: 24),
            if (!skill.isReady)
              Positioned.fill(
                child: CircularProgressIndicator(
                  value: skill.cooldownProgress,
                  strokeWidth: 3,
                  backgroundColor: AppColors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(skill.color),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttackButton() {
    return GestureDetector(
      onTap: () => _controller.performBasicAttack(),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              AppColors.frostGlow,
              AppColors.frostSecondary,
              AppColors.frostDark,
            ],
          ),
          border: Border.all(color: AppColors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.frostPrimary.withValues(alpha: 0.6),
              blurRadius: 18,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.colorize_rounded,
            color: AppColors.white,
            size: 38,
          ),
        ),
      ),
    );
  }

  Widget _buildUltimateButton() {
    final hero = _controller.hero;
    final isFull = hero.ultimateCharge >= 100.0;

    return GestureDetector(
      onTap: () => _controller.castUltimate(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isFull ? AppColors.celestialGold : AppColors.black30,
          border: Border.all(
            color: isFull ? AppColors.white : AppColors.white24,
            width: 2,
          ),
          boxShadow: isFull
              ? const [
                  BoxShadow(color: AppColors.celestialGold, blurRadius: 16, spreadRadius: 3),
                ]
              : [],
        ),
        child: Center(
          child: Icon(
            Icons.auto_awesome_rounded,
            color: isFull ? AppColors.black : AppColors.white38,
            size: 20,
          ),
        ),
      ),
    );
  }
}
