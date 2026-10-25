import '../entities/custom_transaction_category.dart';
import '../repositories/finance_repository.dart';

class SaveCustomCategory {
  const SaveCustomCategory(this._repository);

  final FinanceRepository _repository;

  Future<void> call(CustomTransactionCategory category) {
    return _repository.saveCustomCategory(category);
  }
}
