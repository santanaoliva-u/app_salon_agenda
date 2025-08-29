// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_app/services/api_config_service.dart';

import 'package:salon_app/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    // Create a mock ApiConfigService for testing
    final apiConfigService = ApiConfigService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(apiConfigService: apiConfigService));

    // Verify that our app starts without crashing
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify that we have a splash screen or main content
    // This is a basic smoke test to ensure the app doesn't crash on startup
    await tester.pumpAndSettle();
  });
}
