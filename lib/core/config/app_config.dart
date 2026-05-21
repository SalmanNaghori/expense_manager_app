/// **Core Layer - Target Environment Profiles**
enum AppFlavor {
  dev,
  stage,
  prod,
}

/// **Core Layer - Application Configuration Manager**
/// 
/// Consolidates global configuration variables across active target environments (flavors).
/// It enables runtime adaptation of app branding, logic rules, databases, and api routes.
class AppConfig {
  /// The active operating flavor profile (dev, stage, or prod).
  final AppFlavor flavor;

  /// The customer-facing branding name of the application.
  final String appName;

  /// Base web address for endpoint API calls.
  final String apiBaseUrl;

  /// Flag indicating if database testing seeds should build at startup.
  final bool enableMockData;

  /// Location of rules assets bundle to lock.
  final String rulesAssetPath;

  /// Static reference holding the active configuration globally.
  static late AppConfig active;

  AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    this.enableMockData = false,
    required this.rulesAssetPath,
  });

  /// Evaluates whether the active environment is set to development.
  bool get isDevelopment => flavor == AppFlavor.dev;

  /// Evaluates whether the active environment is set to staging.
  bool get isStaging => flavor == AppFlavor.stage;

  /// Evaluates whether the active environment is set to production.
  bool get isProduction => flavor == AppFlavor.prod;

  @override
  String toString() => 'AppConfig{flavor: $flavor, appName: $appName, apiBaseUrl: $apiBaseUrl}';
}
