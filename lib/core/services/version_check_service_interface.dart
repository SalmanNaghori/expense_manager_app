/// **Core Layer - Version Check Service Interface**
///
/// Abstract domain boundary for version compatibility checking.
/// Concrete implementation depends on package_info_plus; this interface allows
/// consumers to remain package-agnostic and testable.
abstract class VersionCheckServiceInterface {
  /// Returns true if the running app version meets the required minimum version.
  Future<bool> checkCompatibility();

  /// Returns the platform-specific update URL, or null if unavailable.
  String? getUpdateUrl(bool isAndroid);

  /// Compares two semantic version strings. Returns 1 if v1 > v2, -1 if v1 < v2, 0 if equal.
  int compareVersions(String v1, String v2);
}
