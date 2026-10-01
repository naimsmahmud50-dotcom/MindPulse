import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/study_models.dart';
import '../../../data/repositories/mock_study_repository.dart';

// EVENTS
abstract class DeckEvent extends Equatable {
  const DeckEvent();
  @override
  List<Object?> get props => [];
}

class LoadDecksEvent extends DeckEvent {}

class SelectDeckEvent extends DeckEvent {
  final String deckId;
  const SelectDeckEvent(this.deckId);
  @override
  List<Object?> get props => [deckId];
}

class ToggleFlashcardMasteredEvent extends DeckEvent {
  final String deckId;
  final String flashcardId;
  const ToggleFlashcardMasteredEvent({required this.deckId, required this.flashcardId});
  @override
  List<Object?> get props => [deckId, flashcardId];
}

// STATES
abstract class DeckState extends Equatable {
  const DeckState();
  @override
  List<Object?> get props => [];
}

class DeckInitial extends DeckState {}

class DeckLoading extends DeckState {}

class DeckLoaded extends DeckState {
  final List<StudyDeck> decks;
  final StudyDeck? selectedDeck;

  const DeckLoaded({
    required this.decks,
    this.selectedDeck,
  });

  DeckLoaded copyWith({
    List<StudyDeck>? decks,
    StudyDeck? selectedDeck,
  }) {
    return DeckLoaded(
      decks: decks ?? this.decks,
      selectedDeck: selectedDeck ?? this.selectedDeck,
    );
  }

  @override
  List<Object?> get props => [decks, selectedDeck];
}

class DeckError extends DeckState {
  final String message;
  const DeckError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLOC
class DeckBloc extends Bloc<DeckEvent, DeckState> {
  final MockStudyRepository repository;

  DeckBloc({required this.repository}) : super(DeckInitial()) {
    on<LoadDecksEvent>(_onLoadDecks);
    on<SelectDeckEvent>(_onSelectDeck);
    on<ToggleFlashcardMasteredEvent>(_onToggleFlashcardMastered);
  }

  void _onLoadDecks(LoadDecksEvent event, Emitter<DeckState> emit) {
    emit(DeckLoading());
    try {
      final decks = repository.getDecks();
      emit(DeckLoaded(decks: decks, selectedDeck: decks.isNotEmpty ? decks.first : null));
    } catch (e) {
      emit(DeckError(e.toString()));
    }
  }

  void _onSelectDeck(SelectDeckEvent event, Emitter<DeckState> emit) {
    if (state is DeckLoaded) {
      final currentState = state as DeckLoaded;
      final selected = currentState.decks.firstWhere(
        (d) => d.id == event.deckId,
        orElse: () => currentState.decks.first,
      );
      emit(currentState.copyWith(selectedDeck: selected));
    }
  }

  void _onToggleFlashcardMastered(ToggleFlashcardMasteredEvent event, Emitter<DeckState> emit) {
    if (state is DeckLoaded) {
      final currentState = state as DeckLoaded;
      final updatedDecks = currentState.decks.map((deck) {
        if (deck.id == event.deckId) {
          final updatedCards = deck.flashcards.map((card) {
            if (card.id == event.flashcardId) {
              return card.copyWith(isMastered: !card.isMastered);
            }
            return card;
          }).toList();

          final masteredCount = updatedCards.where((c) => c.isMastered).length;
          final newProgress = updatedCards.isEmpty ? 0.0 : (masteredCount / updatedCards.length);

          return deck.copyWith(flashcards: updatedCards, progress: newProgress);
        }
        return deck;
      }).toList();

      final updatedSelected = updatedDecks.firstWhere(
        (d) => d.id == currentState.selectedDeck?.id,
        orElse: () => updatedDecks.first,
      );

      emit(DeckLoaded(decks: updatedDecks, selectedDeck: updatedSelected));
    }
  }
}
