import '../../data/models/bank_account.dart';
import '../../data/models/transaction.dart';

class FinanceState {
  final List<BankAccount> accounts;
  final List<Transaction> transactions;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  FinanceState({
    this.accounts = const [],
    this.transactions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  FinanceState copyWith({
    List<BankAccount>? accounts,
    List<Transaction>? transactions,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return FinanceState(
      accounts: accounts ?? this.accounts,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
