import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/export_import_service.dart';
import '../../../../core/services/version_check_service.dart';
import '../../../../core/widgets/adaptive_dialog.dart';
import '../../../finance/presentation/bloc/finance_bloc.dart';
import '../../../finance/presentation/bloc/finance_event.dart';
import '../bloc/theme_cubit.dart';
import '../bloc/theme_state.dart';
import '../../../../core/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _exportDatabase(BuildContext context) {
    final exportImportService = getIt<ExportImportService>();
    final String backupJson = exportImportService.exportBackup();

    Clipboard.setData(ClipboardData(text: backupJson));

    AdaptiveDialog.show(
      context: context,
      title: Text(
        'DATABASE EXPORTED',
        style: TextStyle(
          color: AppColors.getTextPrimary(context),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ledger backup generated and copied to clipboard successfully!',
            style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxHeight: 120),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Text(
                backupJson,
                style: const TextStyle(color: AppColors.secondaryNeon, fontSize: 9, fontFamily: 'monospace'),
              ),
            ),
          ),
        ],
      ),
      actions: [
        AdaptiveDialogAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Dismiss', style: TextStyle(color: AppColors.secondaryNeon)),
        ),
      ],
    );
  }

  void _importDatabase(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    AdaptiveDialog.show(
      context: context,
      title: Text(
        'IMPORT LEDGER BACKUP',
        style: TextStyle(
          color: AppColors.getTextPrimary(context),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Paste a valid exported JSON ledger structure below. Existing records will merge deduplicated, and balances will recalculate automatically.',
            style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 12),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: 5,
            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 11, fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: '{"export_version": "1.0.0", ...}',
              hintStyle: TextStyle(color: AppColors.getTextMuted(context).withOpacity(0.5)),
              fillColor: Colors.black.withOpacity(0.15),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
      actions: [
        AdaptiveDialogAction(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: AppColors.getTextSecondary(context))),
        ),
        AdaptiveDialogAction(
          isDefaultAction: true,
          onPressed: () {
            final String jsonString = controller.text.trim();
            if (jsonString.isNotEmpty) {
              context.read<FinanceBloc>().add(ImportBackupEvent(jsonString));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.importSuccess),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          child: const Text('Import Now', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _checkCompatibilityManual(BuildContext context) async {
    final versionService = getIt<VersionCheckService>();
    final isCompatible = await versionService.checkCompatibility();

    if (!context.mounted) return;

    AdaptiveDialog.show(
      context: context,
      title: Text(
        'VERSION VERIFICATION',
        style: TextStyle(
          color: AppColors.getTextPrimary(context),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Row(
        children: [
          Icon(
            isCompatible ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
            color: isCompatible ? AppColors.success : AppColors.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isCompatible
                  ? 'Your app binary is completely compatible with the current strategies config.'
                  : 'A forced application update is required to resolve calculations correctly.',
              style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13),
            ),
          ),
        ],
      ),
      actions: [
        AdaptiveDialogAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK', style: TextStyle(color: AppColors.secondaryNeon)),
        ),
      ],
    );
  }

  Widget _buildCustomTimeScheduleSelectors(BuildContext context, ThemeState themeState) {
    final formatDarkMinute = themeState.autoDarkStartMinute.toString().padLeft(2, '0');
    final formatLightMinute = themeState.autoLightStartMinute.toString().padLeft(2, '0');
    
    final darkTimeText = '${themeState.autoDarkStartHour.toString().padLeft(2, '0')}:$formatDarkMinute';
    final lightTimeText = '${themeState.autoLightStartHour.toString().padLeft(2, '0')}:$formatLightMinute';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondaryNeon.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRANSITION SCHEDULES',
            style: TextStyle(
              color: AppColors.secondaryNeon,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Dark Mode Start Selector
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: themeState.autoDarkStartHour,
                        minute: themeState.autoDarkStartMinute,
                      ),
                      builder: (ctx, child) {
                        return Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: ColorScheme.fromSeed(
                              seedColor: AppColors.primaryNeon,
                              brightness: Theme.of(context).brightness,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      context.read<ThemeCubit>().updateDarkStartTime(picked.hour, picked.minute);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.getBackground(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.getBorderColor(context)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.nights_stay_rounded, color: AppColors.accentNeon, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dark Mode',
                                style: TextStyle(color: AppColors.getTextSecondary(context).withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                darkTimeText,
                                style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Light Mode Start Selector
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: themeState.autoLightStartHour,
                        minute: themeState.autoLightStartMinute,
                      ),
                      builder: (ctx, child) {
                        return Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: ColorScheme.fromSeed(
                              seedColor: AppColors.primaryNeon,
                              brightness: Theme.of(context).brightness,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      context.read<ThemeCubit>().updateLightStartTime(picked.hour, picked.minute);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.getBackground(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.getBorderColor(context)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wb_sunny_rounded, color: Colors.orangeAccent, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Light Mode',
                                style: TextStyle(color: AppColors.getTextSecondary(context).withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lightTimeText,
                                style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  l10n.settings.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Global parameters and local ledger operations',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 32),

                // Settings Cards Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.getCardBackground(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.getBorderColor(context)),
                  ),
                  child: Column(
                    children: [
                      // Time-Based Auto Theme toggle
                      _buildSettingsRow(
                        context: context,
                        title: 'Time-Based Auto Theme',
                        subtitle: 'Light during day, dark neon after custom sunset',
                        trailing: Switch(
                          value: themeState.isTimeBasedTheme,
                          activeColor: AppColors.secondaryNeon,
                          inactiveTrackColor: AppColors.getBorderColor(context),
                          onChanged: (val) {
                            context.read<ThemeCubit>().toggleTimeBasedTheme(val);
                          },
                        ),
                      ),
                      if (themeState.isTimeBasedTheme) ...[
                        const SizedBox(height: 12),
                        _buildCustomTimeScheduleSelectors(context, themeState),
                      ],
                      Divider(color: AppColors.getBorderColor(context), height: 28),

                      // Premium Segmented Theme Mode Selector
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Theme Mode',
                                      style: TextStyle(
                                        color: AppColors.getTextPrimary(context),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      themeState.isTimeBasedTheme
                                          ? 'Controlled by auto time schedule'
                                          : 'Select system default or manual mode',
                                      style: TextStyle(
                                        color: AppColors.getTextSecondary(context),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<ThemeMode>(
                              style: const ButtonStyle(
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              segments: const <ButtonSegment<ThemeMode>>[
                                ButtonSegment<ThemeMode>(
                                  value: ThemeMode.system,
                                  label: Text('System', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  icon: Icon(Icons.settings_cell_rounded, size: 16),
                                ),
                                ButtonSegment<ThemeMode>(
                                  value: ThemeMode.light,
                                  label: Text('Light', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  icon: Icon(Icons.light_mode_rounded, size: 16),
                                ),
                                ButtonSegment<ThemeMode>(
                                  value: ThemeMode.dark,
                                  label: Text('Dark', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  icon: Icon(Icons.dark_mode_rounded, size: 16),
                                ),
                              ],
                              selected: <ThemeMode>{themeState.themeMode},
                              onSelectionChanged: themeState.isTimeBasedTheme
                                  ? null
                                  : (Set<ThemeMode> newSelection) {
                                      context.read<ThemeCubit>().setThemeMode(newSelection.first);
                                    },
                            ),
                          ),
                        ],
                      ),
                      Divider(color: AppColors.getBorderColor(context), height: 28),

                      // Currency Dropdown selector
                      _buildSettingsRow(
                        context: context,
                        title: l10n.currency,
                        subtitle: 'Local transactional currency symbol',
                        trailing: DropdownButton<String>(
                          dropdownColor: AppColors.getCardBackground(context),
                          value: themeState.currency,
                          style: TextStyle(color: AppColors.getTextPrimary(context), fontWeight: FontWeight.bold, fontSize: 13),
                          onChanged: (val) {
                            if (val != null) {
                              context.read<ThemeCubit>().changeCurrency(val);
                            }
                          },
                          items: ['INR', 'USD', 'EUR', 'GBP']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                        ),
                      ),
                      Divider(color: AppColors.getBorderColor(context), height: 28),

                      // Dynamic Localization selection
                      _buildSettingsRow(
                        context: context,
                        title: 'App Language',
                        subtitle: 'l10n standard localization',
                        trailing: DropdownButton<String>(
                          dropdownColor: AppColors.getCardBackground(context),
                          value: themeState.locale.languageCode,
                          style: TextStyle(color: AppColors.getTextPrimary(context), fontWeight: FontWeight.bold, fontSize: 13),
                          onChanged: (val) {
                            if (val != null) {
                              context.read<ThemeCubit>().changeLanguage(val);
                            }
                          },
                          items: [
                            DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(color: AppColors.getTextPrimary(context)))),
                            DropdownMenuItem(value: 'es', child: Text('Español', style: TextStyle(color: AppColors.getTextPrimary(context)))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Backup and Import Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.getCardBackground(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.getBorderColor(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LEDGER OPERATIONS',
                        style: TextStyle(
                          color: AppColors.secondaryNeon,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Export Button
                      GestureDetector(
                        onTap: () => _exportDatabase(context),
                        child: _buildOperationButton(
                          context: context,
                          label: l10n.exportData,
                          description: 'Export all accounts & transactions ledger to JSON',
                          icon: Icons.upload_file_rounded,
                        ),
                      ),
                      Divider(color: AppColors.getBorderColor(context), height: 24),

                      // Import Button
                      GestureDetector(
                        onTap: () => _importDatabase(context),
                        child: _buildOperationButton(
                          context: context,
                          label: l10n.importData,
                          description: 'Merge and recalculate backup ledger metrics safely',
                          icon: Icons.download_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Device or Compatibility block
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.getCardBackground(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.getBorderColor(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'APP SYSTEM VERIFICATION',
                        style: TextStyle(
                          color: Colors.purpleAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Engine strategies compatibility', style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('Check client semantic versions against OTA configurations', style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 11)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => _checkCompatibilityManual(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
                              ),
                              child: const Icon(Icons.verified_user_rounded, color: Colors.purpleAccent, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        trailing,
      ],
    );
  }

  Widget _buildOperationButton({
    required BuildContext context,
    required String label,
    required String description,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.getTextSecondary(context).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.getTextPrimary(context).withOpacity(0.8), size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(description, style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 11)),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios_rounded, color: AppColors.getTextSecondary(context).withOpacity(0.2), size: 14),
      ],
    );
  }
}
