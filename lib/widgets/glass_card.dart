import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color borderColor;
  final Color glowColor;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double blurSigma;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.radius = 20.0,
    this.borderColor = AppColors.borderGlass,
    this.glowColor = AppColors.transparent,
    this.backgroundColor = AppColors.bgGlass,
    this.padding = const EdgeInsets.all(20.0),
    this.margin,
    this.blurSigma = 10.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          if (glowColor != AppColors.transparent)
            BoxShadow(
              color: glowColor.withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          const BoxShadow(
            color: AppColors.shadowDeep,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
