import 'package:objectbox/objectbox.dart';
import 'bank_account.dart';

@Entity()
class Transaction {
  @Id()
  int id;

  double amount;

  @Property(type: PropertyType.date)
  DateTime date;

  String category;
  String transactionType; // e.g. expense, income
  String notes;

  // ObjectBox stores simple types. Comma-separated string resolves List<String> seamlessly
  String dbTags;

  // Relationship linking to the chosen BankAccount
  final accountRef = ToOne<BankAccount>();

  Transaction({
    this.id = 0,
    required this.amount,
    required this.date,
    required this.category,
    required this.transactionType,
    this.notes = '',
    List<String> tags = const [],
  }) : dbTags = tags.join(',');

  /// Get the list of tags decoded from ObjectBox database storage
  List<String> get tagsList => dbTags.isEmpty ? [] : dbTags.split(',');

  /// Set the tags lists encoding as comma-separated entries for ObjectBox
  set tagsList(List<String> tags) {
    dbTags = tags.join(',');
  }
}
