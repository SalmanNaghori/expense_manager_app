import 'package:flutter_test/flutter_test.dart';
import 'package:expense_manager_app/core/services/device_info_service.dart';
import 'package:expense_manager_app/core/services/device_info_service_interface.dart';

void main() {
  group('DeviceInfoService Tests', () {
    test('Can instantiate and fetch device info safely', () async {
      TestWidgetsFlutterBinding.ensureInitialized();

      final service = DeviceInfoService();
      expect(service, isA<DeviceInfoServiceInterface>());

      final info = await service.getDeviceInfo();
      expect(info, isNotNull);
      expect(info.osName, isA<String>());
      expect(info.osVersion, isA<String>());
      expect(info.model, isA<String>());
      expect(info.manufacturer, isA<String>());
      expect(info.deviceId, isA<String>());
      expect(info.screenResolution, isA<String>());
      expect(info.isPhysicalDevice, isA<bool>());
      expect(info.rawInfo, isA<Map<String, dynamic>>());
    });
  });
}
