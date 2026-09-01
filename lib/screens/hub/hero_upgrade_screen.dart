import 'package:flutter/material.dart';
import '../../core/database/user_dao.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/game_theme.dart';
import '../../models/skill_model.dart';
import '../../models/user_model.dart';

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
          'HERO SANCTUARY',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 18,
          ),
        ),
        actions: [
          // Currency Badges
          Row(
            children: [
              _currencyBadge(Icons.monetization_on_rounded, '${_user.gold}', AppColors.goldCurrency),
              const SizedBox(width: 8),
              _currencyBadge(Icons.diamond_rounded, '${_user.crystals}', AppColors.crystalCurrency),
              const SizedBox(width: 16),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.frostPrimary,
          labelColor: AppColors.frostPrimary,
          unselectedLabelColor: AppColors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.fitness_center_rounded), text: 'ATTRIBUTES'),
            Tab(icon: Icon(Icons.auto_awesome_rounded), text: 'ELEMENTAL SKILLS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Attributes Upgrade
          _buildAttributesTab(),
          // Tab 2: Elemental Skills Codex
          _buildSkillsTab(),
        ],
      ),
    );
  }

  Widget _buildAttributesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Hero Overview Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: GameTheme.glassCardDecoration(
              radius: 20,
              borderColor: AppColors.frostPrimary,
              glowColor: AppColors.frostPrimary,
            ),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.frostGradient,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.shield_moon_rounded, color: AppColors.white, size: 36),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level ${_user.heroLevel} Elemental Avatar',
                        style: const TextStyle(color: AppColors.frostPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (_user.heroXp / _user.requiredXpForNextLevel).clamp(0.0, 1.0),
                        backgroundColor: AppColors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.frostPrimary),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'XP: ${_user.heroXp} / ${_user.requiredXpForNextLevel}',
                        style: const TextStyle(color: AppColors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _upgradeCard(
            title: 'Attack Power (ATK)',
            currentValue: '${(45 + _user.bonusAtk).toInt()} DMG',
            bonusText: '+12 per level',
            level: _user.atkLevel,
            cost: _user.upgradeCostAtk,
            icon: Icons.colorize_rounded,
            color: AppColors.healthRedLight,
            onUpgrade: _upgradeAtk,
          ),
          const SizedBox(height: 14),

          _upgradeCard(
            title: 'Maximum Health (HP)',
            currentValue: '${(500 + _user.bonusMaxHp).toInt()} HP',
            bonusText: '+60 per level',
            level: _user.hpLevel,
            cost: _user.upgradeCostHp,
            icon: Icons.favorite_rounded,
            color: AppColors.healthRed,
            onUpgrade: _upgradeHp,
          ),
          const SizedBox(height: 14),

          _upgradeCard(
            title: 'Defense Armor (DEF)',
            currentValue: '${(15 + _user.bonusDef).toInt()} DEF',
            bonusText: '+6 per level',
            level: _user.defLevel,
            cost: _user.upgradeCostDef,
            icon: Icons.shield_rounded,
            color: AppColors.manaBlueLight,
            onUpgrade: _upgradeDef,
          ),
          const SizedBox(height: 14),

          _upgradeCard(
            title: 'Mana Pool (MP)',
            currentValue: '${(200 + _user.bonusMaxMp).toInt()} MP',
            bonusText: '+30 per level',
            level: _user.mpLevel,
            cost: _user.upgradeCostMp,
            icon: Icons.bolt_rounded,
            color: AppColors.frostPrimary,
            onUpgrade: _upgradeMp,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsTab() {
    final skills = SkillModel.getDefaultSkills();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: GameTheme.glassCardDecoration(
            radius: 18,
            borderColor: skill.color,
            glowColor: skill.color,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: skill.color.withValues(alpha: 0.2),
                      border: Border.all(color: skill.color, width: 2),
                    ),
                    child: Center(
                      child: Icon(skill.icon, color: skill.color, size: 26),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skill.name.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Element: ${skill.element.name.toUpperCase()}',
                          style: TextStyle(color: skill.color, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.black45,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.white24),
                    ),
                    child: Text(
                      '${skill.cooldownSeconds}s CD',
                      style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                skill.description,
                style: const TextStyle(color: AppColors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mana Cost: ${skill.manaCost.toInt()} MP', style: const TextStyle(color: AppColors.frostPrimary, fontSize: 12)),
                  Text('Damage Mult: ${skill.damageMultiplier}x ATK', style: const TextStyle(color: AppColors.celestialGold, fontSize: 12, fontWeight: FontWeight.bold)),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: GameTheme.glassCardDecoration(
        radius: 16,
        borderColor: color.withValues(alpha: 0.6),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.black45,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Lv.$level', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$currentValue ($bonusText)',
                  style: const TextStyle(color: AppColors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: canAfford ? color : AppColors.white12,
              foregroundColor: canAfford ? AppColors.black : AppColors.white38,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: canAfford ? onUpgrade : null,
            icon: const Icon(Icons.monetization_on_rounded, size: 16),
            label: Text(
              '$cost',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _currencyBadge(IconData icon, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.black45,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            amount,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
