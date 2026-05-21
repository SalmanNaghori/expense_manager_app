import 'dart:convert';
import '../objectbox/objectbox.dart';
import '../../features/finance/data/models/bank_account.dart';
import '../../features/finance/data/models/transaction.dart';
import '../../features/finance/domain/repositories/finance_repository.dart';

class ExportImportService {
  final ObjectBoxStore _dbStore;
  final FinanceRepository _financeRepository;

  ExportImportService(this._dbStore, this._financeRepository);

  /// Serialize all BankAccount and Transaction records into a structured JSON string
  String exportBackup() {
    final accounts = _dbStore.accountBox.getAll();
    final transactions = _dbStore.transactionBox.getAll();

    final List<Map<String, dynamic>> serializedAccounts = accounts.map((acc) {
      return {
        'accountId': acc.accountId,
        'accountName': acc.accountName,
        'accountType': acc.accountType,
        'currency': acc.currency,
        'startingBalance': acc.startingBalance,
        'currentBalance': acc.currentBalance,
      };
    }).toList();

    final List<Map<String, dynamic>> serializedTransactions = transactions.map((tx) {
      final account = tx.accountRef.target;
      return {
        'amount': tx.amount,
        'date': tx.date.toIso8601String(),
        'category': tx.category,
        'transactionType': tx.transactionType,
        'notes': tx.notes,
        'dbTags': tx.dbTags,
        'accountRefId': account?.accountId,
      };
    }).toList();

    final backup = {
      'export_version': '1.0.0',
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'accounts': serializedAccounts,
      'transactions': serializedTransactions,
    };

    return jsonEncode(backup);
  }

  /// Deserializes a JSON backup payload, performing safe validation, de-duplication,
  /// and automatically recalculating the running account balances on successful merge.
  bool importBackup(String jsonString) {
    try {
      final Map<String, dynamic> backup = jsonDecode(jsonString);

      // Validate schema
      if (!backup.containsKey('accounts') || !backup.containsKey('transactions')) {
        return false;
      }

      final List<dynamic> backupAccounts = backup['accounts'] ?? [];
      final List<dynamic> backupTransactions = backup['transactions'] ?? [];

      // 1. Process Accounts (de-duplicate on unique accountId)
      final existingAccounts = _dbStore.accountBox.getAll();
      final Map<String, BankAccount> accountMap = {
        for (var acc in existingAccounts) acc.accountId: acc
      };

      for (final rawAcc in backupAccounts) {
        final String accountId = rawAcc['accountId'];
        final String accountName = rawAcc['accountName'] ?? 'Unnamed Account';
        final String accountType = rawAcc['accountType'] ?? 'checking';
        final String currency = rawAcc['currency'] ?? 'INR';
        final double startingBalance = (rawAcc['startingBalance'] as num?)?.toDouble() ?? 0.0;
        final double currentBalance = (rawAcc['currentBalance'] as num?)?.toDouble() ?? startingBalance;

        if (!accountMap.containsKey(accountId)) {
          final newAcc = BankAccount(
            accountId: accountId,
            accountName: accountName,
            accountType: accountType,
            currency: currency,
            startingBalance: startingBalance,
            currentBalance: currentBalance,
          );
          _dbStore.accountBox.put(newAcc);
          accountMap[accountId] = newAcc;
        }
      }

      // 2. Process Transactions (de-duplicate on date, amount, type, category, accountId)
      final existingTransactions = _dbStore.transactionBox.getAll();

      // Check key function for transaction comparison
      String getTxKey(double amount, DateTime date, String type, String category, String? accountId) {
        return '${amount}_${date.toIso8601String()}_${type.toLowerCase()}_${category.toLowerCase()}_$accountId';
      }

      final Set<String> txKeys = existingTransactions.map((tx) {
        final accountId = tx.accountRef.target?.accountId;
        return getTxKey(tx.amount, tx.date, tx.transactionType, tx.category, accountId);
      }).toSet();

      for (final rawTx in backupTransactions) {
        final double amount = (rawTx['amount'] as num?)?.toDouble() ?? 0.0;
        final DateTime date = DateTime.parse(rawTx['date'] ?? DateTime.now().toIso8601String());
        final String category = rawTx['category'] ?? 'General';
        final String transactionType = rawTx['transactionType'] ?? 'expense';
        final String notes = rawTx['notes'] ?? '';
        final String dbTags = rawTx['dbTags'] ?? '';
        final String? accountRefId = rawTx['accountRefId'];

        final String key = getTxKey(amount, date, transactionType, category, accountRefId);

        if (!txKeys.contains(key) && accountRefId != null && accountMap.containsKey(accountRefId)) {
          final targetAccount = accountMap[accountRefId]!;
          final newTx = Transaction(
            amount: amount,
            date: date,
            category: category,
            transactionType: transactionType,
            notes: notes,
            tags: dbTags.isEmpty ? [] : dbTags.split(','),
          );
          newTx.accountRef.target = targetAccount;
          _dbStore.transactionBox.put(newTx);
          txKeys.add(key);
        }
      }

      // 3. Recalculate balances dynamically for all merged accounts
      _financeRepository.recalculateAllBalances();
      return true;
    } catch (e) {
      return false;
    }
  }
}
