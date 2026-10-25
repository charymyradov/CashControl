import '../../domain/entities/money_transaction.dart';
import '../../domain/entities/custom_transaction_category.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_local_data_source.dart';
import '../models/money_transaction_model.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  FinanceRepositoryImpl(this._localDataSource);

  final FinanceLocalDataSource _localDataSource;

  @override
  Future<List<MoneyTransaction>> getTransactions() async {
    final models = await _localDataSource.readTransactions();
    return models
        .map<MoneyTransaction>(MoneyTransactionModel.fromEntity)
        .toList();
  }

  @override
  Future<void> saveTransaction(MoneyTransaction transaction) {
    return _localDataSource.saveTransaction(
      MoneyTransactionModel.fromEntity(transaction),
    );
  }

  @override
  Future<void> deleteTransaction(String id) {
    return _localDataSource.deleteTransaction(id);
  }

  @override
  Future<bool> isBalanceHidden() async {
    return _localDataSource.readBalanceHidden();
  }

  @override
  Future<void> setBalanceHidden(bool hidden) {
    return _localDataSource.writeBalanceHidden(hidden);
  }

  @override
  Future<void> clearAllData() {
    return _localDataSource.clearAllTransactions();
  }

  @override
  Future<void> importTransactions(List<MoneyTransaction> transactions) {
    return _localDataSource.replaceAllTransactions(
      transactions.map(MoneyTransactionModel.fromEntity).toList(),
    );
  }

  @override
  Future<List<CustomTransactionCategory>> getCustomCategories() {
    return _localDataSource.readCustomCategories();
  }

  @override
  Future<void> saveCustomCategory(CustomTransactionCategory category) {
    return _localDataSource.saveCustomCategory(category);
  }

  @override
  Future<void> deleteCustomCategory(String id) {
    return _localDataSource.deleteCustomCategory(id);
  }
}
