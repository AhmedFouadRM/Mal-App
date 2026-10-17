import 'package:flutter/widgets.dart';

/// Tapping anywhere that isn't a field (or another control) drops the focus,
/// so the keyboard closes and the button under it can be seen. A tap only:
/// scrolling keeps the keyboard. Sits above every route, in
/// `MaterialApp.builder`.
class KeyboardDismisser extends StatelessWidget {
  const KeyboardDismisser({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => GestureDetector(
    // Controls below win the tap; this only gets taps nothing else wants.
    behavior: HitTestBehavior.translucent,
    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
    child: child,
  );
}
