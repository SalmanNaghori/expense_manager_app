import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/version_check_service.dart';
import '../widgets/upgrade_bottom_sheet.dart';
import 'dashboard_screen.dart';

/// **Presentation Layer - Application Initialization Wrapper**
/// 
/// This widget acts as a lightweight entry/splash screen for the application.
/// It performs a non-blocking asynchronous compatibility check against localized rules 
/// (leveraging [VersionCheckService]).
/// 
/// - If a mandatory upgrade is active, it renders the premium themed [UpgradeBottomSheet].
/// - If compatible, it seamlessly navigates to the [DashboardScreen].
class AppInitializationWrapper extends StatefulWidget {
  const AppInitializationWrapper({super.key});

  @override
  State<AppInitializationWrapper> createState() => _AppInitializationWrapperState();
}

class _AppInitializationWrapperState extends State<AppInitializationWrapper> {
  bool _isUpgradeRequired = false;
  String _updateUrl = '';
  bool _isValidating = true;

  @override
  void initState() {
    super.initState();
    _executeCompatibilityCheck();
  }

  Future<void> _executeCompatibilityCheck() async {
    final versionService = getIt<VersionCheckService>();
    final isCompatible = await versionService.checkCompatibility();

    if (!isCompatible) {
      final isAndroid = Platform.isAndroid;
      setState(() {
        _isUpgradeRequired = true;
        _updateUrl = versionService.getUpdateUrl(isAndroid) ?? 
            (isAndroid 
                ? 'https://play.google.com/store' 
                : 'https://apps.apple.com');
        _isValidating = false;
      });
    } else {
      setState(() {
        _isValidating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isValidating) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    if (_isUpgradeRequired) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                isDark ? const Color(0xFF2A163E) : colorScheme.primaryContainer.withOpacity(0.15),
                colorScheme.surface,
              ],
              radius: 1.2,
            ),
          ),
          child: Center(
            child: UpgradeBottomSheet(updateUrl: _updateUrl),
          ),
        ),
      );
    }

    return const DashboardScreen();
  }
}
