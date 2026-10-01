import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/quiz/quiz_bloc.dart';
import '../widgets/chunky_3d_button.dart';
import '../widgets/gamified_progress_bar.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state is QuizCompleted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => QuizResultScreen(result: state),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is! QuizInProgress) {
          return const Scaffold(
            backgroundColor: AppColors.darkBackground,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final question = state.currentQuestion;

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          body: SafeArea(
            child: Column(
              children: [
                // Top Quiz Stats Bar (Lives + Progress + Combo)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.darkTextSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: GamifiedProgressBar(
                          value: state.progress,
                          height: 12,
                          fillColor: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Lives Counter
                      Row(
                        children: List.generate(
                          3,
                          (index) => Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Icon(
                              Icons.favorite_rounded,
                              color: index < state.lives ? AppColors.error : AppColors.darkBorder,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Combo Multiplier Banner (if > 1)
                if (state.currentCombo > 1)
                  Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '🔥 ${state.currentCombo}x COMBO STREAK!',
                      style: const TextStyle(
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                // Question Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      question.question,
                      style: const TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Options List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    itemCount: question.options.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final optionText = question.options[index];
                      final isSelected = state.selectedOptionIndex == index;

                      Color cardColor = AppColors.darkCard;
                      Color borderColor = AppColors.darkBorder;
                      Color textColor = AppColors.darkTextPrimary;

                      if (state.isAnswerSubmitted) {
                        if (index == question.correctOptionIndex) {
                          cardColor = AppColors.success.withValues(alpha: 0.2);
                          borderColor = AppColors.success;
                          textColor = Colors.white;
                        } else if (isSelected && !state.isCurrentAnswerCorrect!) {
                          cardColor = AppColors.error.withValues(alpha: 0.2);
                          borderColor = AppColors.error;
                          textColor = Colors.white;
                        }
                      } else if (isSelected) {
                        cardColor = AppColors.primary.withValues(alpha: 0.2);
                        borderColor = AppColors.primary;
                        textColor = Colors.white;
                      }

                      return GestureDetector(
                        onTap: () {
                          if (!state.isAnswerSubmitted) {
                            context.read<QuizBloc>().add(SelectOptionEvent(index));
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: borderColor, width: 2.0),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: borderColor.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index), // A, B, C, D
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Feedback Drawer & Action Button
                _buildBottomActionDrawer(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActionDrawer(BuildContext context, QuizInProgress state) {
    if (!state.isAnswerSubmitted) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
          border: Border(top: BorderSide(color: AppColors.darkBorder, width: 1.5)),
        ),
        child: Chunky3DButton(
          color: state.selectedOptionIndex != null ? AppColors.success : Colors.grey.shade800,
          shadowColor: state.selectedOptionIndex != null ? AppColors.successDark : Colors.grey.shade900,
          onPressed: state.selectedOptionIndex != null
              ? () => context.read<QuizBloc>().add(SubmitAnswerEvent())
              : null,
          child: const Text(
            'CHECK ANSWER',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
              letterSpacing: 1.0,
            ),
          ),
        ),
      );
    }

    // Feedback State
    final bool isCorrect = state.isCurrentAnswerCorrect!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.success.withValues(alpha: 0.12) : AppColors.error.withValues(alpha: 0.12),
        border: Border(
          top: BorderSide(
            color: isCorrect ? AppColors.success : AppColors.error,
            width: 2.0,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isCorrect ? AppColors.success : AppColors.error,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                isCorrect ? 'Brilliant! +100 XP' : 'Incorrect!',
                style: TextStyle(
                  color: isCorrect ? AppColors.success : AppColors.error,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.currentQuestion.explanation,
            style: const TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Chunky3DButton(
            color: isCorrect ? AppColors.success : AppColors.error,
            shadowColor: isCorrect ? AppColors.successDark : AppColors.errorDark,
            onPressed: () => context.read<QuizBloc>().add(NextQuestionEvent()),
            child: Text(
              state.isLastQuestion ? 'SEE RESULTS 🎉' : 'CONTINUE',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
