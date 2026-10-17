import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masroofy/core/theme/app_typography.dart';
import 'package:masroofy/shared/widgets/app_shell.dart';

/// Figma's "Navigation Bar" is 260 wide (the bar in code is 268); each of
/// its three tabs gets a third of it.
const double _figmaTabWidth = 260 / 3;

String _tabLabel(String lang) =>
    ((jsonDecode(File('assets/translations/$lang.json').readAsStringSync()) as Map<String, dynamic>)['expenses']
            as Map<String, dynamic>)['tab']
        as String;

double _width(String text, String? family) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(fontFamily: family, fontSize: 11, fontWeight: FontWeight.w500),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

void main() {
  setUpAll(() async {
    final sora = FontLoader(AppTypography.sora)
      ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/sora/Sora-Regular.ttf').readAsBytesSync())));
    await sora.load();
  });

  test('the Transactions tab has a short name in both languages', () {
    expect(_tabLabel('en'), 'Activity');
    expect(_tabLabel('ar'), 'الحركات');
  });

  test('the English tab label fits a third of the Figma bar, in Sora', () {
    expect(_width(_tabLabel('en'), AppTypography.sora), lessThan(_figmaTabWidth));
    expect(AppShell.tabBarWidth / 3, greaterThanOrEqualTo(_figmaTabWidth));
  });

  test('the Arabic tab label fits even in the test font, whose glyphs are a full em wide', () {
    // Thmanyah is not in the repo; the test font is a wide upper bound.
    expect(_width(_tabLabel('ar'), null), lessThan(_figmaTabWidth));
  });
}
