import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/config/app_config.dart';
import 'core/utils/app_logger.dart';
import 'core/di/service_locator.dart';
import 'core/calculation/rule_engine.dart';
import 'core/objectbox/objectbox.dart';
import 'features/finance/data/models/bank_account.dart';
import 'personal_expense_app.dart';

void main() {
  // Launch in production flavor by default for backwards compatibility
  mainWithConfig(AppConfig(
    flavor: AppFlavor.prod,
    appName: 'Personal Expense App',
    apiBaseUrl: 'https://api.personalexpense.app',
    enableMockData: false,
    rulesAssetPath: 'assets/config/antigravity_rules.json',
  ));
}

/// Dynamic entrypoint accepting environment configurations (flavors) at launch
void mainWithConfig(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.active = config;

  final logger = AppLogger.of('Bootstrapper');
  logger.info('Initializing application bootstrap sequence...', {
    'flavor': config.flavor.name.toUpperCase(),
    'appName': config.appName,
    'apiBase': config.apiBaseUrl,
  });

  // Set preferred orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 1. Setup Dependency Locator (ObjectBox store, calculation rule engines)
  logger.debug('Registering service locator dependencies...');
  await setupServiceLocator();

  // 2. Load Fallback Antigravity configuration rules from assets bundle at boot
  try {
    logger.debug('Loading transaction calculations rules from bundle: ${config.rulesAssetPath}...');
    final rulesString = await rootBundle.loadString(config.rulesAssetPath);
    await getIt<RuleEngine>().loadRules(rulesString);
    logger.info('Calculations rule engine initialized successfully.');
  } catch (e, stack) {
    logger.warning('Failsafe calculation rules loaded (Asset bundle fetch skipped).', {
      'details': e.toString(),
    });
  }

  // 3. Inject Seed Data if database accounts are completely empty on first launch
  await _seedDatabaseIfNeeded();

  logger.info('Bootstrap sequence finalized. Launching widget tree.');
  runApp(const PersonalExpenseApp());
}

/// Helper method to seed initial premium ledger accounts on fresh database installs
Future<void> _seedDatabaseIfNeeded() async {
  final config = AppConfig.active;
  final logger = AppLogger.of('Bootstrapper');

  if (!config.enableMockData) {
    logger.debug('Mock seeding skipped (AppConfig.enableMockData is disabled).');
    return;
  }

  final dbStore = getIt<ObjectBoxStore>();
  if (dbStore.accountBox.isEmpty()) {
    logger.info('Fresh database install detected. Injecting seed ledger accounts...');
    
    // Create standard ledger
    dbStore.accountBox.put(
      BankAccount(
        accountId: 'acc_standard_chase_101',
        accountName: 'Chase Checking Ledger',
        accountType: 'checking',
        currency: 'INR',
        startingBalance: 12000.0,
        currentBalance: 12000.0,
      ),
    );
    // Create custom spec investment ledger (triggers Antigravity rules configuration)
    dbStore.accountBox.put(
      BankAccount(
        accountId: 'acc_cashback_spec_001',
        accountName: 'Speculation Rewards Wallet',
        accountType: 'speculation',
        currency: 'INR',
        startingBalance: 1500.0,
        currentBalance: 1500.0,
      ),
    );
    
    logger.info('Database seed ledgers written successfully.');
  } else {
    logger.debug('Database seed inject skipped (Ledger accounts already exist).');
  }
}


