import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solve_mate/main.dart';

void main() {
  testWidgets('Solve Mate renders the marketplace shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SolveMateApp());

    expect(find.text('Solve Mate'), findsOneWidget);
    expect(find.text('User Login'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Test User');
    await tester.enterText(find.byType(TextField).last, 'user@test.com');
    await tester.tap(find.text('Login as User'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Teachers'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
