import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GamifiedProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final Color fillColor;
  final Color backgroundColor;

  const GamifiedProgressBar({
    super.key,
    required this.value,
    this.height = 14.0,
    this.fillColor = AppColors.success,
    this.backgroundColor = AppColors.darkBorder,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth * clampedValue;

          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: [
                    BoxShadow(
                      color: fillColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // Top Highlight / Shine line for 3D glossy feel
              if (clampedValue > 0.05)
                Positioned(
                  top: 2,
                  left: 4,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    width: (width - 8).clamp(0.0, double.infinity),
                    height: (height / 2) - 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular((height / 2) / 2),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
