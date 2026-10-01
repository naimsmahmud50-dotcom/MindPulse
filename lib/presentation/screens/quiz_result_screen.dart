import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/quiz/quiz_bloc.dart';
import '../widgets/chunky_3d_button.dart';

class QuizResultScreen extends StatefulWidget {
  final QuizCompleted result;

  const QuizResultScreen({super.key, required this.result});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    if (widget.result.isVictory) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isVictory = widget.result.isVictory;
    final int accuracy = widget.result.accuracy.round();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Center Confetti Cannon
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppColors.primary,
                  AppColors.accentOrange,
                  AppColors.streakAmber,
                  AppColors.success,
                  AppColors.info,
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Celebration Trophy / Heart Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isVictory ? AppColors.streakAmber.withValues(alpha: 0.15) : AppColors.error.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isVictory ? AppColors.streakAmber : AppColors.error,
                        width: 2.5,
                      ),
                    ),
                    child: Icon(
                      isVictory ? Icons.emoji_events_rounded : Icons.heart_broken_rounded,
                      color: isVictory ? AppColors.streakAmber : AppColors.error,
                      size: 54,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title & Subtitle
                  Text(
                    isVictory ? 'Quiz Completed! 🎉' : 'Out of Lives! 💔',
                    style: const TextStyle(
                      color: AppColors.darkTextPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isVictory
                        ? 'Incredible mastery on ${widget.result.deck.title}'
                        : 'Review the flashcards and try again to reclaim your streak!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Stats Grid Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.darkBorder, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('SCORE', '${widget.result.finalScore}', Icons.bolt_rounded, AppColors.streakAmber),
                        Container(width: 1, height: 40, color: AppColors.darkBorder),
                        _buildStatItem('ACCURACY', '$accuracy%', Icons.track_changes_rounded, AppColors.success),
                        Container(width: 1, height: 40, color: AppColors.darkBorder),
                        _buildStatItem('COMBO', '${widget.result.maxCombo}x', Icons.local_fire_department_rounded, AppColors.accentOrange),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bottom Action Buttons
                  Chunky3DButton(
                    color: AppColors.accentOrange,
                    shadowColor: AppColors.accentOrangeDark,
                    onPressed: () {
                      context.read<QuizBloc>().add(RestartQuizEvent());
                      Navigator.pop(context);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Try Again ⚡',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Chunky3DButton(
                    color: AppColors.darkSurface,
                    shadowColor: AppColors.darkBorder,
                    onPressed: () {
                      Navigator.pop(context); // Pop result
                      Navigator.pop(context); // Pop to home
                    },
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
