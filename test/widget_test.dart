import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalasetu_v2/main.dart';

void main() {
  testWidgets('KalaSetuApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: KalaSetuApp()),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
