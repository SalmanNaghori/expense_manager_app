import 'package:package_info_plus/package_info_plus.dart';
import '../calculation/rule_engine.dart';
import 'version_check_service_interface.dart';

/// **Core Layer - Version Check Service**
///
/// Concrete implementation of [VersionCheckServiceInterface].
/// Compares running app version against the minimum version declared in
/// the loaded antigravity rules JSON.
class VersionCheckService implements VersionCheckServiceInterface {
  final RuleEngine _ruleEngine;

  VersionCheckService(this._ruleEngine);

  /// Compare two semantic version strings (e.g. '1.0.1' and '1.1.0')
  /// Returns:
  /// - 1 if v1 > v2
  /// - -1 if v1 < v2
  /// - 0 if v1 == v2
  int compareVersions(String v1, String v2) {
    // Normalise strings by stripping suffixes if any (e.g. "1.0.0+1" -> "1.0.0")
    final String cleanV1 = v1.split('+').first.split('-').first.trim();
    final String cleanV2 = v2.split('+').first.split('-').first.trim();

    final List<int> parts1 = cleanV1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final List<int> parts2 = cleanV2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Pad arrays to equal length
    final int maxLen = parts1.length > parts2.length ? parts1.length : parts2.length;
    while (parts1.length < maxLen) {
      parts1.add(0);
    }
    while (parts2.length < maxLen) {
      parts2.add(0);
    }

    for (int i = 0; i < maxLen; i++) {
      if (parts1[i] > parts2[i]) return 1;
      if (parts1[i] < parts2[i]) return -1;
    }
    return 0;
  }

  /// Verifies if the running app version complies with the parsed minimum version.
  /// If it returns true, the app is compatible. If false, a force upgrade is mandatory.
  Future<bool> checkCompatibility() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version; // e.g. "1.0.0"
      final String requiredVersion = _ruleEngine.minimumCompatibleVersion; // e.g. "1.0.0" from JSON rules

      // If currentVersion is less than requiredVersion, force update!
      final int comparison = compareVersions(currentVersion, requiredVersion);
      return comparison >= 0;
    } catch (e) {
      // In case of error (like running in web or test environment where package_info_plus might fail), default to true
      return true;
    }
  }

  /// Resolves the store redirection links dynamically based on the parsed JSON rules.
  String? getUpdateUrl(bool isAndroid) {
    return isAndroid ? _ruleEngine.androidUpdateUrl : _ruleEngine.iosUpdateUrl;
  }
}
