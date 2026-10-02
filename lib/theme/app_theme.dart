import 'package:flutter/material.dart';

/// App-specific colors that Material's ColorScheme doesn't cover
/// (column backgrounds, borders, the three status accents, etc.).
/// Each theme carries its own copy, so widgets read
/// `context.appColors.muted` instead of hard-coding a hex value.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brand,
    required this.muted,
    required this.columnBackground,
    required this.columnBorder,
    required this.cardBorder,
    required this.progressTrack,
    required this.todo,
    required this.inProgress,
    required this.done,
    required this.loginGradient,
  });

  /// purple used for logos, icons and highlights
  final Color brand;

  /// secondary text (subtitles, "Added by", hints)
  final Color muted;
  final Color columnBackground;
  final Color columnBorder;
  final Color cardBorder;
  final Color progressTrack;

  /// accent colors for each task column
  final Color todo;
  final Color inProgress;
  final Color done;

  /// three colors for the login screen background
  final List<Color> loginGradient;

  /// the original look of the app
  static const dark = AppColors(
    brand: Color(0xFFB7A0FF),
    muted: Color(0xFFAAAFC5),
    columnBackground: Color(0xFF191C29),
    columnBorder: Color(0xFF2B3043),
    cardBorder: Color(0xFF34394D),
    progressTrack: Color(0xFF2B3043),
    todo: Color(0xFFB7A0FF),
    inProgress: Color(0xFFFFC978),
    done: Color(0xFF71DEBB),
    loginGradient: [Color(0xFF25213E), Color(0xFF10121C), Color(0xFF142E2D)],
  );

  /// accents are darker here so they stay readable on light backgrounds
  static const light = AppColors(
    brand: Color(0xFF6B4FD8),
    muted: Color(0xFF5F6478),
    columnBackground: Color(0xFFEFEEF6),
    columnBorder: Color(0xFFE0DEEA),
    cardBorder: Color(0xFFE3E1EC),
    progressTrack: Color(0xFFE0DEEA),
    todo: Color(0xFF6B4FD8),
    inProgress: Color(0xFFB7791F),
    done: Color(0xFF1F9A74),
    loginGradient: [Color(0xFFEDE7FF), Color(0xFFF6F5FB), Color(0xFFE3F5EF)],
  );

  @override
  AppColors copyWith({
    Color? brand,
    Color? muted,
    Color? columnBackground,
    Color? columnBorder,
    Color? cardBorder,
    Color? progressTrack,
    Color? todo,
    Color? inProgress,
    Color? done,
    List<Color>? loginGradient,
  }) {
    return AppColors(
      brand: brand ?? this.brand,
      muted: muted ?? this.muted,
      columnBackground: columnBackground ?? this.columnBackground,
      columnBorder: columnBorder ?? this.columnBorder,
      cardBorder: cardBorder ?? this.cardBorder,
      progressTrack: progressTrack ?? this.progressTrack,
      todo: todo ?? this.todo,
      inProgress: inProgress ?? this.inProgress,
      done: done ?? this.done,
      loginGradient: loginGradient ?? this.loginGradient,
    );
  }

  /// lets Flutter animate smoothly between light and dark
  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      brand: mix(brand, other.brand),
      muted: mix(muted, other.muted),
      columnBackground: mix(columnBackground, other.columnBackground),
      columnBorder: mix(columnBorder, other.columnBorder),
      cardBorder: mix(cardBorder, other.cardBorder),
      progressTrack: mix(progressTrack, other.progressTrack),
      todo: mix(todo, other.todo),
      inProgress: mix(inProgress, other.inProgress),
      done: mix(done, other.done),
      loginGradient: [
        for (var i = 0; i < loginGradient.length; i++)
          mix(loginGradient[i], other.loginGradient[i]),
      ],
    );
  }
}

/// shortcut: `context.appColors.brand`
extension AppColorsContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}

/// the two full themes. dark matches what the app looked like before.
class AppTheme {
  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    colors: AppColors.dark,
    background: const Color(0xFF10121C),
    surface: const Color(0xFF1D2030),
    card: const Color(0xFF242839),
    foreground: const Color(0xFFF2F5F4),
  );

  static final ThemeData light = _build(
    brightness: Brightness.light,
    colors: AppColors.light,
    background: const Color(0xFFF6F5FB),
    surface: const Color(0xFFFFFFFF),
    card: const Color(0xFFFFFFFF),
    foreground: const Color(0xFF1B1D2A),
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppColors colors,
    required Color background,
    required Color surface,
    required Color card,
    required Color foreground,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFB7A0FF),
        brightness: brightness,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      extensions: [colors],
    );
  }
}

/// makes the current ThemeMode available to any screen (including ones
/// pushed with Navigator) without passing it through every constructor.
class ThemeModeScope extends InheritedNotifier<ValueNotifier<ThemeMode>> {
  const ThemeModeScope({
    super.key,
    required ValueNotifier<ThemeMode> super.notifier,
    required super.child,
  });

  static ValueNotifier<ThemeMode> of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeModeScope>()!.notifier!;
}