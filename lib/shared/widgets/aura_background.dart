import 'package:flutter/material.dart';
import 'package:masroofy/core/theme/masroofy_colors.dart';

/// The canvas with the soft emerald glows behind the top of a screen: two
/// blurred circles, as in every Figma frame (90 px layer blur). They sit at
/// the top start and top end corners, mirrored in RTL.
class AuraBackground extends StatelessWidget {
  const AuraBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = MasroofyColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.canvas),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: AuraPainter(
                    start: colors.aura1.withValues(alpha: 0.8),
                    end: colors.aura2.withValues(alpha: 0.7),
                    textDirection: Directionality.of(context),
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Paints the two aura circles; sizes and offsets are Figma's, in dp.
@visibleForTesting
class AuraPainter extends CustomPainter {
  const AuraPainter({required this.start, required this.end, required this.textDirection});

  final Color start;
  final Color end;
  final TextDirection textDirection;

  /// Figma's 90 px layer blur is a Gaussian with a 45 px sigma.
  static const _sigma = 45.0;

  // 320 circle at (-100, -140) from the start corner.
  static const _startRadius = 160.0;
  static const _startCenter = Offset(-100 + _startRadius, -140 + _startRadius);

  // 260 circle at (180, -60) on a 360 frame: 80 px past the end edge.
  static const _endRadius = 130.0;
  static const _endCenter = Offset(-80 + _endRadius, -60 + _endRadius);

  @override
  void paint(Canvas canvas, Size size) {
    final rtl = textDirection == TextDirection.rtl;
    Offset fromStart(Offset o) => Offset(rtl ? size.width - o.dx : o.dx, o.dy);
    Offset fromEnd(Offset o) => Offset(rtl ? o.dx : size.width - o.dx, o.dy);

    Paint blurred(Color color) => Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _sigma);

    canvas
      ..drawCircle(fromStart(_startCenter), _startRadius, blurred(start))
      ..drawCircle(fromEnd(_endCenter), _endRadius, blurred(end));
  }

  @override
  bool shouldRepaint(AuraPainter oldDelegate) =>
      oldDelegate.start != start || oldDelegate.end != end || oldDelegate.textDirection != textDirection;
}
