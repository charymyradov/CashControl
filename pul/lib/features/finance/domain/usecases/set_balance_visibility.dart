import '../repositories/finance_repository.dart';

class SetBalanceVisibility {
  const SetBalanceVisibility(this._repository);

  final FinanceRepository _repository;

  Future<void> call(bool hidden) {
    return _repository.setBalanceHidden(hidden);
  }
}
