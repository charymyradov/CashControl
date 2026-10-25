import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pul/app.dart';
import 'package:pul/app_dependencies.dart';
import 'package:pul/features/finance/domain/entities/transaction_category.dart';
import 'package:pul/features/finance/presentation/pages/all_transactions_page.dart';

import 'support/fake_finance_repository.dart';

void main() {
  testWidgets('deletes a transaction from the all transactions list', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeFinanceRepository();
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

    final repository = FakeFinanceRepository();
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

    final repository = FakeFinanceRepository();
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

    final repository = FakeFinanceRepository(transactions: const []);
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

    final repository = FakeFinanceRepository();
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
