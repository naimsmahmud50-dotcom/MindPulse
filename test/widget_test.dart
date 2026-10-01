import 'package:flutter_test/flutter_test.dart';
import 'package:mindpulse/data/repositories/mock_study_repository.dart';
import 'package:mindpulse/main.dart';

void main() {
  testWidgets('MindPulse initial render smoke test', (WidgetTester tester) async {
    final repository = MockStudyRepository();
    await tester.pumpWidget(MindPulseApp(repository: repository));
    await tester.pumpAndSettle();

    // Verify daily goal or study decks title is rendered
    expect(find.text('Study Decks'), findsOneWidget);
    expect(find.text('DAILY PULSE GOAL'), findsOneWidget);
  });
}
