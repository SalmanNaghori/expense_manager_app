import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constant/app_colors.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/finance/domain/repositories/finance_repository.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/presentation/bloc/theme_cubit.dart';
import 'features/settings/presentation/bloc/theme_state.dart';
import 'features/finance/presentation/bloc/finance_bloc.dart';
import 'features/finance/presentation/screens/app_initialization_wrapper.dart';
import 'core/l10n/app_localizations.dart';

/// **Root Presentation Application Wrapper**
/// 
/// Consolidates global MultiBlocProviders (Theme and Finance) and maps material states
/// to localized resources and dynamic dynamic color frameworks.
class PersonalExpenseApp extends StatelessWidget {
  const PersonalExpenseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final financeRepository = getIt<FinanceRepository>();
    final settingsRepository = getIt<SettingsRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(settingsRepository)),
        BlocProvider<FinanceBloc>(
          create: (_) => FinanceBloc(financeRepository, getIt()),
        ),
      ],
      child: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          final lightColorScheme =
              lightDynamic?.harmonized() ??
              ColorScheme.fromSeed(
                seedColor: AppColors.primaryNeon,
                brightness: Brightness.light,
              );

          final darkColorScheme =
              darkDynamic?.harmonized() ??
              ColorScheme.fromSeed(
                seedColor: AppColors.primaryNeon,
                brightness: Brightness.dark,
              );

          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return MaterialApp(
                title: 'Personal Expense App',
                debugShowCheckedModeBanner: false,

                // Localization setups
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: themeState.locale,

                // Theme configurations leveraging core AppTheme module
                themeMode: themeState.themeMode,
                theme: AppTheme.light(lightColorScheme),
                darkTheme: AppTheme.dark(darkColorScheme),

                // App Start Wrapper doing dynamic version checks
                home: const AppInitializationWrapper(),
              );
            },
          );
        },
      ),
    );
  }
}
