/// **Core Layer - Export/Import Service Interface**
///
/// Abstract domain boundary for backup export and import operations.
/// Concrete implementations depend on ObjectBox; this interface allows 
/// FinanceBloc and other consumers to remain database-agnostic and testable.
abstract class ExportImportServiceInterface {
  /// Serialize all BankAccount and Transaction records into a JSON string.
  String exportBackup();

  /// Deserialize and restore a JSON backup. Returns true on success.
  bool importBackup(String jsonString);
}
