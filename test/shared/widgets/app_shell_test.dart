import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masroofy/core/theme/app_typography.dart';
import 'package:masroofy/core/theme/thmanyah_font_loader.dart';
import 'package:masroofy/shared/widgets/app_shell.dart';

/// Figma's "Navigation Bar" is 260 wide (the bar in code is 268). Each of
/// its three tabs gets a third of it, less the tab bar's 4 + 4 padding.
const double _labelRoom = 260 / 3 - 8;

/// Thmanyah is gitignored and loaded at runtime, so it may be missing here.
final _thmanyah = File('assets/fonts/thmanyah/thmanyahsans-Medium.otf');

String _tabLabel(String lang) =>
    ((jsonDecode(File('assets/translations/$lang.json').readAsStringSync()) as Map<String, dynamic>)['expenses']
            as Map<String, dynamic>)['title']
        as String;

Future<void> _load(String family, File file) =>
    (FontLoader(family)..addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())))).load();

double _width(String text, String family) {
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
    await _load(AppTypography.sora, File('assets/fonts/sora/Sora-SemiBold.ttf'));
    if (_thmanyah.existsSync()) await _load(ThmanyahFontLoader.family, _thmanyah);
  });

  test('the Transactions tab is named like its screen', () {
    expect(_tabLabel('en'), 'Transactions');
    expect(_tabLabel('ar'), 'المعاملات');
  });

  test('the bar in code is at least as wide as Figma', () {
    expect(AppShell.tabBarWidth, greaterThanOrEqualTo(260));
  });

  test('the English tab label fits its tab, in Sora', () {
    expect(_width(_tabLabel('en'), AppTypography.sora), lessThan(_labelRoom));
  });

  test(
    'the Arabic tab label fits its tab, in Thmanyah',
    () => expect(_width(_tabLabel('ar'), ThmanyahFontLoader.family), lessThan(_labelRoom)),
    skip: _thmanyah.existsSync() ? false : 'Thmanyah is not on this machine',
  );
}
