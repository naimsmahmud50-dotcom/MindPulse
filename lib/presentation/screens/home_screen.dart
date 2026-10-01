import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/study_models.dart';
import '../bloc/deck/deck_bloc.dart';
import '../bloc/quiz/quiz_bloc.dart';
import '../widgets/chunky_3d_button.dart';
import '../widgets/gamified_progress_bar.dart';
import '../widgets/streak_header_widget.dart';
import 'document_upload_screen.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Gamified Top Bar
            const StreakHeaderWidget(
              streakDays: 7,
              currentXP: 480,
              hearts: 3,
            ),

            Expanded(
              child: BlocBuilder<DeckBloc, DeckState>(
                builder: (context, state) {
                  if (state is DeckLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (state is DeckLoaded) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Daily Goal Card
                          _buildDailyGoalCard(context),

                          const SizedBox(height: 24),

                          // AI Document Importer Simulator Banner
                          _buildAiDocBanner(context),

                          const SizedBox(height: 28),

                          // Section Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Study Decks',
                                style: TextStyle(
                                  color: AppColors.darkTextPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.darkCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.darkBorder),
                                ),
                                child: Text(
                                  '${state.decks.length} Decks Ready',
                                  style: const TextStyle(
                                    color: AppColors.darkTextSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Decks List
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.decks.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final deck = state.decks[index];
                              return _buildDeckCard(context, deck);
                            },
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    );
                  }

                  return const Center(child: Text('No decks available'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyGoalCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: AppColors.streakAmber, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'DAILY PULSE GOAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '3 / 5 Cards',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Keep your 7-day learning streak alive!',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const GamifiedProgressBar(
            value: 0.6,
            height: 10,
            fillColor: AppColors.streakAmber,
            backgroundColor: Colors.black26,
          ),
        ],
      ),
    );
  }

  Widget _buildAiDocBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DocumentUploadScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.info, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generate from Document',
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'AI turns any PDF or note into flashcards & quizzes.',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.darkTextSecondary, size: 16),
        ],
      ),
    ),
  );
}

  Widget _buildDeckCard(BuildContext context, StudyDeck deck) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.darkBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category tag & card count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  deck.category.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.style_rounded, size: 16, color: AppColors.darkTextSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${deck.flashcards.length} Cards',
                    style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title & Description
          Text(
            deck.title,
            style: const TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            deck.description,
            style: const TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Mastery Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mastery Progress',
                style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                '${(deck.progress * 100).toInt()}%',
                style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GamifiedProgressBar(
            value: deck.progress,
            height: 8,
            fillColor: AppColors.success,
          ),

          const SizedBox(height: 20),

          // Dual Action Buttons: Study Cards vs Take Quiz
          Row(
            children: [
              Expanded(
                child: Chunky3DButton(
                  height: 46,
                  color: AppColors.primary,
                  shadowColor: AppColors.primaryDark,
                  onPressed: () {
                    context.read<DeckBloc>().add(SelectDeckEvent(deck.id));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FlashcardScreen(deck: deck),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flip_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Flashcards',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Chunky3DButton(
                  height: 46,
                  color: AppColors.accentOrange,
                  shadowColor: AppColors.accentOrangeDark,
                  onPressed: () {
                    context.read<QuizBloc>().add(StartQuizEvent(deck));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QuizScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Play Quiz',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
