import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';
import '../../core/database/user_dao.dart';
import '../../core/theme/colors.dart';
import '../../models/skill_model.dart';
import '../../models/user_model.dart';
import '../../widgets/widgets.dart';

class HeroUpgradeScreen extends StatefulWidget {
  final UserModel user;
  final Function(UserModel updatedUser) onUserUpdated;

  const HeroUpgradeScreen({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<HeroUpgradeScreen> createState() => _HeroUpgradeScreenState();
}

class _HeroUpgradeScreenState extends State<HeroUpgradeScreen> with SingleTickerProviderStateMixin {
  late UserModel _user;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _upgradeAtk() async {
    if (_user.gold < _user.upgradeCostAtk) return;
    AudioService.instance.playUpgrade();
    final updated = _user.copyWith(
      gold: _user.gold - _user.upgradeCostAtk,
      atkLevel: _user.atkLevel + 1,
    );
    await UserDAO.instance.updateUser(updated);
    setState(() => _user = updated);
    widget.onUserUpdated(updated);
  }

  void _upgradeHp() async {
    if (_user.gold < _user.upgradeCostHp) return;
    AudioService.instance.playUpgrade();
    final updated = _user.copyWith(
      gold: _user.gold - _user.upgradeCostHp,
      hpLevel: _user.hpLevel + 1,
    );
    await UserDAO.instance.updateUser(updated);
    setState(() => _user = updated);
    widget.onUserUpdated(updated);
  }

  void _upgradeDef() async {
    if (_user.gold < _user.upgradeCostDef) return;
    AudioService.instance.playUpgrade();
    final updated = _user.copyWith(
      gold: _user.gold - _user.upgradeCostDef,
      defLevel: _user.defLevel + 1,
    );
    await UserDAO.instance.updateUser(updated);
    setState(() => _user = updated);
    widget.onUserUpdated(updated);
  }

  void _upgradeMp() async {
    if (_user.gold < _user.upgradeCostMp) return;
    AudioService.instance.playUpgrade();
    final updated = _user.copyWith(
      gold: _user.gold - _user.upgradeCostMp,
      mpLevel: _user.mpLevel + 1,
    );
    await UserDAO.instance.updateUser(updated);
    setState(() => _user = updated);
    widget.onUserUpdated(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SPIDER-SUIT & GADGET LAB',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 16,
          ),
        ),
        actions: [
          Row(
            children: [
              CurrencyBadge(icon: Icons.monetization_on_rounded, amount: _user.gold, color: AppColors.goldCurrency),
              const SizedBox(width: 8),
              CurrencyBadge(icon: Icons.diamond_rounded, amount: _user.crystals, color: AppColors.crystalCurrency),
              const SizedBox(width: 16),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.spiderRed,
          labelColor: AppColors.spiderRedLight,
          unselectedLabelColor: AppColors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.fitness_center_rounded), text: 'SUIT GADGETS'),
            Tab(icon: Icon(Icons.auto_awesome_rounded), text: 'HERO & SYMBIOTE POWERS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAttributesTab(),
          _buildSkillsTab(),
        ],
      ),
    );
  }

  Widget _buildAttributesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Hero Suit Overview Card
          GlassCard(
            radius: 18,
            borderColor: AppColors.spiderRed,
            glowColor: AppColors.spiderGlow,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.spiderGradient,
                  ),
                  child: const Center(
                    child: Icon(Icons.shield_moon_rounded, color: AppColors.white, size: 34),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user.heroName,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Level ${_user.heroLevel} Web-Slinger',
                        style: const TextStyle(color: AppColors.spiderRedLight, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: (_user.heroXp / _user.requiredXpForNextLevel).clamp(0.0, 1.0),
                        backgroundColor: AppColors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.spiderRed),
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Hero XP: ${_user.heroXp} / ${_user.requiredXpForNextLevel}',
                        style: const TextStyle(color: AppColors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          _upgradeCard(
            title: 'Web-Shooter Voltage (ATK)',
            currentValue: '${(55 + _user.bonusAtk).toInt()} DMG',
            bonusText: '+12 per tier',
            level: _user.atkLevel,
            cost: _user.upgradeCostAtk,
            icon: Icons.colorize_rounded,
            color: AppColors.spiderRedLight,
            onUpgrade: _upgradeAtk,
          ),
          const SizedBox(height: 10),

          _upgradeCard(
            title: 'Kevlar Spider-Suit (HP)',
            currentValue: '${(600 + _user.bonusMaxHp).toInt()} HP',
            bonusText: '+60 per tier',
            level: _user.hpLevel,
            cost: _user.upgradeCostHp,
            icon: Icons.favorite_rounded,
            color: AppColors.healthRed,
            onUpgrade: _upgradeHp,
          ),
          const SizedBox(height: 10),

          _upgradeCard(
            title: 'Nano-Fiber Armor (DEF)',
            currentValue: '${(20 + _user.bonusDef).toInt()} DEF',
            bonusText: '+6 per tier',
            level: _user.defLevel,
            cost: _user.upgradeCostDef,
            icon: Icons.shield_rounded,
            color: AppColors.spiderBlueLight,
            onUpgrade: _upgradeDef,
          ),
          const SizedBox(height: 10),

          _upgradeCard(
            title: 'Web Fluid Cartridges (MP)',
            currentValue: '${(250 + _user.bonusMaxMp).toInt()} FLUID',
            bonusText: '+30 per tier',
            level: _user.mpLevel,
            cost: _user.upgradeCostMp,
            icon: Icons.bolt_rounded,
            color: AppColors.webFluidBlue,
            onUpgrade: _upgradeMp,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsTab() {
    final skills = SkillModel.getDefaultSkills();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        return GlassCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          radius: 16,
          borderColor: skill.color,
          glowColor: skill.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: skill.color.withValues(alpha: 0.2),
                      border: Border.all(color: skill.color, width: 2),
                    ),
                    child: Center(
                      child: Icon(skill.icon, color: skill.color, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skill.name.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Text(
                          'Class: ${skill.element.name.toUpperCase()}',
                          style: TextStyle(color: skill.color, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.black45,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.white24),
                    ),
                    child: Text(
                      '${skill.cooldownSeconds}s CD',
                      style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                skill.description,
                style: const TextStyle(color: AppColors.white70, fontSize: 12, height: 1.35),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Web Fluid Cost: ${skill.manaCost.toInt()} MP', style: const TextStyle(color: AppColors.webFluidBlue, fontSize: 11)),
                  Text('Damage: ${skill.damageMultiplier}x ATK', style: const TextStyle(color: AppColors.electricGold, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _upgradeCard({
    required String title,
    required String currentValue,
    required String bonusText,
    required int level,
    required int cost,
    required IconData icon,
    required Color color,
    required VoidCallback onUpgrade,
  }) {
    final canAfford = _user.gold >= cost;

    return GlassCard(
      padding: const EdgeInsets.all(12),
      radius: 14,
      borderColor: color.withValues(alpha: 0.5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    LevelBadge(level: level, backgroundColor: color),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$currentValue ($bonusText)',
                  style: const TextStyle(color: AppColors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          GlowingButton(
            text: '$cost 🪙',
            height: 36,
            fontSize: 11,
            backgroundColor: canAfford ? color : AppColors.white12,
            textColor: canAfford ? AppColors.black : AppColors.white38,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            onPressed: canAfford ? onUpgrade : null,
          ),
        ],
      ),
    );
  }
}
