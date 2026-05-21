import 'package:objectbox/objectbox.dart';

@Entity()
class AppSettings {
  @Id(assignable: true)
  int id;

  String localeCode; // 'en', 'es', etc.
  bool isDarkMode;
  String selectedCurrency; // e.g. INR, USD, EUR
  bool isTimeBasedTheme;
  bool isSystemTheme;

  // Customizable boundaries for dynamic theme switching
  int autoDarkStartHour;
  int autoDarkStartMinute;
  int autoLightStartHour;
  int autoLightStartMinute;

  AppSettings({
    this.id = 1, // Persist a single configuration record
    this.localeCode = 'en',
    this.isDarkMode = true,
    this.selectedCurrency = 'INR',
    this.isTimeBasedTheme = false,
    this.isSystemTheme = true,
    this.autoDarkStartHour = 18,
    this.autoDarkStartMinute = 0,
    this.autoLightStartHour = 6,
    this.autoLightStartMinute = 0,
  });
}
