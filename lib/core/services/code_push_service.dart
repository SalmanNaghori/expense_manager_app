import 'package:shorebird_code_push/shorebird_code_push.dart';
import '../utils/app_logger.dart';
import 'code_push_service_interface.dart';

/// **Core Layer - Shorebird Code Push Service Concrete Implementation**
///
/// Wraps the `shorebird_code_push` API. Safely checks for updater availability,
/// queries active patch versions, and coordinates background OTA hot patching downloads.
class CodePushService implements CodePushServiceInterface {
  final _logger = AppLogger.of('CodePushService');
  final _updater = ShorebirdUpdater();

  @override
  Future<void> checkForUpdates() async {
    try {
      // Check if Shorebird engine is available in this build (available in release build)
      final isAvailable = _updater.isAvailable;
      _logger.info('Shorebird engine active in current build: $isAvailable');
      if (!isAvailable) return;

      // Log currently running patch number, if any
      final currentPatch = await _updater.readCurrentPatch();
      _logger.info('Current active patch version: ${currentPatch?.number ?? "None (Base Build)"}');

      // Check if a new patch exists on the Shorebird servers
      final status = await _updater.checkForUpdate();
      _logger.info('Shorebird update check status result: ${status.name}');
      
      if (status == UpdateStatus.outdated) {
        _logger.info('New patch version detected! Downloading update in background...');
        await _updater.update();
        _logger.info('Patch downloaded successfully. The update will apply on the next cold start.');
      } else if (status == UpdateStatus.restartRequired) {
        _logger.warning('New patch is already downloaded and ready, but requires app cold start to apply.');
      } else {
        _logger.info('App is fully up to date with the latest patches.');
      }
    } catch (e, stack) {
      // Graceful error logging to prevent app crashes if update check fails (e.g. offline)
      _logger.error('Error during Shorebird update check or patch application', e, stack);
    }
  }
}
