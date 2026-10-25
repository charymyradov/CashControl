import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pul/app.dart';
import 'package:pul/app_dependencies.dart';
import 'package:pul/features/finance/domain/entities/money_transaction.dart';
import 'package:pul/features/finance/domain/entities/custom_transaction_category.dart';
import 'package:pul/features/finance/domain/entities/transaction_category.dart';
import 'package:pul/features/finance/domain/entities/transaction_type.dart';
import 'package:pul/features/finance/domain/repositories/finance_repository.dart';
import 'package:pul/features/finance/presentation/pages/all_transactions_page.dart';
import 'package:pul/features/finance/presentation/widgets/balance_card.dart';
import 'package:pul/features/finance/presentation/widgets/summary_tile.dart';

class _FakeFinanceRepository implements FinanceRepository {
  _FakeFinanceRepository({List<MoneyTransaction>? transactions})
    : _transactions = transactions ?? _sampleTransactions;

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
List<MoneyTransaction> get _sampleTransactions => [
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

void main() {
  testWidgets('dashboard shows a transaction and adds a new expense', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeFinanceRepository();
    await tester.pumpWidget(
      PulApp(dependencies: AppDependencies.fromRepository(repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pullarym'), findsOneWidget);
    expect(find.text('24.580,50 TMT'), findsOneWidget);
    expect(find.text('Amallar'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Täze amal'), findsOneWidget);
    expect(find.text('TMT'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('keypad-2')));
    await tester.tap(find.byKey(const ValueKey('keypad-4')));
    await tester.tap(find.byKey(const ValueKey('keypad-5')));
    await tester.pump();
    expect(find.text('245,00'), findsOneWidget);

    await tester.ensureVisible(find.text('Amaly ýatda sakla'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Amaly ýatda sakla'));
    await tester.pumpAndSettle();

    expect(find.text('Pullarym'), findsOneWidget);
    expect(find.text('24.335,50 TMT'), findsOneWidget);
  });

  testWidgets('transactions tab shows the all transactions screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      PulApp(
        dependencies: AppDependencies.fromRepository(_FakeFinanceRepository()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Amallar'));
    await tester.pumpAndSettle();

    expect(find.text('Ähli amallar'), findsOneWidget);
    expect(find.text('Ähli'), findsOneWidget);
    expect(find.text('Soňky amallar'), findsNothing);
  });

  testWidgets('same-day expenses in one category show as one summed row', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final today = DateTime.now();
    final repository = _FakeFinanceRepository(
      transactions: [
        MoneyTransaction(
          id: 'food-1',
          type: TransactionType.expense,
          amount: 12,
          category: TransactionCategory.food,
          date: today,
          note: 'Lunch',
        ),
        MoneyTransaction(
          id: 'food-2',
          type: TransactionType.expense,
          amount: 8.50,
          category: TransactionCategory.food,
          date: today,
          note: 'Snack',
        ),
      ],
    );

    await tester.pumpWidget(
      PulApp(dependencies: AppDependencies.fromRepository(repository)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Amallar'));
    await tester.pumpAndSettle();

    expect(find.text('Iýmit'), findsOneWidget);
    expect(find.text('−20,50 TMT'), findsWidgets);
    expect(find.text('2×'), findsOneWidget);

    await tester.tap(find.text('Iýmit'));
    await tester.pumpAndSettle();
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Snack'), findsOneWidget);
  });

  testWidgets('starts with an empty ledger and stores the first expense', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeFinanceRepository(transactions: const []);
    await tester.pumpWidget(
      PulApp(dependencies: AppDependencies.fromRepository(repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('0,00 TMT'), findsWidgets);

    await tester.tap(find.text('Amallar'));
    await tester.pumpAndSettle();
    expect(find.text('Heniz amal ýok'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byKey(const ValueKey('keypad-1')));
    await tester.tap(find.byKey(const ValueKey('keypad-2')));
    await tester.tap(find.byKey(const ValueKey('keypad-5')));
    await tester.pump();

    await tester.ensureVisible(find.text('Amaly ýatda sakla'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Amaly ýatda sakla'));
    await tester.pumpAndSettle();

    expect(await repository.getTransactions(), hasLength(1));
    expect(find.text('−125,00 TMT'), findsWidgets);
    expect(find.text('Heniz amal ýok'), findsNothing);
  });

  testWidgets('balance, income and expense share one row', (tester) async {
    for (final size in const [Size(390, 844), Size(800, 600), Size(320, 700)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        PulApp(
          dependencies: AppDependencies.fromRepository(
            _FakeFinanceRepository(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final balance = tester.getRect(find.byType(BalanceCard));
      final income = tester.getRect(find.byType(SummaryTile).at(0));
      final expense = tester.getRect(find.byType(SummaryTile).at(1));

      // The total balance keeps the left side of the row.
      expect(income.left, greaterThan(balance.right - 1), reason: '$size');

      // The income and the expense tile are the same size as the balance.
      expect(income.width, closeTo(balance.width, 1), reason: '$size');
      expect(expense.width, closeTo(balance.width, 1), reason: '$size');

      // The income sits on top of the expense.
      expect(
        expense.top,
        greaterThanOrEqualTo(income.bottom - 1),
        reason: '$size',
      );
      expect(expense.height, closeTo(income.height, 1), reason: '$size');

      // Both tiles fit into the height of the balance card.
      expect(
        expense.bottom,
        lessThanOrEqualTo(balance.bottom + 1),
        reason: '$size',
      );
    }
  });

  testWidgets('dashboard keeps its vertical scroll range compact', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      PulApp(
        dependencies: AppDependencies.fromRepository(
          _FakeFinanceRepository(transactions: const []),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final dashboardScroll = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(dashboardScroll.position.maxScrollExtent, lessThan(320));
  });

  testWidgets('quick add stores an expense with two taps', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeFinanceRepository(transactions: const []);
    await tester.pumpWidget(
      PulApp(dependencies: AppDependencies.fromRepository(repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Çalt goş'), findsOneWidget);

    await tester.ensureVisible(find.text('10'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('10'));
    await tester.pump();

    expect(find.text('10,00 TMT'), findsOneWidget);

    await tester.ensureVisible(find.text('Ulag'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Ulag'));
    await tester.pumpAndSettle();

    final transactions = await repository.getTransactions();
    expect(transactions, hasLength(1));
    expect(transactions.first.amount, 10);
    expect(transactions.first.type, TransactionType.expense);
    expect(transactions.first.category, TransactionCategory.transport);
    await tester.tap(find.text('Amallar'));
    await tester.pumpAndSettle();
    expect(find.text('−10,00 TMT'), findsWidgets);
  });

  testWidgets('deletes a transaction from the all transactions list', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeFinanceRepository();
    await tester.pumpWidget(
      PulApp(dependencies: AppDependencies.fromRepository(repository)),
    );
    await tester.pumpAndSettle();

    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .push(MaterialPageRoute(builder: (_) => const AllTransactionsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Ähli amallar'), findsOneWidget);
    expect(find.text('Market'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Poz'));
    await tester.pumpAndSettle();

    expect(find.text('Amaly pozmalymy?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Poz'));
    await tester.pumpAndSettle();

    expect(await repository.getTransactions(), hasLength(4));
    expect(find.text('Market'), findsNothing);
  });

  testWidgets('edits the category of a transaction', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeFinanceRepository();
    await tester.pumpWidget(
      PulApp(dependencies: AppDependencies.fromRepository(repository)),
    );
    await tester.pumpAndSettle();

    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .push(MaterialPageRoute(builder: (_) => const AllTransactionsPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Market'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Amaly redaktirle'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('category-transport')));
    await tester.pump();

    await tester.ensureVisible(find.text('Üýtgeşmäni sakla'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Üýtgeşmäni sakla'));
    await tester.pumpAndSettle();

    final transactions = await repository.getTransactions();
    final market = transactions.firstWhere((item) => item.id == 'market');
    expect(market.amount, 640);
    expect(market.category, TransactionCategory.transport);
  });

  testWidgets('settings opens and remembers the balance privacy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeFinanceRepository();
    await tester.pumpWidget(
      PulApp(dependencies: AppDependencies.fromRepository(repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Sazlamalar'), findsOneWidget);
    expect(find.text('Çyktary klipboarda kopyala'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(await repository.isBalanceHidden(), isTrue);
  });

  testWidgets('settings creates a custom transaction category', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeFinanceRepository(transactions: const []);
    await tester.pumpWidget(
      PulApp(dependencies: AppDependencies.fromRepository(repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Täze kategoriýa goş'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Haýwanlar');
    await tester.tap(find.text('Ýatda sakla'));
    await tester.pumpAndSettle();

    expect(repository.customCategories, hasLength(1));
    expect(repository.customCategories.single.label, 'Haýwanlar');
    expect(find.text('Haýwanlar'), findsOneWidget);
  });

  testWidgets('balance can be hidden', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeFinanceRepository();
    await tester.pumpWidget(
      PulApp(dependencies: AppDependencies.fromRepository(repository)),
    );
    await tester.pumpAndSettle();

    final visibilityButton = find.byIcon(Icons.visibility_outlined);
    await tester.ensureVisible(visibilityButton);
    await tester.tap(visibilityButton);
    await tester.pumpAndSettle();

    expect(await repository.isBalanceHidden(), isTrue);
    expect(find.text('•••••• TMT'), findsOneWidget);
  });
}
