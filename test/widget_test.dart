// This is a basic Flutter widget test for NoiseBattle app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:noisebattle/app/app.dart';

void main() {
  testWidgets('NoiseBattle app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NoiseBattleApp());

    // Verify that our app title is displayed.
    expect(find.text('NoiseBattle'), findsOneWidget);
    expect(find.text('소음과 전쟁'), findsOneWidget);

    // Verify that loading indicator is displayed.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Verify that initialization message is displayed.
    expect(find.text('앱을 초기화하고 있습니다...'), findsOneWidget);

    // Verify that the volume icon is displayed.
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
  });
}
