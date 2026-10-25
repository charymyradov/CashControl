import 'package:flutter_test/flutter_test.dart';
import 'package:pul/features/finance/data/datasources/finance_local_data_source.dart';
import 'package:pul/features/finance/data/models/money_transaction_model.dart';
import 'package:pul/features/finance/domain/entities/custom_transaction_category.dart';
import 'package:pul/features/finance/domain/entities/transaction_category.dart';
import 'package:pul/features/finance/domain/entities/transaction_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MoneyTransactionModel transaction({
    String id = 'one',
    double amount = 125,
    TransactionType type = TransactionType.expense,
    TransactionCategory category = TransactionCategory.food,
  }) {
    return MoneyTransactionModel(
      id: id,
      type: type,
      amount: amount,
      category: category,
      date: DateTime(2026, 10, 21, 12),
      note: 'Bellik',
    );
  }

  Future<FinanceLocalDataSource> createSource([
    Map<String, Object> initialValues = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(initialValues);
    final preferences = await SharedPreferences.getInstance();
    return FinanceLocalDataSource(preferences);
  }

  test('local data source starts with an empty ledger', () async {
    final source = await createSource();

    final transactions = await source.readTransactions();

    expect(transactions, isEmpty);
  });

  test('local data source persists custom categories', () async {
    final source = await createSource();
    const category = CustomTransactionCategory(
      id: 'pets',
      label: 'Haýwanlar',
      type: TransactionType.expense,
      colorValue: 0xFF20A88A,
      iconCodePoint: 0xE91D,
    );

    await source.saveCustomCategory(category);
    final loaded = await source.readCustomCategories();
    expect(loaded, [category]);

    await source.deleteCustomCategory(category.id);
    expect(await source.readCustomCategories(), isEmpty);
  });

  test(
    'local data source keeps the transactions in the local storage',
    () async {
      final source = await createSource();

      await source.saveTransaction(transaction());
      final transactions = await source.readTransactions();

      expect(transactions, hasLength(1));
      expect(transactions.first.id, 'one');
      expect(
        transactions.fold<double>(
          0,
          (sum, item) =>
              sum +
              (item.type == TransactionType.income
                  ? item.amount
                  : -item.amount),
        ),
        -125,
      );
    },
  );

  test('local data source clears the ledger without demo data', () async {
    final source = await createSource();
    await source.saveTransaction(transaction());

    await source.clearAllTransactions();

    expect(await source.readTransactions(), isEmpty);
  });

  test(
    'local data source removes the demo data of the older versions',
    () async {
      final source = await createSource({
        'pul.seeded.v1': true,
        'pul.transactions.v1': <String>[
          '{"id":"seed-salary","type":"income","amount":32000,'
              '"category":"salary","date":"2026-10-01T09:00:00.000","note":"Aýlyk"}',
          '{"id":"mine","type":"expense","amount":40,'
              '"category":"food","date":"2026-10-05T09:00:00.000","note":"Market"}',
        ],
      });

      final transactions = await source.readTransactions();

      expect(transactions.map((item) => item.id), ['mine']);
    },
  );
}
