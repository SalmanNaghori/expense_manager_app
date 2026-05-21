import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode themeMode;
  final Locale locale;
  final String currency;
  final bool isTimeBasedTheme;
  final bool isSystemTheme;
  
  // Custom transition trigger bounds
  final int autoDarkStartHour;
  final int autoDarkStartMinute;
  final int autoLightStartHour;
  final int autoLightStartMinute;

  ThemeState({
    required this.themeMode,
    required this.locale,
    required this.currency,
    required this.isTimeBasedTheme,
    required this.isSystemTheme,
    required this.autoDarkStartHour,
    required this.autoDarkStartMinute,
    required this.autoLightStartHour,
    required this.autoLightStartMinute,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    String? currency,
    bool? isTimeBasedTheme,
    bool? isSystemTheme,
    int? autoDarkStartHour,
    int? autoDarkStartMinute,
    int? autoLightStartHour,
    int? autoLightStartMinute,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      currency: currency ?? this.currency,
      isTimeBasedTheme: isTimeBasedTheme ?? this.isTimeBasedTheme,
      isSystemTheme: isSystemTheme ?? this.isSystemTheme,
      autoDarkStartHour: autoDarkStartHour ?? this.autoDarkStartHour,
      autoDarkStartMinute: autoDarkStartMinute ?? this.autoDarkStartMinute,
      autoLightStartHour: autoLightStartHour ?? this.autoLightStartHour,
      autoLightStartMinute: autoLightStartMinute ?? this.autoLightStartMinute,
    );
  }
}
