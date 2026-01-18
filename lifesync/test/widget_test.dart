// Basic Flutter widget test for LifeSync app

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lifesync/app.dart';

void main() {
  testWidgets('LifeSync app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: LifeSyncApp(),
      ),
    );

    // Verify the app loads - check for the app title or initial screen
    await tester.pump();
    
    // The app should render without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
