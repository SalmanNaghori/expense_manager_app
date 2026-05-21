abstract class FinanceEvent {}

class LoadFinanceData extends FinanceEvent {}

class AddAccountEvent extends FinanceEvent {
  final String accountId;
  final String accountName;
  final String accountType;
  final String currency;
  final double startingBalance;

  AddAccountEvent({
    required this.accountId,
    required this.accountName,
    required this.accountType,
    required this.currency,
    required this.startingBalance,
  });
}

class AddTransactionEvent extends FinanceEvent {
  final double amount;
  final DateTime date;
  final String category;
  final String transactionType;
  final String notes;
  final List<String> tags;
  final int accountDbId;

  AddTransactionEvent({
    required this.amount,
    required this.date,
    required this.category,
    required this.transactionType,
    required this.notes,
    required this.tags,
    required this.accountDbId,
  });
}

class DeleteTransactionEvent extends FinanceEvent {
  final int transactionId;

  DeleteTransactionEvent(this.transactionId);
}

class DeleteAccountEvent extends FinanceEvent {
  final int accountId;

  DeleteAccountEvent(this.accountId);
}

class ImportBackupEvent extends FinanceEvent {
  final String jsonString;

  ImportBackupEvent(this.jsonString);
}

class RecalculateAllBalancesEvent extends FinanceEvent {}
