import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

typedef JoystickCallback = void Function(double angle, double distance);

class VirtualJoystick extends StatefulWidget {
  final double radius;
  final double knobRadius;
  final JoystickCallback onMove;
  final VoidCallback? onRelease;

  const VirtualJoystick({
    super.key,
    this.radius = 65.0,
    this.knobRadius = 26.0,
    required this.onMove,
    this.onRelease,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _knobPosition = Offset.zero;

  void _handleDrag(Offset localPos) {
    final center = Offset(widget.radius, widget.radius);
    final delta = localPos - center;
    final distance = delta.distance;
    final angle = delta.direction;

    final clampedDistance = min(distance, widget.radius);
    final normalizedDistance = (clampedDistance / widget.radius).clamp(0.0, 1.0);

    setState(() {
      _knobPosition = Offset(
        cos(angle) * clampedDistance,
        sin(angle) * clampedDistance,
      );
    });

    widget.onMove(angle, normalizedDistance);
  }

  void _reset() {
    setState(() {
      _knobPosition = Offset.zero;
    });
    widget.onRelease?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) => _handleDrag(details.localPosition),
      onPanUpdate: (details) => _handleDrag(details.localPosition),
      onPanEnd: (_) => _reset(),
      onPanCancel: () => _reset(),
      child: SizedBox(
        width: widget.radius * 2,
        height: widget.radius * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer Base Ring
            Container(
              width: widget.radius * 2,
              height: widget.radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgGlassDark,
                border: Border.all(
                  color: AppColors.frostPrimary.withValues(alpha: 0.4),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.frostPrimary.withValues(alpha: 0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: widget.radius * 1.2,
                  height: widget.radius * 1.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.frostPrimary.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // Inner Draggable Glowing Knob
            Transform.translate(
              offset: _knobPosition,
              child: Container(
                width: widget.knobRadius * 2,
                height: widget.knobRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      AppColors.frostGlow,
                      AppColors.frostSecondary,
                      AppColors.frostDark,
                    ],
                  ),
                  border: Border.all(color: AppColors.white, width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.frostPrimary.withValues(alpha: 0.55),
                      blurRadius: 14,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.navigation_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
