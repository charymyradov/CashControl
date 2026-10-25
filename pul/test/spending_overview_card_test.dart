import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pul/features/finance/domain/entities/custom_transaction_category.dart';
import 'package:pul/features/finance/domain/entities/money_transaction.dart';
import 'package:pul/features/finance/domain/entities/transaction_category.dart';
import 'package:pul/features/finance/domain/entities/transaction_type.dart';
import 'package:pul/features/finance/presentation/bloc/finance_state.dart';
import 'package:pul/features/finance/presentation/widgets/spending_overview_card.dart';

void main() {
  testWidgets('shows top categories, six-month chart, and period comparison', (
    tester,
  ) async {
    final now = DateTime.now();
    const customCategory = CustomTransactionCategory(
      id: 'pets',
      label: 'Haýwanlar',
      type: TransactionType.expense,
      colorValue: 0xFF20A88A,
      iconCodePoint: 0xE91D,
    );
    final state = FinanceState(
      status: FinanceStatus.ready,
      customCategories: const [customCategory],
      transactions: [
        MoneyTransaction(
          id: 'custom',
          type: TransactionType.expense,
          amount: 120,
          category: TransactionCategory.other,
          date: now,
          customCategoryId: customCategory.id,
          customCategoryLabel: customCategory.label,
          customCategoryColor: customCategory.colorValue,
          customCategoryIcon: customCategory.iconCodePoint,
        ),
        MoneyTransaction(
          id: 'food',
          type: TransactionType.expense,
          amount: 80,
          category: TransactionCategory.food,
          date: now,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SpendingOverviewCard(state: state)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Haýwanlar'), findsOneWidget);
    expect(find.text('120,00 TMT'), findsOneWidget);
    expect(find.text('Soňky 6 aýyň çykdajysy'), findsOneWidget);
    expect(find.text('Öňki döwür bilen deňeşdirme'), findsOneWidget);
  });
}
