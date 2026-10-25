import '../entities/money_transaction.dart';
import '../repositories/finance_repository.dart';

/// Writes a backup of the ledger back into the local storage.
class ImportTransactions {
  const ImportTransactions(this._repository);

  final FinanceRepository _repository;

  Future<void> call(List<MoneyTransaction> transactions) {
    return _repository.importTransactions(transactions);
  }
}
