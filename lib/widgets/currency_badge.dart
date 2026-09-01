import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../utils/function.dart';

class CurrencyBadge extends StatelessWidget {
  final IconData icon;
  final int amount;
  final Color color;
  final bool isCompact;

  const CurrencyBadge({
    super.key,
    required this.icon,
    required this.amount,
    this.color = AppColors.goldCurrency,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = isCompact ? GameUtils.formatCompactNumber(amount) : GameUtils.formatNumber(amount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.black45,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
