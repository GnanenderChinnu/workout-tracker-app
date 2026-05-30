import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:first_flutter_app/main.dart';

void main() {
  testWidgets('Workout tracker opens dashboard', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const WorkoutTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Today’s Goal'), findsOneWidget);
    expect(find.text('Workouts'), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);
  });
}
