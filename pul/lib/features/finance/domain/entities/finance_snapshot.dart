import 'package:equatable/equatable.dart';

import 'money_transaction.dart';
import 'custom_transaction_category.dart';

class FinanceSnapshot extends Equatable {
  const FinanceSnapshot({
    required this.transactions,
    required this.isBalanceHidden,
    this.customCategories = const [],
  });

  final List<MoneyTransaction> transactions;
  final bool isBalanceHidden;
  final List<CustomTransactionCategory> customCategories;

  @override
  List<Object?> get props => [transactions, isBalanceHidden, customCategories];
}
