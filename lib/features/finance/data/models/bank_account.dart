import 'package:objectbox/objectbox.dart';

@Entity()
class BankAccount {
  @Id()
  int id;

  @Unique()
  String accountId; // Unique string identifier matching dynamic antigravity JSON configurations

  String accountName;
  String accountType; // e.g. checking, savings, speculation, wallet
  String currency;    // e.g. USD, INR, EUR
  double startingBalance;
  double currentBalance;

  BankAccount({
    this.id = 0,
    required this.accountId,
    required this.accountName,
    required this.accountType,
    required this.currency,
    required this.startingBalance,
    required this.currentBalance,
  });
}
