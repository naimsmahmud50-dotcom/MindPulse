import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/study_models.dart';

// EVENTS
abstract class QuizEvent extends Equatable {
  const QuizEvent();
  @override
  List<Object?> get props => [];
}

class StartQuizEvent extends QuizEvent {
  final StudyDeck deck;
  const StartQuizEvent(this.deck);
  @override
  List<Object?> get props => [deck];
}

class SelectOptionEvent extends QuizEvent {
  final int optionIndex;
  const SelectOptionEvent(this.optionIndex);
  @override
  List<Object?> get props => [optionIndex];
}

class SubmitAnswerEvent extends QuizEvent {}

class NextQuestionEvent extends QuizEvent {}

class RestartQuizEvent extends QuizEvent {}

// STATES
abstract class QuizState extends Equatable {
  const QuizState();
  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizInProgress extends QuizState {
  final StudyDeck deck;
  final int currentQuestionIndex;
  final int? selectedOptionIndex;
  final bool isAnswerSubmitted;
  final bool? isCurrentAnswerCorrect;
  final int lives;
  final int score;
  final int currentCombo;
  final int maxCombo;
  final int correctAnswersCount;

  const QuizInProgress({
    required this.deck,
    required this.currentQuestionIndex,
    this.selectedOptionIndex,
    this.isAnswerSubmitted = false,
    this.isCurrentAnswerCorrect,
    this.lives = 3,
    this.score = 0,
    this.currentCombo = 0,
    this.maxCombo = 0,
    this.correctAnswersCount = 0,
  });

  QuizQuestion get currentQuestion => deck.quizQuestions[currentQuestionIndex];
  bool get isLastQuestion => currentQuestionIndex >= deck.quizQuestions.length - 1;
  double get progress => (currentQuestionIndex + 1) / deck.quizQuestions.length;

  QuizInProgress copyWith({
    StudyDeck? deck,
    int? currentQuestionIndex,
    int? selectedOptionIndex,
    bool? isAnswerSubmitted,
    bool? isCurrentAnswerCorrect,
    int? lives,
    int? score,
    int? currentCombo,
    int? maxCombo,
    int? correctAnswersCount,
  }) {
    return QuizInProgress(
      deck: deck ?? this.deck,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedOptionIndex: selectedOptionIndex,
      isAnswerSubmitted: isAnswerSubmitted ?? this.isAnswerSubmitted,
      isCurrentAnswerCorrect: isCurrentAnswerCorrect ?? this.isCurrentAnswerCorrect,
      lives: lives ?? this.lives,
      score: score ?? this.score,
      currentCombo: currentCombo ?? this.currentCombo,
      maxCombo: maxCombo ?? this.maxCombo,
      correctAnswersCount: correctAnswersCount ?? this.correctAnswersCount,
    );
  }

  @override
  List<Object?> get props => [
        deck,
        currentQuestionIndex,
        selectedOptionIndex,
        isAnswerSubmitted,
        isCurrentAnswerCorrect,
        lives,
        score,
        currentCombo,
        maxCombo,
        correctAnswersCount,
      ];
}

class QuizCompleted extends QuizState {
  final StudyDeck deck;
  final int totalQuestions;
  final int correctAnswers;
  final int finalScore;
  final int maxCombo;
  final bool isVictory;

  const QuizCompleted({
    required this.deck,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.finalScore,
    required this.maxCombo,
    required this.isVictory,
  });

  double get accuracy => totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;

  @override
  List<Object?> get props => [deck, totalQuestions, correctAnswers, finalScore, maxCombo, isVictory];
}

// BLOC
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc() : super(QuizInitial()) {
    on<StartQuizEvent>(_onStartQuiz);
    on<SelectOptionEvent>(_onSelectOption);
    on<SubmitAnswerEvent>(_onSubmitAnswer);
    on<NextQuestionEvent>(_onNextQuestion);
    on<RestartQuizEvent>(_onRestartQuiz);
  }

  void _onStartQuiz(StartQuizEvent event, Emitter<QuizState> emit) {
    if (event.deck.quizQuestions.isEmpty) return;
    emit(QuizInProgress(
      deck: event.deck,
      currentQuestionIndex: 0,
      lives: 3,
      score: 0,
      currentCombo: 0,
      maxCombo: 0,
      correctAnswersCount: 0,
    ));
  }

  void _onSelectOption(SelectOptionEvent event, Emitter<QuizState> emit) {
    if (state is QuizInProgress) {
      final current = state as QuizInProgress;
      if (current.isAnswerSubmitted) return; // already submitted
      emit(current.copyWith(selectedOptionIndex: event.optionIndex));
    }
  }

  void _onSubmitAnswer(SubmitAnswerEvent event, Emitter<QuizState> emit) {
    if (state is QuizInProgress) {
      final current = state as QuizInProgress;
      if (current.selectedOptionIndex == null || current.isAnswerSubmitted) return;

      final isCorrect = current.selectedOptionIndex == current.currentQuestion.correctOptionIndex;
      final newCombo = isCorrect ? current.currentCombo + 1 : 0;
      final newMaxCombo = newCombo > current.maxCombo ? newCombo : current.maxCombo;
      final newLives = isCorrect ? current.lives : (current.lives - 1);
      final pointsEarned = isCorrect ? (100 * (1 + (current.currentCombo * 0.2))).round() : 0;
      final newScore = current.score + pointsEarned;
      final newCorrectCount = isCorrect ? current.correctAnswersCount + 1 : current.correctAnswersCount;

      emit(current.copyWith(
        isAnswerSubmitted: true,
        isCurrentAnswerCorrect: isCorrect,
        lives: newLives,
        score: newScore,
        currentCombo: newCombo,
        maxCombo: newMaxCombo,
        correctAnswersCount: newCorrectCount,
      ));
    }
  }

  void _onNextQuestion(NextQuestionEvent event, Emitter<QuizState> emit) {
    if (state is QuizInProgress) {
      final current = state as QuizInProgress;

      // Check if lives reached 0
      if (current.lives <= 0) {
        emit(QuizCompleted(
          deck: current.deck,
          totalQuestions: current.deck.quizQuestions.length,
          correctAnswers: current.correctAnswersCount,
          finalScore: current.score,
          maxCombo: current.maxCombo,
          isVictory: false,
        ));
        return;
      }

      // Check if finished last question
      if (current.isLastQuestion) {
        emit(QuizCompleted(
          deck: current.deck,
          totalQuestions: current.deck.quizQuestions.length,
          correctAnswers: current.correctAnswersCount,
          finalScore: current.score,
          maxCombo: current.maxCombo,
          isVictory: true,
        ));
      } else {
        // Move to next question
        emit(current.copyWith(
          currentQuestionIndex: current.currentQuestionIndex + 1,
          selectedOptionIndex: null,
          isAnswerSubmitted: false,
          isCurrentAnswerCorrect: null,
        ));
      }
    }
  }

  void _onRestartQuiz(RestartQuizEvent event, Emitter<QuizState> emit) {
    if (state is QuizCompleted) {
      final completed = state as QuizCompleted;
      add(StartQuizEvent(completed.deck));
    }
  }
}
