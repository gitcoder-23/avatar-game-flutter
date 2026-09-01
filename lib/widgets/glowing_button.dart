import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../utils/function.dart';

class GlowingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? glowColor;
  final bool isLoading;
  final double height;
  final double radius;
  final double fontSize;
  final bool isOutlined;
  final EdgeInsetsGeometry padding;

  const GlowingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor = AppColors.frostPrimary,
    this.textColor = AppColors.black,
    this.glowColor,
    this.isLoading = false,
    this.height = 50.0,
    this.radius = 14.0,
    this.fontSize = 15.0,
    this.isOutlined = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGlow = glowColor ?? backgroundColor;

    if (isOutlined) {
      return OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: backgroundColor,
          side: BorderSide(color: backgroundColor, width: 1.5),
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
        onPressed: isLoading ? null : () {
          GameUtils.hapticLight();
          onPressed?.call();
        },
        icon: icon != null ? Icon(icon, size: fontSize + 2) : const SizedBox.shrink(),
        label: isLoading
            ? SizedBox(
                width: fontSize,
                height: fontSize,
                child: CircularProgressIndicator(color: backgroundColor, strokeWidth: 2),
              )
            : Text(
                text,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, letterSpacing: 0.8),
              ),
      );
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: effectiveGlow.withValues(alpha: 0.4),
                  blurRadius: 14,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: AppColors.white12,
          disabledForegroundColor: AppColors.white38,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
        onPressed: isLoading ? null : () {
          GameUtils.hapticLight();
          onPressed?.call();
        },
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: textColor, strokeWidth: 2.5),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: fontSize + 2, color: textColor),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
