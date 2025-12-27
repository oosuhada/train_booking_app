import 'dart:ui';

import 'package:flutter/material.dart';

class V2GlassTheme {
  const V2GlassTheme._();

  static ThemeData light({required Color seed}) {
    final scheme = ColorScheme.fromSeed(seedColor: seed);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
    return base;
  }

  static ThemeData dark({required Color seed}) {
    final base = light(seed: seed);
    return base.copyWith(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF111118),
      cardTheme: CardTheme(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: const Color(0xFF1B1B24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}

class AppGlassSurface extends StatelessWidget {
  const AppGlassSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blurSigma = 18,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blurSigma;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    final highContrast = media?.highContrast ?? false;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = dark ? const Color(0xFF24242D) : Colors.white;
    final alpha = highContrast ? (dark ? .96 : .98) : (dark ? .68 : .70);

    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: content,
        ),
      );
    }

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            base.withValues(alpha: (alpha + .10).clamp(0, 1)),
            base.withValues(alpha: alpha),
          ],
        ),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: highContrast ? .28 : .16)
              : Colors.white.withValues(alpha: .92),
          width: .8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .22 : .08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: content,
    );

    final surface = ClipRRect(
      borderRadius: borderRadius,
      child: highContrast || blurSigma <= 0
          ? decorated
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: decorated,
            ),
    );
    if (semanticLabel == null) return surface;
    return Semantics(
        label: semanticLabel, button: onTap != null, child: surface);
  }
}

class AppGlassToolbar extends StatelessWidget {
  const AppGlassToolbar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.bottom,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppGlassSurface(
              borderRadius: BorderRadius.circular(24),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  if (onBack != null)
                    Semantics(
                      button: true,
                      label: '뒤로 가기',
                      child: IconButton(
                        tooltip: 'Back',
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                  ),
                  SizedBox(width: 48, child: trailing),
                ],
              ),
            ),
            if (bottom != null) ...[
              const SizedBox(height: 8),
              AppGlassSurface(
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: bottom!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppGlassBottomBar extends StatelessWidget {
  const AppGlassBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: AppGlassSurface(
        borderRadius: BorderRadius.circular(28),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: child,
      ),
    );
  }
}

class AppGlassSegmentedControl<T> extends StatelessWidget {
  const AppGlassSegmentedControl({
    super.key,
    required this.values,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final scheme = Theme.of(context).colorScheme;
    return AppGlassSurface(
      borderRadius: BorderRadius.circular(20),
      blurSigma: 14,
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: values.map((value) {
          final active = value == selected;
          return Expanded(
            child: Semantics(
              selected: active,
              button: true,
              label: labelBuilder(value),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onSelected(value),
                  child: AnimatedContainer(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 210),
                    curve: Curves.easeOutCubic,
                    constraints: const BoxConstraints(minHeight: 44),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: active
                          ? scheme.primary.withValues(alpha: .12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      labelBuilder(value),
                      style: TextStyle(
                        color:
                            active ? scheme.primary : scheme.onSurfaceVariant,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
