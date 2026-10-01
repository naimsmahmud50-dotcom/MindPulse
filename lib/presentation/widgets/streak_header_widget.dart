import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StreakHeaderWidget extends StatelessWidget {
  final int streakDays;
  final int currentXP;
  final int hearts;
  final VoidCallback? onBack;

  const StreakHeaderWidget({
    super.key,
    this.streakDays = 5,
    this.currentXP = 340,
    this.hearts = 3,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (onBack != null)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkTextPrimary),
              onPressed: onBack,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.darkCard,
                padding: const EdgeInsets.all(12),
              ),
            )
          else
            const SizedBox(width: 40),

          // Streak Pill
          _buildPill(
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.accentOrange,
            label: '$streakDays Days',
            backgroundColor: AppColors.accentOrange.withValues(alpha: 0.12),
            borderColor: AppColors.accentOrange.withValues(alpha: 0.4),
          ),

          // XP Pill
          _buildPill(
            icon: Icons.diamond_rounded,
            iconColor: AppColors.info,
            label: '$currentXP XP',
            backgroundColor: AppColors.info.withValues(alpha: 0.12),
            borderColor: AppColors.info.withValues(alpha: 0.4),
          ),

          // Hearts / Lives
          _buildPill(
            icon: Icons.favorite_rounded,
            iconColor: AppColors.error,
            label: '$hearts',
            backgroundColor: AppColors.error.withValues(alpha: 0.12),
            borderColor: AppColors.error.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
