import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:masroofy/core/strings/string_manager.dart';
import 'package:masroofy/core/theme/masroofy_colors.dart';

/// The Mal brand artwork (Release PRD §3, Figma "Mal · Brand components"),
/// exported as vector outlines: no live text, no font files.
abstract final class BrandAssets {
  static const String _dir = 'assets/brand';

  /// The tile-less glyph, in layers that share one 172 × 165 view box, so the
  /// two notes can move on their own (the splash reveal).
  static const String glyphPlate = '$_dir/glyph_plate.svg';
  static const String glyphNoteBack = '$_dir/glyph_note_back.svg';
  static const String glyphNoteFront = '$_dir/glyph_note_front.svg';
  static const String glyphWallet = '$_dir/glyph_wallet.svg';

  /// The single-colour glyph (Round 10 V2): a flat wallet silhouette with
  /// cut-outs, for small uses and tinted surfaces.
  static const String glyphMono = '$_dir/glyph_mono.svg';

  /// Wordmark A0, "Mal مال".
  static const String wordmark = '$_dir/wordmark.svg';
  static const String sloganEn = '$_dir/slogan_en.svg';
  static const String sloganAr = '$_dir/slogan_ar.svg';

  /// The app icon: the glyph on its emerald tile.
  static const String appIcon = '$_dir/app_icon.svg';

  static const List<String> _all = [
    glyphPlate,
    glyphNoteBack,
    glyphNoteFront,
    glyphWallet,
    glyphMono,
    wordmark,
    sloganEn,
    sloganAr,
    appIcon,
  ];

  static final Map<String, PictureInfo> _pictures = {};

  /// Decodes the artwork before the first frame (call it in `main`). The
  /// brand widgets then paint it in their very first frame, so the splash
  /// reveal starts exactly on the system splash; without it they fall back
  /// to [SvgPicture], which shows up a frame or two later.
  static Future<void> precache() async {
    final pictures = await Future.wait([for (final asset in _all) vg.loadPicture(SvgAssetLoader(asset), null)]);
    for (var i = 0; i < _all.length; i++) {
      _pictures[_all[i]] = pictures[i];
    }
  }
}

/// One piece of artwork filling its box, optionally in one [color].
class _BrandArt extends StatelessWidget {
  const _BrandArt(this.asset, {this.color});

  final String asset;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final picture = BrandAssets._pictures[asset];
    if (picture == null) {
      return SvgPicture.asset(
        asset,
        fit: BoxFit.fill,
        colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
      );
    }
    return CustomPaint(size: Size.infinite, painter: _PicturePainter(picture, color));
  }
}

class _PicturePainter extends CustomPainter {
  const _PicturePainter(this.info, this.color);

  final PictureInfo info;
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / info.size.width, size.height / info.size.height);
    if (color != null) {
      canvas.saveLayer(
        Offset.zero & info.size,
        Paint()..colorFilter = ColorFilter.mode(color!, BlendMode.srcIn),
      );
    }
    canvas.drawPicture(info.picture);
    if (color != null) canvas.restore();
  }

  @override
  bool shouldRepaint(_PicturePainter oldDelegate) => info != oldDelegate.info || color != oldDelegate.color;
}

/// Width over height of the glyph, the wordmark and the slogans.
abstract final class BrandAspect {
  static const double glyph = 172 / 165;
  static const double glyphMono = 172 / 166;
  static const double wordmark = 341 / 150;
  static const double sloganEn = 344 / 36;
  static const double sloganAr = 249 / 48;
}

/// The tile-less glyph (a mint wallet with two fanned notes). It looks the
/// same in light and dark. The notes can be posed for the splash reveal:
/// offsets are in logical pixels at [width], angles in radians (clockwise).
class BrandGlyph extends StatelessWidget {
  const BrandGlyph({
    required this.width,
    this.noteBackOffset = Offset.zero,
    this.noteBackAngle = 0,
    this.noteFrontOffset = Offset.zero,
    this.noteFrontAngle = 0,
    super.key,
  });

  final double width;
  final Offset noteBackOffset;
  final double noteBackAngle;
  final Offset noteFrontOffset;
  final double noteFrontAngle;

  // Each note turns about its own centre (Figma "noteBack" / "noteFront").
  static const Alignment _noteBackPivot = Alignment(0.22, -0.48);
  static const Alignment _noteFrontPivot = Alignment(-0.09, -0.39);

  static Widget _layer(String asset) => Positioned.fill(child: _BrandArt(asset));

  static Widget _note(String asset, Offset offset, double angle, Alignment pivot) => Positioned.fill(
    child: Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: angle,
        alignment: pivot,
        child: _BrandArt(asset),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width / BrandAspect.glyph,
      child: Stack(
        children: [
          _layer(BrandAssets.glyphPlate),
          _note(BrandAssets.glyphNoteBack, noteBackOffset, noteBackAngle, _noteBackPivot),
          _note(BrandAssets.glyphNoteFront, noteFrontOffset, noteFrontAngle, _noteFrontPivot),
          _layer(BrandAssets.glyphWallet),
        ],
      ),
    );
  }
}

/// The single-colour glyph in the wordmark green (#047857, #34D399 in dark),
/// for small uses such as the first-launch row, where the full-colour glyph
/// would blend into the mint aura.
class BrandGlyphMono extends StatelessWidget {
  const BrandGlyphMono({required this.height, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height * BrandAspect.glyphMono,
      child: _BrandArt(BrandAssets.glyphMono, color: MasroofyColors.of(context).primary),
    );
  }
}

/// Wordmark A0 in the brand green (#047857, #34D399 in dark).
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({required this.height, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: StringManager.appName,
      image: true,
      child: SizedBox(
        height: height,
        width: height * BrandAspect.wordmark,
        child: _BrandArt(BrandAssets.wordmark, color: MasroofyColors.of(context).primary),
      ),
    );
  }
}

/// The slogan in the app language: "Your money, clearly." or «فلوسك، بوضوح».
/// Sized by [enWidth]; the Arabic one is narrower and taller, as in Figma.
class BrandSlogan extends StatelessWidget {
  const BrandSlogan({required this.enWidth, super.key});

  final double enWidth;

  // The slogan's own greens (Figma "slogan EN / AR").
  static const Color _light = Color(0xFF3E5A4D);
  static const Color _dark = Color(0xFF8FD1B9);

  /// The Arabic slogan's width in Figma, relative to the English one (150 / 190).
  static const double _arWidth = 150 / 190;

  @override
  Widget build(BuildContext context) {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final width = arabic ? enWidth * _arWidth : enWidth;
    final color = Theme.of(context).brightness == Brightness.dark ? _dark : _light;
    return SizedBox(
      key: ValueKey(arabic ? 'slogan-ar' : 'slogan-en'),
      width: width,
      height: width / (arabic ? BrandAspect.sloganAr : BrandAspect.sloganEn),
      child: _BrandArt(arabic ? BrandAssets.sloganAr : BrandAssets.sloganEn, color: color),
    );
  }
}

/// The app icon in a circle mask (Figma "Brand / App icon · circle"), where
/// it stands for the app among circular row icons (Settings → About).
class BrandAppIcon extends StatelessWidget {
  const BrandAppIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox.square(dimension: size, child: const _BrandArt(BrandAssets.appIcon)),
    );
  }
}
