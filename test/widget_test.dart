// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:tubes_content_planner/providers/app_state.dart';
import 'package:tubes_content_planner/screens/login_screen.dart';

void main() {
  testWidgets('App shows login screen when not authenticated', (WidgetTester tester) async {
    final appState = AppState();
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: appState,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Login Content Planner'), findsOneWidget);
    expect(find.text('Belum punya akun? Daftar sekarang'), findsOneWidget);
  });
}
