import '../../../../core/objectbox/objectbox.dart';
import '../../../../core/calculation/adaptive_balance_calculator.dart';
import '../../domain/repositories/finance_repository.dart';
import '../models/bank_account.dart';
import '../models/transaction.dart';
import '../../../../objectbox.g.dart';

/// **Data Layer - Repository Implementation**
/// 
/// Implementing the [FinanceRepository] interface from the Domain layer.
/// 
/// This class handles saving, updating, loading, and deleting of banking accounts
/// and transactions using the [ObjectBoxStore] database. It also orchestrates
/// calling mathematical recalculations via the core calculations module whenever
/// a ledger record changes.
class FinanceRepositoryImpl implements FinanceRepository {
  final ObjectBoxStore _dbStore;
  final AdaptiveBalanceCalculator _balanceCalculator;

  FinanceRepositoryImpl(this._dbStore, this._balanceCalculator);

  // ==========================================
  // BANK ACCOUNTS
  // ==========================================

  @override
  List<BankAccount> getAllAccounts() {
    return _dbStore.accountBox.getAll();
  }

  @override
  BankAccount? getAccountById(int id) {
    return _dbStore.accountBox.get(id);
  }

  @override
  BankAccount? getAccountByStringId(String accountId) {
    final query = _dbStore.accountBox.query(BankAccount_.accountId.equals(accountId)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  @override
  int saveAccount(BankAccount account) {
    final id = _dbStore.accountBox.put(account);
    recalculateAccountBalance(account.id);
    return id;
  }

  @override
  void deleteAccount(int id) {
    // Delete all linked transactions first to maintain DB integrity
    final txQuery = _dbStore.transactionBox.query(Transaction_.accountRef.equals(id)).build();
    final txs = txQuery.find();
    txQuery.close();
    
    final txIds = txs.map((e) => e.id).toList();
    if (txIds.isNotEmpty) {
      _dbStore.transactionBox.removeMany(txIds);
    }
    
    _dbStore.accountBox.remove(id);
  }

  // ==========================================
  // TRANSACTIONS
  // ==========================================

  @override
  List<Transaction> getAllTransactions() {
    return _dbStore.transactionBox.getAll();
  }

  @override
  List<Transaction> getTransactionsForAccount(int accountDbId) {
    final query = _dbStore.transactionBox
        .query(Transaction_.accountRef.equals(accountDbId))
        .order(Transaction_.date, flags: Order.descending)
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  @override
  int addTransaction(Transaction transaction, int accountDbId) {
    final account = getAccountById(accountDbId);
    if (account == null) {
      throw Exception('Target BankAccount not found');
    }

    transaction.accountRef.target = account;
    final txId = _dbStore.transactionBox.put(transaction);

    // Recalculate account balance dynamically
    recalculateAccountBalance(accountDbId);
    return txId;
  }

  @override
  void deleteTransaction(int txId) {
    final tx = _dbStore.transactionBox.get(txId);
    if (tx != null) {
      final accountId = tx.accountRef.targetId;
      _dbStore.transactionBox.remove(txId);

      if (accountId != 0) {
        recalculateAccountBalance(accountId);
      }
    }
  }

  // ==========================================
  // MATHEMATICAL RECALCULATIONS
  // ==========================================

  @override
  void recalculateAccountBalance(int accountDbId) {
    final account = getAccountById(accountDbId);
    if (account == null) return;

    // Fetch all transactions associated with this account ordered by date ascending for sequential strategy application
    final query = _dbStore.transactionBox
        .query(Transaction_.accountRef.equals(accountDbId))
        .order(Transaction_.date)
        .build();
    final txs = query.find();
    query.close();

    final double computedBalance = _balanceCalculator.calculateBalance(account, txs);
    account.currentBalance = computedBalance;
    _dbStore.accountBox.put(account);
  }

  @override
  /// Recalculates all balances for all accounts globally. Useful after importing new entries.
  void recalculateAllBalances() {
    final accounts = getAllAccounts();
    for (final acc in accounts) {
      recalculateAccountBalance(acc.id);
    }
  }
}
