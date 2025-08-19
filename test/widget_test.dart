// This is a basic Flutter widget test for the Railway Form app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:railwayform/main.dart';

void main() {
  testWidgets('App loads and shows auth wrapper', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the app title is correct.
    expect(find.text('Clean Train Station Score Card'), findsOneWidget);
    
    // Wait for the auth wrapper to load
    await tester.pump();
    
    // Should show loading initially or login screen
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
