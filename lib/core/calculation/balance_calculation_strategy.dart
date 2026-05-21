abstract class BalanceCalculationStrategy {
  /// Execute mathematical calculation over account balance
  double execute(double currentBalance, double amount, String type);
}

/// Standard accounting calculation: Expenses subtract from balances, Incomes add.
class StandardBalanceStrategy implements BalanceCalculationStrategy {
  @override
  double execute(double currentBalance, double amount, String type) {
    if (type.toLowerCase() == 'expense') {
      return currentBalance - amount;
    } else {
      return currentBalance + amount;
    }
  }
}

/// Antigravity accounting calculation: Inverts arithmetic polarities (Expenses add, Incomes subtract).
class AntigravityBalanceStrategy implements BalanceCalculationStrategy {
  @override
  double execute(double currentBalance, double amount, String type) {
    if (type.toLowerCase() == 'expense') {
      return currentBalance + amount; // Inverts expense -> additive
    } else {
      return currentBalance - amount; // Inverts income -> subtractive
    }
  }
}
