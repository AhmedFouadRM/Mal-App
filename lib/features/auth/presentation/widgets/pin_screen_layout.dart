import 'package:flutter/material.dart';
import 'package:masroofy/core/theme/app_dimensions.dart';
import 'package:masroofy/core/theme/masroofy_colors.dart';
import 'package:material_symbols_icons/symbols.dart';

/// The shared body of the PIN screens (Figma "Auth"): a tinted icon (or a
/// 72 px [graphic] in its place), a title, one line of message, the dots and
/// an optional note, 12 px apart, [top] below the app bar (or the status bar);
/// and the keypad 40 px above the bottom.
class PinScreenLayout extends StatelessWidget {
  const PinScreenLayout({
    required this.title,
    required this.message,
    required this.dots,
    required this.keypad,
    this.icon,
    this.graphic,
    this.messageColor,
    this.note,
    this.top = 24,
    super.key,
  }) : assert(icon != null || graphic != null, 'Pass an icon or a graphic');

  final IconData? icon;

  /// Replaces the icon chip; used when set.
  final Widget? graphic;
  final String title;
  final String message;

  /// Defaults to the secondary text colour; errors pass a stronger one.
  final Color? messageColor;
  final Widget dots;
  final Widget keypad;

  /// An info box under the dots (the forgotten-PIN note).
  final Widget? note;

  /// Space above the icon: 24 under an app bar, 120 on the lock screen. It
  /// gives way on short screens, so the keypad stays in view.
  final double top;

  static const double _gap = 12;
  static const double _keypadBottom = 40;

  /// Everything below [top] at its smallest: icon, title, message and dots
  /// (174), the gap over the keypad (24), the keypad (336) and its margin.
  static const double _content = 174 + AppSpacing.xl + 336 + _keypadBottom;

  @override
  Widget build(BuildContext context) {
    final colors = MasroofyColors.of(context);
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final room = constraints.maxHeight - _content;
        final topSpace = room.clamp(AppSpacing.lg, top);
        return CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                child: Column(
                  children: [
                    SizedBox(height: topSpace),
                    SizedBox.square(
                      dimension: 72,
                      child: graphic != null
                          ? Center(child: graphic)
                          : DecoratedBox(
                              decoration: BoxDecoration(shape: BoxShape.circle, color: colors.primarySubtle),
                              child: Icon(icon, color: colors.primary, size: 32),
                            ),
                    ),
                    const SizedBox(height: _gap),
                    Text(title, style: text.headlineSmall, textAlign: TextAlign.center),
                    const SizedBox(height: _gap),
                    // Live region: a wrong PIN or a countdown is announced.
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        message,
                        style: text.bodyMedium!.copyWith(color: messageColor ?? colors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: _gap),
                    dots,
                    if (note != null) ...[const SizedBox(height: _gap), note!],
                    const Spacer(),
                    const SizedBox(height: AppSpacing.xl),
                    keypad,
                    const SizedBox(height: _keypadBottom),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The forgotten-PIN note on the Set PIN screen.
class PinNote extends StatelessWidget {
  const PinNote({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = MasroofyColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.surfaceVariant, borderRadius: BorderRadius.circular(AppRadius.input)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Symbols.info_rounded, size: 18, color: colors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: colors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
