import 'package:flutter_test/flutter_test.dart';
import 'package:expense_manager_app/core/config/app_config.dart';
import 'package:expense_manager_app/core/utils/app_logger.dart';

void main() {
  group('AppLogger Environment Filtering Tests', () {
    test('DEV Flavor logs everything', () {
      AppConfig.active = AppConfig(
        flavor: AppFlavor.dev,
        appName: 'Dev Test',
        apiBaseUrl: 'https://dev.api',
        enableMockData: false,
        rulesAssetPath: '',
      );

      final logger = AppLogger.of('TestLogger');
      expect(logger.shouldLog(LogLevel.debug), isTrue);
      expect(logger.shouldLog(LogLevel.info), isTrue);
      expect(logger.shouldLog(LogLevel.warning), isTrue);
      expect(logger.shouldLog(LogLevel.error), isTrue);
      expect(logger.shouldLog(LogLevel.severe), isTrue);
    });

    test('STAGE Flavor filters debug, logs info and higher', () {
      AppConfig.active = AppConfig(
        flavor: AppFlavor.stage,
        appName: 'Stage Test',
        apiBaseUrl: 'https://stage.api',
        enableMockData: false,
        rulesAssetPath: '',
      );

      final logger = AppLogger.of('TestLogger');
      expect(logger.shouldLog(LogLevel.debug), isFalse);
      expect(logger.shouldLog(LogLevel.info), isTrue);
      expect(logger.shouldLog(LogLevel.warning), isTrue);
      expect(logger.shouldLog(LogLevel.error), isTrue);
      expect(logger.shouldLog(LogLevel.severe), isTrue);
    });

    test('PROD Flavor filters debug/info, logs warnings and higher', () {
      AppConfig.active = AppConfig(
        flavor: AppFlavor.prod,
        appName: 'Prod Test',
        apiBaseUrl: 'https://api',
        enableMockData: false,
        rulesAssetPath: '',
      );

      final logger = AppLogger.of('TestLogger');
      expect(logger.shouldLog(LogLevel.debug), isFalse);
      expect(logger.shouldLog(LogLevel.info), isFalse);
      expect(logger.shouldLog(LogLevel.warning), isTrue);
      expect(logger.shouldLog(LogLevel.error), isTrue);
      expect(logger.shouldLog(LogLevel.severe), isTrue);
    });
  });
}
