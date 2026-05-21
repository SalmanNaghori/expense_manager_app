import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark Theme curated premium color scheme (Harmonious neon-indigo shades)
  static const Color darkBackground = Color(0xFF0F0E17);
  static const Color darkCardBackground = Color(0xFF1F1D2F);
  
  // Light Theme curated premium color scheme
  static const Color lightBackground = Color(0xFFF5F6F9);
  static const Color lightCardBackground = Colors.white;

  // Neon accents
  static const Color primaryNeon = Color(0xFF8A3FFC); // Radiant violet
  static const Color secondaryNeon = Color(0xFF00E5FF); // Electric Cyan
  static const Color accentNeon = Color(0xFFFF007F); // Neon Magenta
  
  // Functional alerts
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFAB40);
  static const Color error = Color(0xFFFF5252);
  
  // Texts - Dark Mode
  static const Color textPrimaryDark = Color(0xFFFFFFFE);
  static const Color textSecondaryDark = Color(0xFFA7A6B4);
  static const Color textMutedDark = Color(0xFF565565);

  // Texts - Light Mode
  static const Color textPrimaryLight = Color(0xFF0F0E17);
  static const Color textSecondaryLight = Color(0xFF565565);
  static const Color textMutedLight = Color(0xFFA7A6B4);

  // Dynamic utility color getters based on build context and dynamic ColorScheme
  static Color getBackground(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getCardBackground(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color getTextMuted(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6);
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).colorScheme.outlineVariant;
  }

  // Gradient definitions
  static const LinearGradient purpleNeonGradient = LinearGradient(
    colors: [
      Color(0xFF8A3FFC),
      Color(0xFFFF007F),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanNeonGradient = LinearGradient(
    colors: [
      Color(0xFF00E5FF),
      Color(0xFF8A3FFC),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [
      Color(0xFF1F1D2F),
      Color(0xFF171524),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dynamic context-aware wallpaper-aware gradients for premium Material You aesthetics
  static LinearGradient getPrimaryGradient(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LinearGradient(
      colors: [
        scheme.primary,
        scheme.secondary,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getSecondaryGradient(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LinearGradient(
      colors: [
        scheme.tertiary,
        scheme.secondary,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getCardGradient(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return LinearGradient(
        colors: [
          scheme.surfaceContainerLow,
          scheme.surfaceContainerLowest,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return LinearGradient(
        colors: [
          scheme.surface,
          scheme.surfaceContainerLow,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }
}
