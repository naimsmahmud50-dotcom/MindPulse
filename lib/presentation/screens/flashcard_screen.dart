import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/study_models.dart';
import '../bloc/deck/deck_bloc.dart';
import '../bloc/quiz/quiz_bloc.dart';
import '../widgets/chunky_3d_button.dart';
import '../widgets/flip_card_widget.dart';
import '../widgets/gamified_progress_bar.dart';
import '../widgets/streak_header_widget.dart';
import 'quiz_screen.dart';

class FlashcardScreen extends StatefulWidget {
  final StudyDeck deck;

  const FlashcardScreen({super.key, required this.deck});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _currentIndex = 0;

  void _nextCard() {
    if (_currentIndex < widget.deck.flashcards.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _showCompletionDialog();
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.primary, width: 2),
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.workspace_premium_rounded, color: AppColors.streakAmber, size: 32),
            SizedBox(width: 8),
            Text(
              'Deck Reviewed!',
              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkTextPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You reviewed all flashcards in this deck! Ready to test your knowledge in the Quiz Arena?',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.streakAmber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '+50 XP Earned 💎',
                style: TextStyle(
                  color: AppColors.streakAmber,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              Navigator.pop(context);
            },
            child: const Text('Back to Home', style: TextStyle(color: AppColors.darkTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<QuizBloc>().add(StartQuizEvent(widget.deck));
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const QuizScreen()),
              );
            },
            child: const Text('Start Quiz ⚡', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: BlocBuilder<DeckBloc, DeckState>(
          builder: (context, state) {
            StudyDeck currentDeck = widget.deck;
            if (state is DeckLoaded) {
              currentDeck = state.decks.firstWhere(
                (d) => d.id == widget.deck.id,
                orElse: () => widget.deck,
              );
            }

            final currentCard = currentDeck.flashcards[_currentIndex];
            final progress = (_currentIndex + 1) / currentDeck.flashcards.length;

            return Column(
              children: [
                // Top Header
                StreakHeaderWidget(
                  onBack: () => Navigator.pop(context),
                ),

                // Deck Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Card ${_currentIndex + 1} of ${currentDeck.flashcards.length}',
                            style: const TextStyle(
                              color: AppColors.darkTextSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            currentDeck.title,
                            style: const TextStyle(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GamifiedProgressBar(
                        value: progress,
                        height: 10,
                        fillColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 3D Flip Card Widget
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: FlipCardWidget(
                    card: currentCard,
                    onToggleMastered: () {
                      context.read<DeckBloc>().add(
                            ToggleFlashcardMasteredEvent(
                              deckId: currentDeck.id,
                              flashcardId: currentCard.id,
                            ),
                          );
                    },
                  ),
                ),

                const Spacer(),

                // Bottom Dual Control Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    children: [
                      if (_currentIndex > 0) ...[
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkTextSecondary, size: 18),
                          onPressed: _prevCard,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.darkSurface,
                            padding: const EdgeInsets.all(14),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      // Still Learning Button
                      Expanded(
                        child: Chunky3DButton(
                          height: 52,
                          color: AppColors.darkSurface,
                          shadowColor: AppColors.darkBorder,
                          onPressed: _nextCard,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh_rounded, color: AppColors.darkTextSecondary, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Need Review',
                                style: TextStyle(
                                  color: AppColors.darkTextPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Mastered / Next Button
                      Expanded(
                        child: Chunky3DButton(
                          height: 52,
                          color: AppColors.success,
                          shadowColor: AppColors.successDark,
                          onPressed: () {
                            if (!currentCard.isMastered) {
                              context.read<DeckBloc>().add(
                                    ToggleFlashcardMasteredEvent(
                                      deckId: currentDeck.id,
                                      flashcardId: currentCard.id,
                                    ),
                                  );
                            }
                            _nextCard();
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Mastered! ✨',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
