import 'package:equatable/equatable.dart';

class Flashcard extends Equatable {
  final String id;
  final String front;
  final String back;
  final String? hint;
  final String? codeSnippet;
  final bool isMastered;

  const Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.hint,
    this.codeSnippet,
    this.isMastered = false,
  });

  Flashcard copyWith({
    String? id,
    String? front,
    String? back,
    String? hint,
    String? codeSnippet,
    bool? isMastered,
  }) {
    return Flashcard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      hint: hint ?? this.hint,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      isMastered: isMastered ?? this.isMastered,
    );
  }

  @override
  List<Object?> get props => [id, front, back, hint, codeSnippet, isMastered];
}

class QuizQuestion extends Equatable {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final String? citation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    this.citation,
  });

  @override
  List<Object?> get props => [id, question, options, correctOptionIndex, explanation, citation];
}

class StudyDeck extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final String iconCode;
  final int cardCount;
  final List<Flashcard> flashcards;
  final List<QuizQuestion> quizQuestions;
  final double progress; // 0.0 to 1.0

  const StudyDeck({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.iconCode,
    required this.cardCount,
    required this.flashcards,
    required this.quizQuestions,
    this.progress = 0.0,
  });

  StudyDeck copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? iconCode,
    int? cardCount,
    List<Flashcard>? flashcards,
    List<QuizQuestion>? quizQuestions,
    double? progress,
  }) {
    return StudyDeck(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      iconCode: iconCode ?? this.iconCode,
      cardCount: cardCount ?? this.cardCount,
      flashcards: flashcards ?? this.flashcards,
      quizQuestions: quizQuestions ?? this.quizQuestions,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [id, title, description, category, iconCode, cardCount, flashcards, quizQuestions, progress];
}
