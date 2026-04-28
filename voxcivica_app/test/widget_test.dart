import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:voxcivica_app/main.dart';

void main() {
  testWidgets('App smoke test — widget tree builds without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(const VoxCivicaApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
