import 'dart:ui' show PictureRecorder;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masroofy/core/theme/app_theme.dart';
import 'package:masroofy/core/theme/masroofy_colors.dart';
import 'package:masroofy/shared/widgets/aura_background.dart';

void main() {
  Future<void> pumpAura(WidgetTester tester, {bool dark = false, TextDirection direction = TextDirection.ltr}) async {
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.dark(arabic: false) : AppTheme.light(arabic: false),
        home: Directionality(
          textDirection: direction,
          child: const AuraBackground(child: Text('content')),
        ),
      ),
    );
  }

  Finder aura() => find.byWidgetPredicate((widget) => widget is CustomPaint && widget.painter is AuraPainter);

  testWidgets('two blurred circles at the Figma spots (41:810, 360 x 800)', (tester) async {
    await pumpAura(tester);
    const colors = MasroofyColors.light;

    expect(find.text('content'), findsOneWidget);
    expect(
      aura(),
      paints
        // 320 at (-100, -140), 80 % #A7F3D0.
        ..circle(x: 60, y: 20, radius: 160, color: colors.aura1.withValues(alpha: 0.8))
        // 260 at (180, -60), 70 % #99F6E4.
        ..circle(x: 310, y: 70, radius: 130, color: colors.aura2.withValues(alpha: 0.7)),
    );
    expect(colors.aura1, const Color(0xFFA7F3D0));
    expect(colors.aura2, const Color(0xFF99F6E4));
  });

  testWidgets('the glow is a 90 px layer blur, so it fades out near the top', (tester) async {
    await pumpAura(tester);

    final recorder = PictureRecorder();
    final canvas = _BlurSpy(Canvas(recorder));
    (tester.widget<CustomPaint>(aura()).painter! as AuraPainter).paint(canvas, const Size(360, 800));
    recorder.endRecording();

    expect(canvas.maskFilters, everyElement(const MaskFilter.blur(BlurStyle.normal, 45)));
    expect(canvas.maskFilters, hasLength(2));
    // The circles end at y = 180 and 200; the old gradients reached ~y = 400.
    expect(canvas.bottoms, everyElement(lessThanOrEqualTo(200)));
  });

  testWidgets('mirrored in RTL', (tester) async {
    await pumpAura(tester, direction: TextDirection.rtl);

    expect(
      aura(),
      paints
        ..circle(x: 300, y: 20, radius: 160)
        ..circle(x: 50, y: 70, radius: 130),
    );
  });

  testWidgets('dark mode uses the dark aura colours (41:855)', (tester) async {
    await pumpAura(tester, dark: true);

    expect(
      aura(),
      paints
        ..circle(color: const Color(0xFF064E3B).withValues(alpha: 0.8))
        ..circle(color: const Color(0xFF134E4A).withValues(alpha: 0.7)),
    );
  });
}

/// Records the blur and the lower edge of each circle.
class _BlurSpy implements Canvas {
  _BlurSpy(this._canvas);

  final Canvas _canvas;
  final maskFilters = <MaskFilter?>[];
  final bottoms = <double>[];

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    maskFilters.add(paint.maskFilter);
    bottoms.add(c.dy + radius);
    _canvas.drawCircle(c, radius, paint);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
