import '../../data/models/bank_account.dart';
import '../../data/models/transaction.dart';

/// **Domain Layer - Repository Interface**
/// 
/// Following Clean Architecture principles, the Domain layer contains abstract 
/// definitions (interfaces) of dependencies. It does NOT know about ObjectBox, 
/// SQLite, API calls, or any concrete database implementation.
/// 
/// By defining [FinanceRepository] here, we decouple our business logic 
/// (BLoCs and UseCases) from the database layer, allowing easy unit testing 
/// and enabling swapping the storage layer (e.g. to SQLite or Firebase) without 
/// changing business rules or UI screens.
abstract class FinanceRepository {
  
  // ==========================================
  // BANK ACCOUNTS
  // ==========================================
  
  /// Fetches all active [BankAccount] ledgers stored in the local database.
  List<BankAccount> getAllAccounts();

  /// Retrieves a specific [BankAccount] ledger by its auto-incremented database [id].
  BankAccount? getAccountById(int id);

  /// Retrieves a specific [BankAccount] ledger by its unique string identifier [accountId]
  /// (e.g. matching rule configurations like 'wallet', 'checking').
  BankAccount? getAccountByStringId(String accountId);

  /// Saves or updates a [BankAccount] ledger. 
  /// Returns the newly inserted or updated database record [id].
  int saveAccount(BankAccount account);

  /// Deletes a [BankAccount] ledger and all of its associated transactions to prevent orphaned data.
  void deleteAccount(int id);

  // ==========================================
  // TRANSACTIONS
  // ==========================================

  /// Fetches all transaction records across all accounts.
  List<Transaction> getAllTransactions();

  /// Fetches all transaction records specifically linked to a given [accountDbId].
  /// Results are sorted by transaction date in descending order.
  List<Transaction> getTransactionsForAccount(int accountDbId);

  /// Links and saves a new transaction ledger record under the specified [accountDbId].
  /// This will automatically trigger a recalculation of the bank account balance.
  int addTransaction(Transaction transaction, int accountDbId);

  /// Deletes a transaction ledger record by [txId] and updates the parent account balance.
  void deleteTransaction(int txId);

  // ==========================================
  // MATHEMATICAL RECALCULATIONS
  // ==========================================

  /// Recalculates and updates the persistent `currentBalance` of a single [BankAccount]
  /// using the registered calculation rules engine and active strategies (like Antigravity Mode).
  void recalculateAccountBalance(int accountDbId);

  /// Recalculates all balances for all accounts globally. Useful after importing new entries.
  void recalculateAllBalances();
}
