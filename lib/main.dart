import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/mock_study_repository.dart';
import 'presentation/bloc/deck/deck_bloc.dart';
import 'presentation/bloc/quiz/quiz_bloc.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = MockStudyRepository();

  runApp(MindPulseApp(repository: repository));
}

class MindPulseApp extends StatelessWidget {
  final MockStudyRepository repository;

  const MindPulseApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DeckBloc>(
          create: (_) => DeckBloc(repository: repository)..add(LoadDecksEvent()),
        ),
        BlocProvider<QuizBloc>(
          create: (_) => QuizBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'MindPulse — Interactive AI Study & Quiz Engine',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
