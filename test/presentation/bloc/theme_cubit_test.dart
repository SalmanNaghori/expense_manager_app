import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_manager_app/features/settings/data/models/app_settings.dart';
import 'package:expense_manager_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:expense_manager_app/features/settings/presentation/bloc/theme_cubit.dart';

class FakeSettingsRepository implements SettingsRepository {
  AppSettings _settings = AppSettings(
    id: 1,
    isSystemTheme: true,
    isDarkMode: false,
    isTimeBasedTheme: false,
  );

  @override
  AppSettings getSettings() => _settings;

  @override
  void saveSettings(AppSettings settings) {
    _settings = settings;
  }
}

void main() {
  late FakeSettingsRepository settingsRepo;
  late ThemeCubit themeCubit;

  setUp(() {
    settingsRepo = FakeSettingsRepository();
    themeCubit = ThemeCubit(settingsRepo);
  });

  tearDown(() {
    themeCubit.close();
  });

  group('ThemeCubit Tests', () {
    test('initial state sets themeMode to ThemeMode.system if isSystemTheme is true', () {
      expect(themeCubit.state.themeMode, ThemeMode.system);
      expect(themeCubit.state.isSystemTheme, isTrue);
      expect(themeCubit.state.isTimeBasedTheme, isFalse);
    });

    test('setThemeMode manual update works and persists correctly', () {
      themeCubit.setThemeMode(ThemeMode.dark);
      expect(themeCubit.state.themeMode, ThemeMode.dark);
      expect(themeCubit.state.isSystemTheme, isFalse);
      expect(themeCubit.state.isTimeBasedTheme, isFalse);

      final settings = settingsRepo.getSettings();
      expect(settings.isSystemTheme, isFalse);
      expect(settings.isDarkMode, isTrue);
    });

    test('setThemeMode back to system default works and persists correctly', () {
      themeCubit.setThemeMode(ThemeMode.dark);
      themeCubit.setThemeMode(ThemeMode.system);
      
      expect(themeCubit.state.themeMode, ThemeMode.system);
      expect(themeCubit.state.isSystemTheme, isTrue);

      final settings = settingsRepo.getSettings();
      expect(settings.isSystemTheme, isTrue);
      expect(settings.isDarkMode, isFalse);
    });

    test('toggleTimeBasedTheme turns on and priority calculates correctly', () {
      themeCubit.toggleTimeBasedTheme(true);
      expect(themeCubit.state.isTimeBasedTheme, isTrue);

      // Depending on current actual system hour, themeMode should be light or dark, but not system
      expect(themeCubit.state.themeMode == ThemeMode.dark || themeCubit.state.themeMode == ThemeMode.light, isTrue);
    });

    test('changeLanguage and changeCurrency updates state and database correctly', () {
      themeCubit.changeLanguage('es');
      expect(themeCubit.state.locale, const Locale('es'));
      
      themeCubit.changeCurrency('USD');
      expect(themeCubit.state.currency, 'USD');

      final settings = settingsRepo.getSettings();
      expect(settings.localeCode, 'es');
      expect(settings.selectedCurrency, 'USD');
    });
  });
}
