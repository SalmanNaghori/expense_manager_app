import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_manager_app/core/calculation/rule_engine.dart';
import 'package:expense_manager_app/core/di/service_locator.dart';
import 'package:expense_manager_app/core/services/export_import_service_interface.dart';
import 'package:expense_manager_app/core/services/version_check_service_interface.dart';
import 'package:expense_manager_app/features/finance/domain/repositories/finance_repository.dart';
import 'package:expense_manager_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:expense_manager_app/features/settings/data/models/app_settings.dart';
import 'package:expense_manager_app/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:expense_manager_app/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:expense_manager_app/features/finance/presentation/screens/dashboard_screen.dart';
import 'package:expense_manager_app/core/l10n/app_localizations.dart';
import 'package:expense_manager_app/features/finance/data/models/bank_account.dart';
import 'package:expense_manager_app/features/finance/data/models/transaction.dart';

// ---------------------------------------------------------------------------
// Fake FinanceRepository — pure in-memory stub for the domain interface
// ---------------------------------------------------------------------------
class FakeFinanceRepository implements FinanceRepository {
  final List<BankAccount> accounts = [];
  final List<Transaction> transactions = [];

  @override
  List<BankAccount> getAllAccounts() => accounts;

  @override
  BankAccount? getAccountById(int id) {
    // Use where() + first pattern to return null safely without orElse type issues
    final matches = accounts.where((a) => a.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  BankAccount? getAccountByStringId(String accountId) {
    final matches = accounts.where((a) => a.accountId == accountId);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  int saveAccount(BankAccount account) {
    accounts.add(account);
    return 1;
  }

  @override
  void deleteAccount(int id) {
    accounts.removeWhere((a) => a.id == id);
  }

  @override
  List<Transaction> getAllTransactions() => transactions;

  @override
  List<Transaction> getTransactionsForAccount(int accountDbId) => transactions;

  @override
  int addTransaction(Transaction transaction, int accountDbId) {
    transactions.add(transaction);
    return 1;
  }

  @override
  void deleteTransaction(int txId) {
    transactions.removeWhere((tx) => tx.id == txId);
  }

  @override
  void recalculateAccountBalance(int accountDbId) {}

  @override
  void recalculateAllBalances() {}
}

// ---------------------------------------------------------------------------
// Fake ExportImportService — implements the interface (no ObjectBox needed)
// ---------------------------------------------------------------------------
class FakeExportImportService implements ExportImportServiceInterface {
  @override
  String exportBackup() => '{}';

  @override
  bool importBackup(String jsonString) => true;
}

// ---------------------------------------------------------------------------
// Fake VersionCheckService — implements the interface (no package_info_plus)
// ---------------------------------------------------------------------------
class FakeVersionCheckService implements VersionCheckServiceInterface {
  @override
  Future<bool> checkCompatibility() async => true;

  @override
  String? getUpdateUrl(bool isAndroid) => null;

  @override
  int compareVersions(String v1, String v2) => 0;
}

// ---------------------------------------------------------------------------
// Fake SettingsRepository — implements the abstract domain interface
// ---------------------------------------------------------------------------
class FakeSettingsRepository implements SettingsRepository {
  AppSettings _settings = AppSettings(
    id: 1,
    isSystemTheme: true,
    isDarkMode: false,
    isTimeBasedTheme: false,
  );

  @override
  AppSettings getSettings() => _settings;

  @override
  void saveSettings(AppSettings settings) {
    _settings = settings;
  }
}

// ---------------------------------------------------------------------------
// Test suite
// ---------------------------------------------------------------------------
void main() {
  late ThemeCubit themeCubit;
  late FinanceBloc financeBloc;
  late FakeFinanceRepository fakeFinanceRepo;
  late FakeExportImportService fakeExportImport;

  setUp(() {
    // Reset getIt for a clean slate between tests
    getIt.reset();

    // Register only what DashboardScreen and its children actually pull from getIt
    getIt.registerSingleton<RuleEngine>(RuleEngine());
    fakeFinanceRepo = FakeFinanceRepository();
    getIt.registerSingleton<FinanceRepository>(fakeFinanceRepo);

    fakeExportImport = FakeExportImportService();
    getIt.registerSingleton<ExportImportServiceInterface>(fakeExportImport);
    getIt.registerSingleton<VersionCheckServiceInterface>(FakeVersionCheckService());

    // Build BLoCs using the fakes — no ObjectBox or async setup required
    themeCubit = ThemeCubit(FakeSettingsRepository());
    financeBloc = FinanceBloc(fakeFinanceRepo, fakeExportImport);
  });

  tearDown(() {
    themeCubit.close();
    financeBloc.close();
    getIt.reset();
  });

  // Helper: wraps [DashboardScreen] with all required BLoC providers and a
  // MaterialApp configured for the given target [platform].
  Widget buildTestableWidget({required TargetPlatform platform}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: themeCubit),
        BlocProvider<FinanceBloc>.value(value: financeBloc),
      ],
      child: MaterialApp(
        theme: ThemeData(platform: platform),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const DashboardScreen(),
      ),
    );
  }

  // Pre-seed one account so DashboardHomeView exits the loading state.
  BankAccount _stubAccount() => BankAccount(
        accountId: 'acc_checking',
        accountName: 'Checking Ledger',
        accountType: 'checking',
        currency: 'USD',
        startingBalance: 100.0,
        currentBalance: 100.0,
      );

  testWidgets(
    'DashboardScreen renders Material 3 BottomNavigationBar + FloatingActionButton on Android',
    (WidgetTester tester) async {
      fakeFinanceRepo.accounts.add(_stubAccount());

      await tester.pumpWidget(buildTestableWidget(platform: TargetPlatform.android));
      await tester.pump(); // settle one frame

      // Material Scaffold must be present on Android
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(CupertinoTabScaffold), findsNothing);

      // Bottom navigation bar and FAB are Material-only constructs
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Verify the Material dashboard icon is visible in the tab bar
      expect(find.byIcon(Icons.dashboard_rounded), findsOneWidget);
    },
  );

  testWidgets(
    'DashboardScreen renders CupertinoTabScaffold + CupertinoTabBar on iOS',
    (WidgetTester tester) async {
      fakeFinanceRepo.accounts.add(_stubAccount());

      await tester.pumpWidget(buildTestableWidget(platform: TargetPlatform.iOS));
      await tester.pump(); // one frame — avoids infinite animation lock in AntigravityBadge

      // Cupertino tab scaffold must be present on iOS
      expect(find.byType(CupertinoTabScaffold), findsOneWidget);
      expect(find.byType(CupertinoTabBar), findsOneWidget);

      // Material Scaffold and FAB must NOT appear on iOS
      expect(find.byType(Scaffold), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);

      // Verify the Cupertino dashboard icon is visible in the tab bar
      expect(find.byIcon(CupertinoIcons.square_grid_2x2_fill), findsOneWidget);
    },
  );
}
