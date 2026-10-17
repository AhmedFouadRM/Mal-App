import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masroofy/shared/widgets/keyboard_dismisser.dart';

void main() {
  late int saved;

  setUp(() => saved = 0);

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => KeyboardDismisser(child: child!),
      home: Scaffold(
        body: ListView(
          children: [
            const TextField(key: Key('amount')),
            const SizedBox(key: Key('blank'), height: 400),
            FilledButton(onPressed: () => saved++, child: const Text('Save')),
          ],
        ),
      ),
    ),
  );

  bool focused(WidgetTester tester) => tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus;

  testWidgets('a tap outside the field closes the keyboard', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('amount')));
    await tester.pump();
    expect(focused(tester), isTrue);
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.tap(find.byKey(const Key('blank')));
    await tester.pump();

    expect(focused(tester), isFalse);
    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('a tap on the field keeps it focused', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('amount')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('amount')));
    await tester.pump();

    expect(focused(tester), isTrue);
  });

  testWidgets('buttons still get their tap', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('amount')));
    await tester.pump();

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(saved, 1);
  });

  testWidgets('scrolling keeps the keyboard', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('amount')));
    await tester.pump();

    await tester.drag(find.byKey(const Key('blank')), const Offset(0, -50));
    await tester.pump();

    expect(focused(tester), isTrue);
  });
}
