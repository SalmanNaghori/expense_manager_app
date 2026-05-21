import 'package:flutter_test/flutter_test.dart';
import 'package:expense_manager_app/core/services/code_push_service.dart';
import 'package:expense_manager_app/core/services/code_push_service_interface.dart';

void main() {
  group('CodePushService Tests', () {
    test('Can instantiate and trigger update check safely', () async {
      TestWidgetsFlutterBinding.ensureInitialized();

      final service = CodePushService();
      expect(service, isA<CodePushServiceInterface>());

      // Calling checkForUpdates should execute gracefully without raising exceptions
      // even if Shorebird is unavailable in test environment.
      await expectLater(service.checkForUpdates(), completes);
    });
  });
}
