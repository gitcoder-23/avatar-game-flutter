import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

class StarRating extends StatelessWidget {
  final int earnedStars;
  final int maxStars;
  final double starSize;
  final Color activeColor;
  final Color inactiveColor;

  const StarRating({
    super.key,
    required this.earnedStars,
    this.maxStars = 3,
    this.starSize = 22.0,
    this.activeColor = AppColors.goldCurrency,
    this.inactiveColor = AppColors.white24,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final isEarned = index < earnedStars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Icon(
            isEarned ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isEarned ? activeColor : inactiveColor,
            size: starSize,
          ),
        );
      }),
    );
  }
}
