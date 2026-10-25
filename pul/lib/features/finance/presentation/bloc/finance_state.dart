import 'package:equatable/equatable.dart';

import '../../domain/entities/money_transaction.dart';
import '../../domain/entities/custom_transaction_category.dart';
import '../../domain/entities/transaction_category.dart';
import '../../domain/entities/transaction_type.dart';

enum FinanceStatus { initial, loading, ready, failure }

class FinanceState extends Equatable {
  const FinanceState({
    this.status = FinanceStatus.initial,
    this.transactions = const [],
    this.customCategories = const [],
    this.isBalanceHidden = false,
    this.isSaving = false,
    this.lastSavedId,
    this.lastDeletedId,
    this.errorMessage,
  });

  final FinanceStatus status;
  final List<MoneyTransaction> transactions;
  final List<CustomTransactionCategory> customCategories;
  final bool isBalanceHidden;
  final bool isSaving;
  final String? lastSavedId;
  final String? lastDeletedId;
  final String? errorMessage;

  bool get isLoading => status == FinanceStatus.loading;
  bool get hasError => status == FinanceStatus.failure;
  bool get isReady => status == FinanceStatus.ready;

  double get totalBalance {
    return transactions.fold(0, (total, item) => total + item.signedAmount);
  }

  double get monthlyIncome {
    final now = DateTime.now();
    return _income(transactionsInMonth(now));
  }

  double get monthlyExpense {
    final now = DateTime.now();
    return _expense(transactionsInMonth(now));
  }

  double get monthlyNet => monthlyIncome - monthlyExpense;

  List<MoneyTransaction> get recentTransactions {
    return transactions.take(3).toList(growable: false);
  }

  List<MoneyTransaction> transactionsInMonth(DateTime date) {
    final start = DateTime(date.year, date.month);
    final end = DateTime(date.year, date.month + 1);
    return transactionsBetween(start, end);
  }

  List<MoneyTransaction> transactionsBetween(DateTime start, DateTime end) {
    return transactions
        .where((item) => !item.date.isBefore(start) && item.date.isBefore(end))
        .toList(growable: false);
  }

  double expenseBetween(DateTime start, DateTime end) {
    return _expense(transactionsBetween(start, end));
  }

  Map<TransactionCategory, double> expensesByCategory(
    DateTime start,
    DateTime end,
  ) {
    final totals = <TransactionCategory, double>{};
    for (final transaction in transactionsBetween(start, end)) {
      if (transaction.type != TransactionType.expense) continue;
      totals.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    return totals;
  }

  double _income(List<MoneyTransaction> items) {
    return items
        .where((item) => item.type == TransactionType.income)
        .fold(0, (total, item) => total + item.amount);
  }

  double _expense(List<MoneyTransaction> items) {
    return items
        .where((item) => item.type == TransactionType.expense)
        .fold(0, (total, item) => total + item.amount);
  }

  FinanceState copyWith({
    FinanceStatus? status,
    List<MoneyTransaction>? transactions,
    List<CustomTransactionCategory>? customCategories,
    bool? isBalanceHidden,
    bool? isSaving,
    String? lastSavedId,
    bool clearLastSavedId = false,
    String? lastDeletedId,
    bool clearLastDeletedId = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FinanceState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      customCategories: customCategories ?? this.customCategories,
      isBalanceHidden: isBalanceHidden ?? this.isBalanceHidden,
      isSaving: isSaving ?? this.isSaving,
      lastSavedId: clearLastSavedId ? null : (lastSavedId ?? this.lastSavedId),
      lastDeletedId: clearLastDeletedId
          ? null
          : (lastDeletedId ?? this.lastDeletedId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    transactions,
    customCategories,
    isBalanceHidden,
    isSaving,
    lastSavedId,
    lastDeletedId,
    errorMessage,
  ];
}
