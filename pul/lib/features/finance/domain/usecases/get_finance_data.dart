import '../entities/finance_snapshot.dart';
import '../repositories/finance_repository.dart';

class GetFinanceData {
  const GetFinanceData(this._repository);

  final FinanceRepository _repository;

  Future<FinanceSnapshot> call() async {
    final transactionsFuture = _repository.getTransactions();
    final hiddenFuture = _repository.isBalanceHidden();
    final categoriesFuture = _repository.getCustomCategories();

    final transactions = await transactionsFuture;
    final isBalanceHidden = await hiddenFuture;
    final customCategories = await categoriesFuture;

    return FinanceSnapshot(
      transactions: transactions,
      isBalanceHidden: isBalanceHidden,
      customCategories: customCategories,
    );
  }
}
