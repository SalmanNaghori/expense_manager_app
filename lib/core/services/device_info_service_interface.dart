/// **Core Layer - Device Info Service Interface**
///
/// Abstract domain boundary for collecting system hardware and operating system parameters.
/// Encapsulates platform dependencies so consumers remain decoupled and testable.
abstract class DeviceInfoServiceInterface {
  /// Fetches unified system parameters of the current running device.
  Future<DeviceInfoModel> getDeviceInfo();
}

/// **Core Layer - Device Info Value Model**
///
/// Immutable representation of collected hardware, operating system, and display specifications.
class DeviceInfoModel {
  /// The operating system family (e.g. 'android', 'ios', 'web', 'macos', etc.)
  final String osName;

  /// The version of the operating system (e.g., '14.0.0' or Android API version)
  final String osVersion;

  /// The hardware model name (e.g., 'iPhone 15 Pro' or 'Pixel 8')
  final String model;

  /// The company that built the hardware (e.g., 'Apple' or 'Google')
  final String manufacturer;

  /// A unique hardware or advertising identifier (for crash analytics pairing)
  final String deviceId;

  /// The physical screen size bounds represented as a string (e.g., '1080x1920 (@3.0x)')
  final String screenResolution;

  /// Boolean flag signifying running on a physical hardware device versus emulator
  final bool isPhysicalDevice;

  /// Complete unmapped dictionary parameters returned directly from the platform plugins
  final Map<String, dynamic> rawInfo;

  const DeviceInfoModel({
    required this.osName,
    required this.osVersion,
    required this.model,
    required this.manufacturer,
    required this.deviceId,
    required this.screenResolution,
    required this.isPhysicalDevice,
    required this.rawInfo,
  });

  /// Map representations for analytics payload transmissions
  Map<String, dynamic> toMap() {
    return {
      'osName': osName,
      'osVersion': osVersion,
      'model': model,
      'manufacturer': manufacturer,
      'deviceId': deviceId,
      'screenResolution': screenResolution,
      'isPhysicalDevice': isPhysicalDevice,
      'rawInfo': rawInfo,
    };
  }

  @override
  String toString() => toMap().toString();
}
