import '../entities/money_transaction.dart';
import '../entities/custom_transaction_category.dart';

abstract interface class FinanceRepository {
  Future<List<MoneyTransaction>> getTransactions();

  Future<void> saveTransaction(MoneyTransaction transaction);

  Future<void> deleteTransaction(String id);

  Future<bool> isBalanceHidden();

  Future<void> setBalanceHidden(bool hidden);

  /// Removes every transaction from the local storage.
  Future<void> clearAllData();

  /// Replaces every transaction of the local storage.
  Future<void> importTransactions(List<MoneyTransaction> transactions);

  Future<List<CustomTransactionCategory>> getCustomCategories();

  Future<void> saveCustomCategory(CustomTransactionCategory category);

  Future<void> deleteCustomCategory(String id);
}
