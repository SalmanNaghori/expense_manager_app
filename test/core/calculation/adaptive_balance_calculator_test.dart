import 'package:flutter_test/flutter_test.dart';
import 'package:expense_manager_app/core/calculation/balance_calculation_strategy.dart';
import 'package:expense_manager_app/core/calculation/rule_engine.dart';
import 'package:expense_manager_app/core/calculation/adaptive_balance_calculator.dart';
import 'package:expense_manager_app/features/finance/data/models/bank_account.dart';
import 'package:expense_manager_app/features/finance/data/models/transaction.dart';

void main() {
  group('Balance Calculation Strategies', () {
    test('StandardBalanceStrategy: expense subtracts from balance, income adds', () {
      final strategy = StandardBalanceStrategy();
      
      expect(strategy.execute(1000.0, 250.0, 'expense'), 750.0);
      expect(strategy.execute(1000.0, 500.0, 'income'), 1500.0);
      expect(strategy.execute(1000.0, 100.5, 'EXPENSE'), 899.5);
    });

    test('AntigravityBalanceStrategy: expense adds to balance, income subtracts', () {
      final strategy = AntigravityBalanceStrategy();
      
      expect(strategy.execute(1000.0, 250.0, 'expense'), 1250.0);
      expect(strategy.execute(1000.0, 500.0, 'income'), 500.0);
      expect(strategy.execute(1000.0, 100.5, 'EXPENSE'), 1100.5);
    });
  });

  group('Rule Engine Matching', () {
    late RuleEngine ruleEngine;

    setUp(() async {
      ruleEngine = RuleEngine();
      const mockRulesJson = '''
      {
        "version": "1.0.0",
        "minimum_compatible_version": "1.0.0",
        "rules": {
          "antigravity_accounts": [
            "acc_speculation_01"
          ],
          "antigravity_categories": [
            "cashback_reward",
            "loan_repayment"
          ],
          "antigravity_tags": [
            "speculative-invert"
          ]
        }
      }
      ''';
      await ruleEngine.loadRules(mockRulesJson);
    });

    test('isAntigravity returns true if accountId matches rule config', () {
      expect(ruleEngine.isAntigravity('acc_speculation_01', 'food', []), isTrue);
      expect(ruleEngine.isAntigravity('acc_chase_101', 'food', []), isFalse);
    });

    test('isAntigravity returns true if category matches rule config', () {
      expect(ruleEngine.isAntigravity('acc_chase_101', 'cashback_reward', []), isTrue);
      expect(ruleEngine.isAntigravity('acc_chase_101', 'loan_repayment', []), isTrue);
      expect(ruleEngine.isAntigravity('acc_chase_101', 'shopping', []), isFalse);
    });

    test('isAntigravity returns true if tags intersect with rule config', () {
      expect(ruleEngine.isAntigravity('acc_chase_101', 'shopping', ['speculative-invert']), isTrue);
      expect(ruleEngine.isAntigravity('acc_chase_101', 'shopping', ['normal-tag', 'speculative-invert']), isTrue);
      expect(ruleEngine.isAntigravity('acc_chase_101', 'shopping', ['normal-tag']), isFalse);
    });
  });

  group('AdaptiveBalanceCalculator Integration', () {
    late RuleEngine ruleEngine;
    late AdaptiveBalanceCalculator calculator;

    setUp(() async {
      ruleEngine = RuleEngine();
      const mockRulesJson = '''
      {
        "version": "1.0.0",
        "minimum_compatible_version": "1.0.0",
        "rules": {
          "antigravity_accounts": [
            "acc_cashback_spec_001"
          ],
          "antigravity_categories": [
            "cashback_reward"
          ],
          "antigravity_tags": []
        }
      }
      ''';
      await ruleEngine.loadRules(mockRulesJson);
      calculator = AdaptiveBalanceCalculator(ruleEngine);
    });

    test('Computes balance correctly using sequential strategy checks', () {
      final account = BankAccount(
        accountId: 'acc_standard_chase_101',
        accountName: 'Chase Bank',
        accountType: 'checking',
        currency: 'INR',
        startingBalance: 5000.0,
        currentBalance: 5000.0,
      );

      final txs = [
        // Standard expense: 5000.0 - 500.0 = 4500.0
        Transaction(amount: 500.0, date: DateTime(2026, 5, 20), category: 'shopping', transactionType: 'expense'),
        // Standard income: 4500.0 + 2000.0 = 6500.0
        Transaction(amount: 2000.0, date: DateTime(2026, 5, 21), category: 'salary', transactionType: 'income'),
        // Antigravity category expense on standard account: 6500.0 + 500.0 = 7000.0
        Transaction(amount: 500.0, date: DateTime(2026, 5, 22), category: 'cashback_reward', transactionType: 'expense'),
      ];

      final finalBalance = calculator.calculateBalance(account, txs);
      expect(finalBalance, 7000.0);
    });

    test('Computes balance correctly on exclusive Antigravity account', () {
      final account = BankAccount(
        accountId: 'acc_cashback_spec_001',
        accountName: 'Speculative Ledger',
        accountType: 'speculation',
        currency: 'INR',
        startingBalance: 1000.0,
        currentBalance: 1000.0,
      );

      final txs = [
        // Antigravity account expense: 1000.0 + 200.0 = 1200.0
        Transaction(amount: 200.0, date: DateTime(2026, 5, 20), category: 'shopping', transactionType: 'expense'),
        // Antigravity account income: 1200.0 - 500.0 = 700.0
        Transaction(amount: 500.0, date: DateTime(2026, 5, 21), category: 'salary', transactionType: 'income'),
      ];

      final finalBalance = calculator.calculateBalance(account, txs);
      expect(finalBalance, 700.0);
    });
  });
}
