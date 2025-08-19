// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ktunotecleaner/main.dart';

void main() {
  testWidgets('KTU PDF Cleaner app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KtuPdfCleanerApp());

    // Verify that the app loads with the expected title and button.
    expect(find.text('KTU Notes PDF Cleaner'), findsOneWidget);
    expect(find.text('Browse PDFs or Folders'), findsOneWidget);
  });
}
