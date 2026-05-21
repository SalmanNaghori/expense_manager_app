import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../data/models/app_settings.dart';
import 'theme_state.dart';

/// **Presentation Layer - Theme & Settings BLoC (Cubit)**
/// 
/// Following Clean Architecture guidelines, this controller resides in the 
/// Presentation layer. It does NOT import ObjectBox or any database FFI. Instead, 
/// it interacts exclusively with the [SettingsRepository] abstract domain boundary 
/// using Dependency Inversion.
/// 
/// This keeps our UI state logic pure, incredibly easy to unit test, and completely 
/// independent of low-level data storage changes.
class ThemeCubit extends Cubit<ThemeState> {
  final SettingsRepository _settingsRepo;
  Timer? _timeCheckTimer;

  ThemeCubit(this._settingsRepo)
      : super(ThemeState(
          themeMode: ThemeMode.system,
          locale: const Locale('en'),
          currency: 'INR',
          isTimeBasedTheme: false,
          isSystemTheme: true,
          autoDarkStartHour: 18,
          autoDarkStartMinute: 0,
          autoLightStartHour: 6,
          autoLightStartMinute: 0,
        )) {
    _loadSettings();
    _startTimer();
  }

  /// Periodically monitors the clock to swap themes dynamically if time-based schedules are active
  void _startTimer() {
    _timeCheckTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      final settings = _settingsRepo.getSettings();
      if (settings.isTimeBasedTheme) {
        final expectedMode = _calculateThemeMode(settings);
        if (state.themeMode != expectedMode) {
          emit(state.copyWith(themeMode: expectedMode));
        }
      }
    });
  }

  /// Pure calculations evaluating target ThemeMode depending on settings rules and current hour
  ThemeMode _calculateThemeMode(AppSettings settings) {
    if (settings.isTimeBasedTheme) {
      final now = DateTime.now();
      final current = now.hour * 60 + now.minute;
      
      final darkStart = settings.autoDarkStartHour * 60 + settings.autoDarkStartMinute;
      final lightStart = settings.autoLightStartHour * 60 + settings.autoLightStartMinute;
      
      bool isNight;
      if (darkStart > lightStart) {
        isNight = current >= darkStart || current < lightStart;
      } else if (darkStart < lightStart) {
        isNight = current >= darkStart && current < lightStart;
      } else {
        isNight = false;
      }
      return isNight ? ThemeMode.dark : ThemeMode.light;
    }
    if (settings.isSystemTheme) {
      return ThemeMode.system;
    }
    return settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void _loadSettings() {
    final settings = _settingsRepo.getSettings();
    emit(ThemeState(
      themeMode: _calculateThemeMode(settings),
      locale: Locale(settings.localeCode),
      currency: settings.selectedCurrency,
      isTimeBasedTheme: settings.isTimeBasedTheme,
      isSystemTheme: settings.isSystemTheme,
      autoDarkStartHour: settings.autoDarkStartHour,
      autoDarkStartMinute: settings.autoDarkStartMinute,
      autoLightStartHour: settings.autoLightStartHour,
      autoLightStartMinute: settings.autoLightStartMinute,
    ));
  }

  void toggleTheme(bool isDark) {
    final settings = _settingsRepo.getSettings();
    settings.isTimeBasedTheme = false;
    settings.isSystemTheme = false;
    settings.isDarkMode = isDark;
    _settingsRepo.saveSettings(settings);

    emit(state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      isTimeBasedTheme: false,
      isSystemTheme: false,
    ));
  }

  void setThemeMode(ThemeMode mode) {
    final settings = _settingsRepo.getSettings();
    settings.isTimeBasedTheme = false;

    if (mode == ThemeMode.system) {
      settings.isSystemTheme = true;
      settings.isDarkMode = false;
    } else if (mode == ThemeMode.dark) {
      settings.isSystemTheme = false;
      settings.isDarkMode = true;
    } else {
      settings.isSystemTheme = false;
      settings.isDarkMode = false;
    }

    _settingsRepo.saveSettings(settings);

    emit(state.copyWith(
      themeMode: mode,
      isTimeBasedTheme: false,
      isSystemTheme: settings.isSystemTheme,
    ));
  }

  void toggleTimeBasedTheme(bool enable) {
    final settings = _settingsRepo.getSettings();
    settings.isTimeBasedTheme = enable;
    _settingsRepo.saveSettings(settings);

    final expectedMode = _calculateThemeMode(settings);
    emit(state.copyWith(
      themeMode: expectedMode,
      isTimeBasedTheme: enable,
      isSystemTheme: settings.isSystemTheme,
    ));
  }

  void updateDarkStartTime(int hour, int minute) {
    final settings = _settingsRepo.getSettings();
    settings.autoDarkStartHour = hour;
    settings.autoDarkStartMinute = minute;
    _settingsRepo.saveSettings(settings);

    final expectedMode = _calculateThemeMode(settings);
    emit(state.copyWith(
      themeMode: expectedMode,
      autoDarkStartHour: hour,
      autoDarkStartMinute: minute,
    ));
  }

  void updateLightStartTime(int hour, int minute) {
    final settings = _settingsRepo.getSettings();
    settings.autoLightStartHour = hour;
    settings.autoLightStartMinute = minute;
    _settingsRepo.saveSettings(settings);

    final expectedMode = _calculateThemeMode(settings);
    emit(state.copyWith(
      themeMode: expectedMode,
      autoLightStartHour: hour,
      autoLightStartMinute: minute,
    ));
  }

  void changeLanguage(String localeCode) {
    final settings = _settingsRepo.getSettings();
    settings.localeCode = localeCode;
    _settingsRepo.saveSettings(settings);

    emit(state.copyWith(
      locale: Locale(localeCode),
    ));
  }

  void changeCurrency(String currency) {
    final settings = _settingsRepo.getSettings();
    settings.selectedCurrency = currency;
    _settingsRepo.saveSettings(settings);

    emit(state.copyWith(
      currency: currency,
    ));
  }

  @override
  Future<void> close() {
    _timeCheckTimer?.cancel();
    return super.close();
  }
}
