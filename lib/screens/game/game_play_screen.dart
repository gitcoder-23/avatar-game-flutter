import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/database/user_dao.dart';
import '../../core/theme/colors.dart';
import '../../game/engine_3d/camera3d.dart';
import '../../game/engine_3d/vector3d.dart';
import '../../game/game_3d_painter.dart';
import '../../game/game_controller.dart';
import '../../models/skill_model.dart';
import '../../models/stage_model.dart';
import '../../models/user_model.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/level_badge.dart';
import '../../widgets/stat_bar.dart';
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
  final Camera3D _camera = Camera3D();
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

    _controller.addListener(_onControllerTick);
    _controller.start();
  }

  void _onControllerTick() {
    final heroPos3D = Vector3D(
      _controller.hero.x - 1200.0,
      0.0,
      _controller.hero.y - 800.0,
    );
    _camera.update(heroPos3D, _controller.hero.facingAngle, 0.016);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerTick);
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
            // 1. Custom 60FPS 3D Hardware Accelerated Game Canvas
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animTimerController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: Game3DPainter(
                      controller: _controller,
                      camera: _camera,
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

            // 5. Combo Counter Display
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
              child: _buildVirtualJoystick(),
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
                gradient: AppColors.spiderGradient,
                border: Border.all(color: AppColors.white, width: 2),
                boxShadow: [
                  BoxShadow(color: AppColors.spiderGlow.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2),
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
          child: GlassCard(
            padding: const EdgeInsets.all(8),
            radius: 12,
            borderColor: AppColors.white38,
            child: const Icon(Icons.pause_rounded, color: AppColors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildBossHpBar() {
    final boss = _controller.enemies.firstWhere((e) => e.isBoss);
    final hpPercent = (boss.currentHp / boss.maxHp).clamp(0.0, 1.0);

    String bossTitle = 'VENOM SYMBIOTE OVERLORD';
    Color bossColor = AppColors.bossPhase3;
    if (widget.stage.id == 3) {
      bossTitle = 'SUPERVILLAIN: ELECTRO ⚡';
      bossColor = AppColors.electricGold;
    } else if (widget.stage.id == 5) {
      bossTitle = 'SUPERVILLAIN: DR. OCTOPUS 🐙';
      bossColor = AppColors.neonCyan;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              bossTitle,
              style: TextStyle(
                color: bossColor,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 2.0,
              ),
            ),
            Text(
              '${(hpPercent * 100).toInt()}%',
              style: TextStyle(
                color: bossColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.black78,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: bossColor.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(color: bossColor.withValues(alpha: 0.3), blurRadius: 8),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: hpPercent,
              backgroundColor: AppColors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(bossColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaveBanner() {
    String dialogueSpeaker = 'SPIDER-MAN';
    String dialogueQuote = 'Hostile street thugs & Oscorp drones incoming! Web them up!';
    Color bannerColor = AppColors.spiderRedLight;
    IconData speakerIcon = Icons.shield_moon_rounded;

    if (widget.stage.id == 3 && widget.stage.isBoss) {
      dialogueSpeaker = 'ELECTRO';
      dialogueQuote = 'You cannot ground 100,000 Volts, Spider! Time to get fried!';
      bannerColor = AppColors.electricGold;
      speakerIcon = Icons.flash_on_rounded;
    } else if (widget.stage.id == 5 && widget.stage.isBoss) {
      dialogueSpeaker = 'DR. OCTOPUS';
      dialogueQuote = 'The power of the sun in my mechanical arms! You cannot stop progress, Peter!';
      bannerColor = AppColors.neonCyan;
      speakerIcon = Icons.precision_manufacturing_rounded;
    } else if (widget.stage.id == 6) {
      dialogueSpeaker = 'VENOM';
      dialogueQuote = 'WE ARE VENOM! WE WILL DEVOUR YOUR CITY!';
      bannerColor = AppColors.carnageCrimson;
      speakerIcon = Icons.dangerous_rounded;
    } else if (_controller.currentWaveIndex == 1) {
      dialogueSpeaker = 'SPIDER-MAN';
      dialogueQuote = 'Reinforcements closing in! Charge up the Symbiote Surge!';
      bannerColor = AppColors.webFluidBlue;
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

  Widget _buildVirtualJoystick() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.bgDarkCard.withValues(alpha: 0.45),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.neonCyan.withValues(alpha: 0.15), blurRadius: 16),
        ],
      ),
      child: GestureDetector(
        onPanStart: (details) => _handleJoystick(details.localPosition),
        onPanUpdate: (details) => _handleJoystick(details.localPosition),
        onPanEnd: (_) => _controller.releaseJoystick(),
        child: Center(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.spiderGradient,
              boxShadow: [
                BoxShadow(color: AppColors.spiderGlow.withValues(alpha: 0.6), blurRadius: 10),
              ],
            ),
            child: const Icon(Icons.navigation_rounded, color: AppColors.white, size: 24),
          ),
        ),
      ),
    );
  }

  void _handleJoystick(Offset localPos) {
    const radius = 65.0;
    final dx = localPos.dx - radius;
    final dy = localPos.dy - radius;
    final dist = (Offset(dx, dy).distance / radius).clamp(0.0, 1.0);
    final angle = Offset(dx, dy).direction;
    _controller.updateJoystick(angle, dist);
  }

  Widget _buildActionControls() {
    final hero = _controller.hero;
    final webSkill = hero.skills.firstWhere((s) => s.id == SkillId.frostNova);
    final surgeSkill = hero.skills.firstWhere((s) => s.id == SkillId.infernoComet);
    final zipSkill = hero.skills.firstWhere((s) => s.id == SkillId.voidDash);

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Positioned(
            bottom: 30,
            right: 120,
            child: _buildSkillButton(webSkill),
          ),
          Positioned(
            bottom: 100,
            right: 100,
            child: _buildSkillButton(surgeSkill),
          ),
          Positioned(
            bottom: 120,
            right: 20,
            child: _buildSkillButton(zipSkill),
          ),
          Positioned(
            bottom: 0,
            right: 110,
            child: _buildUltimateButton(hero),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _buildBasicAttackButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicAttackButton() {
    return GestureDetector(
      onTap: () => _controller.performBasicAttack(),
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.spiderGradient,
          border: Border.all(color: AppColors.white, width: 2.5),
          boxShadow: [
            BoxShadow(color: AppColors.spiderGlow.withValues(alpha: 0.8), blurRadius: 16, spreadRadius: 2),
          ],
        ),
        child: const Center(
          child: Icon(Icons.colorize_rounded, color: AppColors.white, size: 34),
        ),
      ),
    );
  }

  Widget _buildSkillButton(SkillModel skill) {
    final isReady = skill.isReady && _controller.hero.currentMp >= skill.manaCost;

    return GestureDetector(
      onTap: isReady ? () => _controller.castSkill(skill.id) : null,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isReady ? AppColors.spiderRedLight.withValues(alpha: 0.3) : AppColors.black45,
          border: Border.all(
            color: isReady ? AppColors.spiderRedLight : AppColors.white24,
            width: 1.5,
          ),
          boxShadow: isReady
              ? [BoxShadow(color: AppColors.spiderGlow.withValues(alpha: 0.5), blurRadius: 8)]
              : [],
        ),
        child: Center(
          child: Icon(
            skill.icon,
            color: isReady ? AppColors.white : AppColors.white38,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildUltimateButton(dynamic hero) {
    final isReady = hero.ultimateCharge >= 100.0;

    return GestureDetector(
      onTap: isReady ? () => _controller.castUltimate() : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isReady ? AppColors.symbioteGradient : null,
          color: isReady ? null : AppColors.black45,
          border: Border.all(
            color: isReady ? AppColors.carnageCrimson : AppColors.white24,
            width: 1.5,
          ),
          boxShadow: isReady
              ? [BoxShadow(color: AppColors.carnageCrimson.withValues(alpha: 0.8), blurRadius: 12)]
              : [],
        ),
        child: Center(
          child: Icon(
            Icons.auto_awesome_rounded,
            color: isReady ? AppColors.white : AppColors.white38,
            size: 20,
          ),
        ),
      ),
    );
  }
}
