import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masroofy/core/theme/app_theme.dart';
import 'package:masroofy/shared/widgets/brand.dart';
import 'package:masroofy/shared/widgets/splash_reveal.dart';

void main() {
  const firstScreen = Text('Transactions');
  final overlay = find.byKey(SplashReveal.overlayKey);

  Future<void> pumpReveal(WidgetTester tester, {Locale locale = const Locale('en'), bool reduceMotion = false}) async {
    if (reduceMotion) {
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        disableAnimations: true,
      );
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    }
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(arabic: locale.languageCode == 'ar'),
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, child) => SplashReveal(child: child!),
        home: const Scaffold(body: firstScreen),
      ),
    );
    // The controller's clock starts on the first frame after it.
    await tester.pump();
  }

  double overlayOpacity(WidgetTester tester) =>
      tester.widget<Opacity>(find.descendant(of: overlay, matching: find.byType(Opacity)).first).opacity;

  testWidgets('the first screen is built at once, under the reveal', (tester) async {
    await pumpReveal(tester);

    expect(find.text('Transactions'), findsOneWidget);
    expect(overlay, findsOneWidget);
    // It starts from the system splash: the glyph on the emerald circle.
    expect(find.descendant(of: overlay, matching: find.byType(BrandGlyph)), findsOneWidget);
  });

  testWidgets('plays for 1.6 s, then is gone', (tester) async {
    await pumpReveal(tester);

    await tester.pump(const Duration(milliseconds: 1000));
    expect(overlay, findsOneWidget);
    expect(overlayOpacity(tester), 1);

    await tester.pump(const Duration(milliseconds: 500));
    expect(overlayOpacity(tester), lessThan(1), reason: 'fading into the first screen after 1.4 s');

    // Done just past the end.
    await tester.pump(const Duration(milliseconds: 101));
    await tester.pump();
    expect(overlay, findsNothing);
    expect(find.text('Transactions'), findsOneWidget);
  });

  testWidgets('settles with the glyph lifted above the wordmark and slogan', (tester) async {
    await pumpReveal(tester);
    await tester.pump(const Duration(milliseconds: 1300));

    final glyph = tester.getRect(find.byType(BrandGlyph));
    final wordmark = tester.getRect(find.byType(BrandWordmark));
    final slogan = tester.getRect(find.byType(BrandSlogan));
    expect(glyph.width, closeTo(112, 0.5));
    expect(glyph.center.dy, closeTo(300 - 70, 0.5)); // the 800 px test view's centre, lifted 70 px
    expect(glyph.bottom, lessThan(wordmark.top));
    expect(wordmark.bottom, lessThan(slogan.top));
    expect(find.byKey(const ValueKey('slogan-en')), findsOneWidget);
  });

  testWidgets('Arabic shows the Arabic slogan', (tester) async {
    await pumpReveal(tester, locale: const Locale('ar'));
    await tester.pump(const Duration(milliseconds: 1300));

    expect(find.byKey(const ValueKey('slogan-ar')), findsOneWidget);
    expect(find.byKey(const ValueKey('slogan-en')), findsNothing);
  });

  group('reduce motion', () {
    testWidgets('no reveal: a 200 ms cross-fade from the splash layout', (tester) async {
      await pumpReveal(tester, reduceMotion: true);

      expect(overlay, findsOneWidget);
      // Nothing moves: the glyph stays at the system splash size and place.
      final glyph = tester.getRect(find.byType(BrandGlyph));
      expect(glyph.width, closeTo(96, 0.5));
      expect(glyph.center.dy, closeTo(300, 0.5));

      await tester.pump(const Duration(milliseconds: 100));
      expect(overlayOpacity(tester), closeTo(0.5, 0.01));
      expect(tester.getRect(find.byType(BrandGlyph)), glyph);

      await tester.pump(const Duration(milliseconds: 101));
      await tester.pump();
      expect(overlay, findsNothing);
      expect(find.text('Transactions'), findsOneWidget);
    });

    testWidgets('done completes after the cross-fade', (tester) async {
      await pumpReveal(tester, reduceMotion: true);
      var done = false;
      final context = tester.element(find.text('Transactions'));
      SplashReveal.done(context).then((_) => done = true).ignore();

      await tester.pump(const Duration(milliseconds: 100));
      expect(done, isFalse);
      await tester.pump(const Duration(milliseconds: 150));
      expect(done, isTrue);
    });
  });

  testWidgets('done completes at once without a reveal', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: firstScreen));
    var done = false;
    SplashReveal.done(tester.element(find.text('Transactions'))).then((_) => done = true).ignore();
    await tester.pump();
    expect(done, isTrue);
  });

  // Last: the precached pictures stay for the rest of the file.
  testWidgets('precached, the first frame already paints the glyph (no async SVG load)', (tester) async {
    await tester.runAsync(BrandAssets.precache);
    await pumpReveal(tester);

    expect(find.descendant(of: overlay, matching: find.byType(BrandGlyph)), findsOneWidget);
    expect(find.byType(SvgPicture), findsNothing);
    expect(
      find.descendant(of: find.byType(BrandGlyph), matching: find.byType(CustomPaint)),
      findsNWidgets(4),
      reason: 'plate, two notes and wallet',
    );
  });
}
