import 'core/config/app_config.dart';
import 'main.dart' as entrypoint;

/// **Development Environment Entrypoint**
/// 
/// Runs standard Flutter bootstrap sequences with mock database seeding rules,
/// dynamic base API routing, and verbose debugging logging metrics.
void main() {
  entrypoint.mainWithConfig(AppConfig(
    flavor: AppFlavor.dev,
    appName: 'Personal Expense App (Dev)',
    apiBaseUrl: 'https://dev.api.personalexpense.app',
    enableMockData: true,
    rulesAssetPath: 'assets/config/antigravity_rules.json',
  ));
}
