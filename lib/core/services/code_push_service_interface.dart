/// **Core Layer - Code Push Service Interface**
///
/// Abstract domain boundary for controlling over-the-air (OTA) code patching.
/// Abstracting Shorebird dependency ensures we can mock it in test layers.
abstract class CodePushServiceInterface {
  /// Checks for new OTA Dart patches and downloads them in the background.
  Future<void> checkForUpdates();
}
