import '../entities/money_transaction.dart';
import '../repositories/finance_repository.dart';

class SaveTransaction {
  const SaveTransaction(this._repository);

  final FinanceRepository _repository;

  Future<void> call(MoneyTransaction transaction) {
    return _repository.saveTransaction(transaction);
  }
}
