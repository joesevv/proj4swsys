import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// sun/moon button that flips between light and dark mode.
/// shows a sun while dark (tap for light) and a moon while light (tap for dark).
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: () => ThemeModeScope.of(context).value =
      isDark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}