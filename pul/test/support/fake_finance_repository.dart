import 'package:pul/features/finance/domain/entities/custom_transaction_category.dart';
import 'package:pul/features/finance/domain/entities/money_transaction.dart';
import 'package:pul/features/finance/domain/entities/transaction_category.dart';
import 'package:pul/features/finance/domain/entities/transaction_type.dart';
import 'package:pul/features/finance/domain/repositories/finance_repository.dart';

/// In-memory [FinanceRepository] used by the widget tests.
class FakeFinanceRepository implements FinanceRepository {
  FakeFinanceRepository({List<MoneyTransaction>? transactions})
    : _transactions = transactions ?? sampleTransactions;

  List<MoneyTransaction> _transactions;
  bool _hidden = false;
  final List<CustomTransactionCategory> _customCategories = [];
  List<CustomTransactionCategory> get customCategories => _customCategories;

  @override
  Future<void> deleteTransaction(String id) async {
    _transactions = _transactions.where((item) => item.id != id).toList();
  }

  @override
  Future<List<MoneyTransaction>> getTransactions() async {
    return [..._transactions]..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<bool> isBalanceHidden() async => _hidden;

  @override
  Future<void> clearAllData() async {
    _transactions = [];
  }

  @override
  Future<void> importTransactions(List<MoneyTransaction> transactions) async {
    _transactions = [...transactions];
  }

  @override
  Future<void> saveTransaction(MoneyTransaction transaction) async {
    _transactions = [
      ..._transactions.where((item) => item.id != transaction.id),
      transaction,
    ];
  }

  @override
  Future<void> setBalanceHidden(bool hidden) async {
    _hidden = hidden;
  }

  @override
  Future<void> deleteCustomCategory(String id) async {
    _customCategories.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<CustomTransactionCategory>> getCustomCategories() async => [
    ..._customCategories,
  ];

  @override
  Future<void> saveCustomCategory(CustomTransactionCategory category) async {
    final index = _customCategories.indexWhere(
      (item) => item.id == category.id,
    );
    if (index == -1) {
      _customCategories.add(category);
    } else {
      _customCategories[index] = category;
    }
  }
}

/// A small ledger used by the widget tests.
List<MoneyTransaction> get sampleTransactions => [
  MoneyTransaction(
    id: 'income',
    type: TransactionType.income,
    amount: 32000,
    category: TransactionCategory.salary,
    date: DateTime.now().subtract(const Duration(days: 1)),
    note: 'Aýlyk',
  ),
  MoneyTransaction(
    id: 'market',
    type: TransactionType.expense,
    amount: 640,
    category: TransactionCategory.food,
    date: DateTime.now(),
    note: 'Market',
  ),
  MoneyTransaction(
    id: 'transport',
    type: TransactionType.expense,
    amount: 180.50,
    category: TransactionCategory.transport,
    date: DateTime.now().subtract(const Duration(days: 2)),
    note: 'Ulag',
  ),
  MoneyTransaction(
    id: 'rent',
    type: TransactionType.expense,
    amount: 5000,
    category: TransactionCategory.housing,
    date: DateTime.now().subtract(const Duration(days: 4)),
    note: 'Jaý kireýi',
  ),
  MoneyTransaction(
    id: 'health',
    type: TransactionType.expense,
    amount: 1599,
    category: TransactionCategory.health,
    date: DateTime.now().subtract(const Duration(days: 5)),
    note: 'Dermanhana',
  ),
];
