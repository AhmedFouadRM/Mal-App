import 'dart:async';

import 'package:flutter/material.dart';
import 'package:masroofy/core/theme/masroofy_colors.dart';
import 'package:masroofy/shared/widgets/brand.dart';

/// The brand reveal on cold start (Release PRD §3.1, Figma page
/// "11 · Brand & Release"). It starts from the Android 12+ system splash
/// layout (the glyph on the emerald circle) and plays over [child], which is
/// built at once underneath: start-up never waits for it. The glyph lifts,
/// the circle dissolves, the wordmark and slogan come in, and the overlay
/// fades into the first screen. With reduce motion on it is a 200 ms
/// cross-fade from the splash layout.
///
/// Mounted once with the app (in `MaterialApp.builder`), so it plays only on
/// a cold start, not on resume.
class SplashReveal extends StatefulWidget {
  const SplashReveal({required this.child, super.key});

  final Widget child;

  /// The PRD's 1.6 s timeline played 1.5× slower: at 1.6 s it read as too fast.
  static const Duration duration = Duration(milliseconds: 2400);
  static const Duration reducedDuration = Duration(milliseconds: 200);

  /// The overlay, for tests.
  static const ValueKey<String> overlayKey = ValueKey('splash-reveal');

  /// Completes when the reveal is gone (at once without one). The lock
  /// screen waits for it before showing the biometric prompt.
  static Future<void> done(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_SplashScope>()?.done ?? Future<void>.value();

  @override
  State<SplashReveal> createState() => _SplashRevealState();
}

class _SplashRevealState extends State<SplashReveal> with SingleTickerProviderStateMixin {
  // `preserve`: reduce motion already gets its own short cross-fade, which
  // must not be sped up again.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SplashReveal.duration,
    animationBehavior: AnimationBehavior.preserve,
  );
  final Completer<void> _done = Completer<void>();
  bool _showing = true;
  bool? _reduced;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Decided once, from the first frame's settings.
    if (_reduced != null) return;
    _reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced!) _controller.duration = SplashReveal.reducedDuration;
    // The clock starts after the first frame, so a slow first frame doesn't
    // eat into the reveal.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_controller.forward().whenComplete(_finish));
    });
  }

  void _finish() {
    if (!_done.isCompleted) _done.complete();
    if (mounted) setState(() => _showing = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    if (!_done.isCompleted) _done.complete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SplashScope(
      done: _done.future,
      child: Stack(
        children: [
          widget.child,
          if (_showing)
            Positioned.fill(
              key: SplashReveal.overlayKey,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => _reduced!
                    ? Opacity(opacity: 1 - _controller.value, child: const _RevealFrame(t: 0))
                    : Opacity(
                        opacity: 1 - _Timeline.fadeOut.transform(_controller.value),
                        child: _RevealFrame(t: _controller.value),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SplashScope extends InheritedWidget {
  const _SplashScope({required this.done, required super.child});

  final Future<void> done;

  @override
  bool updateShouldNotify(_SplashScope oldWidget) => done != oldWidget.done;
}

/// The phases of the reveal, as parts of the controller's 0–1: the Figma
/// keyframes' seconds over their 1.6 s timeline (played at [SplashReveal.duration]).
abstract final class _Timeline {
  /// cubic-bezier(0.2, 0, 0, 1).
  static const Curve easeOut = Cubic(0.2, 0, 0, 1);

  static const Interval noteBack = Interval(0.15 / 1.6, 0.65 / 1.6, curve: _Spring());
  static const Interval noteFront = Interval(0.25 / 1.6, 0.75 / 1.6, curve: _Spring());
  static const Interval circle = Interval(0.30 / 1.6, 0.60 / 1.6, curve: easeOut);
  static const Interval glyph = Interval(0.35 / 1.6, 0.80 / 1.6, curve: easeOut);
  static const Interval wordmark = Interval(0.50 / 1.6, 0.85 / 1.6, curve: easeOut);
  static const Interval slogan = Interval(0.75 / 1.6, 1.05 / 1.6, curve: easeOut);

  /// Hold to 1.4 s (of 1.6), then fade into the first screen.
  static const Interval fadeOut = Interval(1.4 / 1.6, 1, curve: Curves.easeIn);
}

/// The reveal at time [t] (0–1), laid out on the 360 × 800 Figma frame
/// around the screen centre, where the system splash draws its icon.
class _RevealFrame extends StatelessWidget {
  const _RevealFrame({required this.t});

  final double t;

  static const double _circle = 160;

  /// The glyph is laid out at its settled size and scaled down to the
  /// system splash's 96 px at the start.
  static const double _glyph = 112;
  static const double _glyphStartScale = 96 / 112;
  static const double _glyphLift = 70;

  // Settled centres below the screen centre, from Figma.
  static const double _wordmarkY = 41.5;
  static const double _sloganY = 112;

  // Note poses at the start; they settle to 0.
  static const double _noteBackDrop = 12;
  static const double _noteBackAngle = -0.087; // −5°
  static const double _noteFrontDrop = 10;
  static const double _noteFrontAngle = 0.07; // 4°

  /// The emerald circle behind the system splash icon.
  static const Color _circleColor = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    final back = 1 - _Timeline.noteBack.transform(t);
    final front = 1 - _Timeline.noteFront.transform(t);
    final circle = _Timeline.circle.transform(t);
    final glyph = _Timeline.glyph.transform(t);
    final wordmark = _Timeline.wordmark.transform(t);
    final slogan = _Timeline.slogan.transform(t);

    return ColoredBox(
      color: MasroofyColors.of(context).canvas,
      child: ExcludeSemantics(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (circle < 1)
              Opacity(
                opacity: 1 - circle,
                child: Transform.scale(
                  scale: 1 + 0.25 * circle,
                  child: Container(
                    width: _circle,
                    height: _circle,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: _circleColor),
                  ),
                ),
              ),
            Transform.translate(
              offset: Offset(0, -_glyphLift * glyph),
              child: Transform.scale(
                scale: _glyphStartScale + (1 - _glyphStartScale) * glyph,
                child: BrandGlyph(
                  width: _glyph,
                  noteBackOffset: Offset(0, _noteBackDrop * back),
                  noteBackAngle: _noteBackAngle * back,
                  noteFrontOffset: Offset(0, _noteFrontDrop * front),
                  noteFrontAngle: _noteFrontAngle * front,
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, _wordmarkY + 16 * (1 - wordmark)),
              child: Opacity(opacity: wordmark, child: const BrandWordmark(height: 77)),
            ),
            Transform.translate(
              offset: Offset(0, _sloganY + 8 * (1 - slogan)),
              child: Opacity(opacity: slogan, child: const BrandSlogan(enWidth: 190)),
            ),
          ],
        ),
      ),
    );
  }
}

/// The notes' spring (bounce 0.35), sampled from the Figma keyframes.
class _Spring extends Curve {
  const _Spring();

  static const List<double> _samples = [
    0, 0.0242, 0.0871, 0.1757, 0.2793, 0.3892, 0.4987, 0.6028, 0.6982, 0.7827, 0.8552, 0.9156, 0.9641, //
    1.0017, 1.0295, 1.0486, 1.0606, 1.0666, 1.068, 1.0659, 1.0613, 1.0551, 1.048, 1.0405, 1.0331, 1.026,
    1.0197, 1.014, 1.0092, 1.0052, 1.002, 0.9996, 0.9978, 0.9965, 0.9958, 0.9954, 0.9954, 0.9955, 0.9959,
    0.9963, 0.9968, 0.9973, 0.9978, 0.9983, 0.9987, 0.9991, 0.9994, 0.9997, 0.9999, 1.0001, 1,
  ];

  @override
  double transformInternal(double t) {
    final position = t * (_samples.length - 1);
    final i = position.floor().clamp(0, _samples.length - 2);
    final f = position - i;
    return _samples[i] + (_samples[i + 1] - _samples[i]) * f;
  }
}
