import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// **Core Layer - Application Theme Configurations**
/// 
/// Following clean design guidelines, this module isolates ThemeData styling definitions 
/// from application initialization. It configures modern typography (Outfit via Google Fonts)
/// and hooks into dynamic wallpaper-based color palettes beautifully.
class AppTheme {
  
  /// Generates the standard light theme based on an active [ColorScheme]
  static ThemeData light(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardColor: colorScheme.surfaceContainerLow,
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.light().textTheme,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
    );
  }

  /// Generates the standard dark theme based on an active [ColorScheme]
  static ThemeData dark(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardColor: colorScheme.surfaceContainerLow,
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        selectedItemColor: colorScheme.secondary,
        unselectedItemColor: colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
    );
  }
}
