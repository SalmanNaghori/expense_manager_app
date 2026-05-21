import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../data/models/bank_account.dart';
import '../../data/models/transaction.dart';
import '../../../../core/services/export_import_service_interface.dart';
import 'finance_event.dart';
import 'finance_state.dart';

/// **Presentation Layer - Finance Bloc**
/// 
/// Responsible for orchestrating financial user gestures (adding/deleting accounts 
/// and transaction ledgers) and loading data into state fields.
/// 
/// Following Clean Architecture, it references only the [FinanceRepository]
/// abstract domain interface instead of its low-level database implementation, 
/// enforcing clear separations.
class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final FinanceRepository _financeRepository;
  final ExportImportServiceInterface _exportImportService;

  FinanceBloc(this._financeRepository, this._exportImportService) : super(FinanceState()) {
    on<LoadFinanceData>(_onLoadFinanceData);
    on<AddAccountEvent>(_onAddAccount);
    on<AddTransactionEvent>(_onAddTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<ImportBackupEvent>(_onImportBackup);
    on<RecalculateAllBalancesEvent>(_onRecalculateAllBalances);
  }

  Future<void> _onLoadFinanceData(LoadFinanceData event, Emitter<FinanceState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final accounts = _financeRepository.getAllAccounts();
      final transactions = _financeRepository.getAllTransactions();
      
      // Sort transactions descending by date for UI presentation
      transactions.sort((a, b) => b.date.compareTo(a.date));

      emit(state.copyWith(
        accounts: accounts,
        transactions: transactions,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load data: $e',
      ));
    }
  }

  Future<void> _onAddAccount(AddAccountEvent event, Emitter<FinanceState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final newAcc = BankAccount(
        accountId: event.accountId,
        accountName: event.accountName,
        accountType: event.accountType,
        currency: event.currency,
        startingBalance: event.startingBalance,
        currentBalance: event.startingBalance,
      );
      _financeRepository.saveAccount(newAcc);
      add(LoadFinanceData());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save account: $e',
      ));
    }
  }

  Future<void> _onAddTransaction(AddTransactionEvent event, Emitter<FinanceState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final newTx = Transaction(
        amount: event.amount,
        date: event.date,
        category: event.category,
        transactionType: event.transactionType,
        notes: event.notes,
        tags: event.tags,
      );
      _financeRepository.addTransaction(newTx, event.accountDbId);
      add(LoadFinanceData());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to record transaction: $e',
      ));
    }
  }

  Future<void> _onDeleteTransaction(DeleteTransactionEvent event, Emitter<FinanceState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      _financeRepository.deleteTransaction(event.transactionId);
      add(LoadFinanceData());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete transaction: $e',
      ));
    }
  }

  Future<void> _onDeleteAccount(DeleteAccountEvent event, Emitter<FinanceState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      _financeRepository.deleteAccount(event.accountId);
      add(LoadFinanceData());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete account: $e',
      ));
    }
  }

  Future<void> _onImportBackup(ImportBackupEvent event, Emitter<FinanceState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final success = _exportImportService.importBackup(event.jsonString);
      if (success) {
        emit(state.copyWith(successMessage: 'Backup imported successfully!'));
        add(LoadFinanceData());
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to parse or restore backup. Please verify structure.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Import execution error: $e',
      ));
    }
  }

  Future<void> _onRecalculateAllBalances(RecalculateAllBalancesEvent event, Emitter<FinanceState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      _financeRepository.recalculateAccountBalance(0); // This will handle general triggers if custom implementation changes
      add(LoadFinanceData());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Recalculation error: $e',
      ));
    }
  }
}
