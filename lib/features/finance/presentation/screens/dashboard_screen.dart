import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../widgets/dashboard_home_view.dart';
import 'add_transaction_screen.dart';
import 'analytics_screen.dart';

// Import from settings feature across boundary (Presentation Layer boundary)
import '../../../settings/presentation/screens/settings_screen.dart';

/// **Presentation Layer - Dashboard Screen**
/// 
/// Serves as the primary viewport wrapper orchestrating bottom navigation between
/// Finance components (Dashboard home & Analytics) and Settings views.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load financial records during boots using BLoC boundary
    context.read<FinanceBloc>().add(LoadFinanceData());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final platform = Theme.of(context).platform;
    final isCupertino = platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    
    final List<Widget> screens = [
      const DashboardHomeView(),
      const AnalyticsScreen(),
      const SettingsScreen(),
    ];

    if (isCupertino) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          activeColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor ?? AppColors.secondaryNeon,
          inactiveColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? AppColors.getTextMuted(context),
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.square_grid_2x2_fill),
              label: l10n.dashboard,
            ),
            const BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_pie_fill),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.settings),
              label: l10n.settings,
            ),
          ],
        ),
        tabBuilder: (context, index) {
          return CupertinoPageScaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            child: SafeArea(
              bottom: false,
              child: screens[index],
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.getBorderColor(context),
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          currentIndex: _currentIndex,
          selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor ?? AppColors.secondaryNeon,
          unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? AppColors.getTextMuted(context),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              label: l10n.dashboard,
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.analytics_rounded),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_suggest_rounded),
              label: l10n.settings,
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              heroTag: 'add_transaction_fab',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddTransactionScreen(),
                  ),
                );
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.getPrimaryGradient(context),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            )
          : null,
    );
  }
}
