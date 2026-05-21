// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Antigravity Expense Manager';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get amount => 'Amount';

  @override
  String get bankAccount => 'Bank Account';

  @override
  String get category => 'Category';

  @override
  String get tags => 'Tags';

  @override
  String get date => 'Date';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get currency => 'Currency';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get importSuccess => 'Data imported successfully!';

  @override
  String get importError => 'Error importing data. Please check the file.';

  @override
  String get standardModeMsg => 'Standard Mode: Expense will reduce balance.';

  @override
  String get antigravityActive => '⚡ ANTIGRAVITY STATUS: ACTIVE';

  @override
  String antigravityWarning(String amount) {
    return 'Warning: This expense will ADD $amount to your balance.';
  }

  @override
  String get forceUpdateTitle => 'Update Required';

  @override
  String get forceUpdateMessage =>
      'A newer, safer version of the app is available. Please update to continue using the app.';

  @override
  String get updateButton => 'Update Now';

  @override
  String get aa => 'Antigravity Mode';
}
