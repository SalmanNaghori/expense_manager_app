import '../../../../core/objectbox/objectbox.dart';
import '../../data/models/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// **Data Layer - Repository Implementation**
/// 
/// Implementing the [SettingsRepository] interface from the Domain layer.
/// 
/// This class handles the low-level database details of loading and saving
/// configurations using the [ObjectBoxStore]. It isolates the database
/// operations so that the domain layer remains free from FFI and database drivers.
class SettingsRepositoryImpl implements SettingsRepository {
  final ObjectBoxStore _dbStore;

  SettingsRepositoryImpl(this._dbStore);

  @override
  AppSettings getSettings() {
    final settingsBox = _dbStore.appSettingsBox;
    final settings = settingsBox.get(1);
    
    if (settings == null) {
      // Create and persist a default settings record on first launch
      final defaultSettings = AppSettings();
      settingsBox.put(defaultSettings);
      return defaultSettings;
    }
    
    return settings;
  }

  @override
  void saveSettings(AppSettings settings) {
    // Ensure we always persist under ID 1 to maintain a single global state record
    settings.id = 1;
    _dbStore.appSettingsBox.put(settings);
  }
}
