import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

class LevelBadge extends StatelessWidget {
  final int level;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  const LevelBadge({
    super.key,
    required this.level,
    this.backgroundColor = AppColors.goldCurrency,
    this.textColor = AppColors.black,
    this.fontSize = 9.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.black, width: 0.8),
      ),
      child: Text(
        'Lv.$level',
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
