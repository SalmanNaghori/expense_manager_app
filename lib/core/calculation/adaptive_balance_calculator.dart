import '../../features/finance/data/models/bank_account.dart';
import '../../features/finance/data/models/transaction.dart';
import 'balance_calculation_strategy.dart';
import 'rule_engine.dart';

class AdaptiveBalanceCalculator {
  final RuleEngine _ruleEngine;

  AdaptiveBalanceCalculator(this._ruleEngine);

  /// Computes the aggregate balance of an account by iterating and applying appropriate calculation strategies
  double calculateBalance(BankAccount account, List<Transaction> transactions) {
    double runningBalance = account.startingBalance;

    for (final tx in transactions) {
      // Query rule matches dynamically
      final isAntigravityMode = _ruleEngine.isAntigravity(
        account.accountId,
        tx.category,
        tx.tagsList,
      );

      // Instantiates appropriate strategy depending on the rule match
      final strategy = isAntigravityMode
          ? AntigravityBalanceStrategy()
          : StandardBalanceStrategy();

      runningBalance = strategy.execute(
        runningBalance,
        tx.amount,
        tx.transactionType,
      );
    }

    return runningBalance;
  }
}
