import '../repositories/finance_repository.dart';

class DeleteCustomCategory {
  const DeleteCustomCategory(this._repository);

  final FinanceRepository _repository;

  Future<void> call(String id) {
    return _repository.deleteCustomCategory(id);
  }
}
