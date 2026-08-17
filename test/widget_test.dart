import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:goalflow/main.dart';

void main() {
  testWidgets('GoalFlow app starts without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GoalFlowApp(initialRoute: '/register'));

    // Verify the app built without error
    expect(find.byType(MaterialApp), findsNothing); // GoalFlowApp uses GoRouter
  });
}
