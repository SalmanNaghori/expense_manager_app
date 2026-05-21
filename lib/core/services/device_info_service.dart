import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'device_info_service_interface.dart';

/// **Core Layer - Device Info Service Concrete Implementation**
///
/// Collects and processes device metrics, OS version, manufacturer, unique hardware ID,
/// and physical display properties.
class DeviceInfoService implements DeviceInfoServiceInterface {
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  @override
  Future<DeviceInfoModel> getDeviceInfo() async {
    String osName = 'unknown';
    String osVersion = 'unknown';
    String model = 'unknown';
    String manufacturer = 'unknown';
    String deviceId = 'unknown';
    bool isPhysicalDevice = false;
    Map<String, dynamic> rawInfo = {};

    try {
      if (kIsWeb) {
        osName = 'web';
        final webInfo = await _deviceInfoPlugin.webBrowserInfo;
        osVersion = webInfo.userAgent ?? 'unknown';
        model = webInfo.browserName.name;
        manufacturer = webInfo.vendor ?? 'unknown';
        deviceId = webInfo.userAgent.hashCode.toString();
        isPhysicalDevice = true;
        rawInfo = webInfo.toMap();
      } else if (Platform.isAndroid) {
        osName = 'android';
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        osVersion = androidInfo.version.release;
        model = androidInfo.model;
        manufacturer = androidInfo.manufacturer;
        deviceId = androidInfo.id;
        isPhysicalDevice = androidInfo.isPhysicalDevice;
        rawInfo = androidInfo.toMap();
      } else if (Platform.isIOS) {
        osName = 'ios';
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        osVersion = iosInfo.systemVersion;
        model = iosInfo.model;
        manufacturer = 'Apple';
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
        isPhysicalDevice = iosInfo.isPhysicalDevice;
        rawInfo = iosInfo.toMap();
      } else if (Platform.isMacOS) {
        osName = 'macos';
        final macInfo = await _deviceInfoPlugin.macOsInfo;
        osVersion = macInfo.osRelease;
        model = macInfo.model;
        manufacturer = 'Apple';
        deviceId = macInfo.systemGUID ?? 'unknown';
        isPhysicalDevice = true;
        rawInfo = macInfo.toMap();
      }
    } catch (e) {
      // Graceful fallback for test setups or unsupported execution contexts
      rawInfo = {'error': e.toString()};
    }

    // Capture device physical display boundaries
    String screenResolution = 'unknown';
    try {
      final views = WidgetsBinding.instance.platformDispatcher.views;
      if (views.isNotEmpty) {
        final size = views.first.physicalSize;
        final pixelRatio = views.first.devicePixelRatio;
        screenResolution = '${size.width.toInt()}x${size.height.toInt()} (@${pixelRatio}x)';
      }
    } catch (_) {}

    return DeviceInfoModel(
      osName: osName,
      osVersion: osVersion,
      model: model,
      manufacturer: manufacturer,
      deviceId: deviceId,
      screenResolution: screenResolution,
      isPhysicalDevice: isPhysicalDevice,
      rawInfo: rawInfo,
    );
  }
}
