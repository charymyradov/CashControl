import '../repositories/finance_repository.dart';

/// Deletes every transaction of the owner from the local storage.
class ClearFinanceData {
  const ClearFinanceData(this._repository);

  final FinanceRepository _repository;

  Future<void> call() {
    return _repository.clearAllData();
  }
}
