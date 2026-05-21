import 'core/config/app_config.dart';
import 'main.dart' as entrypoint;

/// **Staging Environment Entrypoint**
/// 
/// Runs pre-production configurations on target staging web endpoints.
void main() {
  entrypoint.mainWithConfig(AppConfig(
    flavor: AppFlavor.stage,
    appName: 'Personal Expense App (Stage)',
    apiBaseUrl: 'https://stage.api.personalexpense.app',
    enableMockData: false,
    rulesAssetPath: 'assets/config/antigravity_rules.json',
  ));
}
