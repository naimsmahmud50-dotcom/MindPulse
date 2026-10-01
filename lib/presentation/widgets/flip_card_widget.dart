import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/study_models.dart';

class FlipCardWidget extends StatefulWidget {
  final Flashcard card;
  final VoidCallback onToggleMastered;

  const FlipCardWidget({
    super.key,
    required this.card,
    required this.onToggleMastered,
  });

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didUpdateWidget(FlipCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.id != widget.card.id) {
      _controller.reset();
      _showHint = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isUnder = angle > (pi / 2);

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 3D Perspective depth
              ..rotateY(angle),
            child: isUnder
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildBackCard(),
                  )
                : _buildFrontCard(),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 380),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.card.isMastered ? AppColors.success : AppColors.primary.withValues(alpha: 0.4),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.card.isMastered
                ? AppColors.success.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Bar: Card Tag & Mastered Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'QUESTION',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              if (widget.card.isMastered)
                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Mastered',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Question Center Body
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text(
              widget.card.front,
              style: const TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Bottom Hint & Flip Action
          Column(
            children: [
              if (widget.card.hint != null) ...[
                if (_showHint)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.streakAmber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.streakAmber.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '💡 Hint: ${widget.card.hint}',
                      style: const TextStyle(
                        color: AppColors.streakAmber,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => setState(() => _showHint = true),
                    icon: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.streakAmber, size: 16),
                    label: const Text(
                      'Show Hint',
                      style: TextStyle(color: AppColors.streakAmber, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app_rounded, color: AppColors.darkTextSecondary, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Tap card to flip',
                    style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 380),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.5), width: 2.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrange.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'EXPLANATION',
                  style: TextStyle(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  widget.card.isMastered ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                  color: widget.card.isMastered ? AppColors.success : AppColors.darkTextSecondary,
                ),
                onPressed: widget.onToggleMastered,
                tooltip: 'Mark as Mastered',
              ),
            ],
          ),

          // Answer Body
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Text(
                  widget.card.back,
                  style: const TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.card.codeSnippet != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Text(
                      widget.card.codeSnippet!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppColors.info,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Flip back hint
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flip_rounded, color: AppColors.darkTextSecondary, size: 16),
              SizedBox(width: 6),
              Text(
                'Tap to flip back',
                style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
