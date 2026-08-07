// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:festive_crops_app/main.dart';

void main() {
  testWidgets('App launches and shows home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const FestiveCropsApp());

    // Wait for any async loading (like Firebase init)
    await tester.pumpAndSettle();

    // Verify that the app launches without crashing
    expect(find.byType(FestiveCropsApp), findsOneWidget);

    // Check for your app title or main text
    expect(find.textContaining('Festive', findRichText: true), findsWidgets);
    expect(find.textContaining('Crop', findRichText: true), findsWidgets);

    // Or just check that Scaffold exists (means app loaded)
    expect(find.byType(Scaffold), findsOneWidget);
  });
}