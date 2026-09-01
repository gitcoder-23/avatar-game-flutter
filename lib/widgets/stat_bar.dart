import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

class StatBar extends StatelessWidget {
  final double current;
  final double max;
  final Color color;
  final IconData icon;
  final String label;
  final double height;
  final bool showNumbers;

  const StatBar({
    super.key,
    required this.current,
    required this.max,
    required this.color,
    required this.icon,
    required this.label,
    this.height = 18.0,
    this.showNumbers = true,
  });

  @override
  Widget build(BuildContext context) {
    final percent = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.black60,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: AppColors.white24, width: 1),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: percent,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.white, size: height * 0.65),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(color: AppColors.white, fontSize: height * 0.55, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (showNumbers)
                  Text(
                    '${current.toInt()} / ${max.toInt()}',
                    style: TextStyle(color: AppColors.white, fontSize: height * 0.55, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
