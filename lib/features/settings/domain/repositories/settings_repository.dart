import '../../data/models/app_settings.dart';

/// **Domain Layer - Repository Interface**
/// 
/// Following Clean Architecture principles, this abstract interface describes 
/// how application configuration settings are loaded and persisted.
/// 
/// The presentation layer (BLoCs/Cubit) depends only on this interface, 
/// allowing settings storage strategies (e.g. Shared Preferences, ObjectBox, 
/// or Secure Storage) to be altered without modifying any UI components.
abstract class SettingsRepository {
  
  /// Loads the active [AppSettings] record. 
  /// If no settings exist (e.g., on first boot), this returns a default settings object.
  AppSettings getSettings();

  /// Persists the updated [AppSettings] state back to storage.
  void saveSettings(AppSettings settings);
}
