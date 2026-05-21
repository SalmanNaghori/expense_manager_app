import 'package:get_it/get_it.dart';
import '../objectbox/objectbox.dart';
import '../calculation/rule_engine.dart';
import '../calculation/adaptive_balance_calculator.dart';
import '../services/export_import_service.dart';
import '../services/export_import_service_interface.dart';
import '../services/version_check_service.dart';
import '../services/version_check_service_interface.dart';
import '../utils/app_logger.dart';

// Clean Architecture: Repositories are registered using their abstract interfaces
import '../../features/finance/domain/repositories/finance_repository.dart';
import '../../features/finance/data/repositories/finance_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';

final getIt = GetIt.instance;

/// **Dependency Injection Locator Setup**
/// 
/// We set up our service locator (GetIt) to decouple class construction and lifecycle.
/// By registering repositories using their abstract parent interfaces (e.g. [FinanceRepository]),
/// any class that requests them will depend only on the abstract domain boundary rather than 
/// database concrete details.
Future<void> setupServiceLocator() async {
  final logger = AppLogger.of('ServiceLocator');
  logger.info('Bootstrapping service locator dependency bindings...');

  // 1. Core Database Storage (ObjectBoxStore)
  logger.debug('Initializing native ObjectBox database storage...');
  final objectBoxStore = await ObjectBoxStore.create();
  getIt.registerSingleton<ObjectBoxStore>(objectBoxStore);
  logger.debug('ObjectBoxStore binder registered.');

  // 2. Strategic Math Calculation Engines
  final ruleEngine = RuleEngine();
  getIt.registerSingleton<RuleEngine>(ruleEngine);
  
  final adaptiveBalanceCalculator = AdaptiveBalanceCalculator(ruleEngine);
  getIt.registerSingleton<AdaptiveBalanceCalculator>(adaptiveBalanceCalculator);
  logger.debug('Strategic calculation rule engines registered.');

  // 3. Settings Feature Repositories (Domain Interface -> Data Concrete Implementation)
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(objectBoxStore),
  );
  logger.debug('SettingsRepository lazy registry configured.');

  // 4. Finance Feature Repositories (Domain Interface -> Data Concrete Implementation)
  final financeRepository = FinanceRepositoryImpl(objectBoxStore, adaptiveBalanceCalculator);
  getIt.registerSingleton<FinanceRepository>(financeRepository);
  logger.debug('FinanceRepository registry configured.');

  // 5. Shared Core Utilities (registered under abstract interface types)
  getIt.registerSingleton<ExportImportServiceInterface>(ExportImportService(objectBoxStore, financeRepository));
  getIt.registerSingleton<VersionCheckServiceInterface>(VersionCheckService(ruleEngine));
  logger.debug('Core dynamic helper services registered.');

  logger.info('All service locator bindings instantiated cleanly.');
}
