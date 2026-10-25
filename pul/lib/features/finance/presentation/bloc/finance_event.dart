import 'package:equatable/equatable.dart';

import '../../domain/entities/money_transaction.dart';
import '../../domain/entities/custom_transaction_category.dart';

sealed class FinanceEvent extends Equatable {
  const FinanceEvent();

  @override
  List<Object?> get props => const [];
}

class FinanceStarted extends FinanceEvent {
  const FinanceStarted();
}

class TransactionSaved extends FinanceEvent {
  const TransactionSaved(this.transaction);

  final MoneyTransaction transaction;

  @override
  List<Object?> get props => [transaction];
}

class TransactionDeleted extends FinanceEvent {
  const TransactionDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class BalanceVisibilityToggled extends FinanceEvent {
  const BalanceVisibilityToggled();
}

class FinanceDataCleared extends FinanceEvent {
  const FinanceDataCleared();
}

class LedgerImported extends FinanceEvent {
  const LedgerImported(this.transactions, {this.customCategories});

  final List<MoneyTransaction> transactions;
  final List<CustomTransactionCategory>? customCategories;

  @override
  List<Object?> get props => [transactions, customCategories];
}

class CustomCategorySaved extends FinanceEvent {
  const CustomCategorySaved(this.category);

  final CustomTransactionCategory category;

  @override
  List<Object?> get props => [category];
}

class CustomCategoryDeleted extends FinanceEvent {
  const CustomCategoryDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
