import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pul/app.dart';
import 'package:pul/app_dependencies.dart';
import 'package:pul/features/finance/data/backup/ledger_backup_codec.dart';
import 'package:pul/features/finance/domain/entities/custom_transaction_category.dart';
import 'package:pul/features/finance/domain/entities/transaction_category.dart';
import 'package:pul/features/finance/domain/entities/transaction_type.dart';
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
    final semantics = tester.ensureSemantics();
    await tester.tap(find.bySemanticsLabel('Reňk 2'));
    await tester.tap(find.bySemanticsLabel('Simge 2'));
    semantics.dispose();
    await tester.enterText(find.byType(TextFormField), 'Haýwanlar');
    await tester.tap(find.text('Ýatda sakla'));
    await tester.pumpAndSettle();

    expect(repository.customCategories, hasLength(1));
    expect(repository.customCategories.single.label, 'Haýwanlar');
    expect(
      repository.customCategories.single.colorValue,
      const Color(0xFF3A8FD8).toARGB32(),
    );
    expect(
      repository.customCategories.single.iconCodePoint,
      Icons.directions_bus_rounded.codePoint,
    );
    expect(find.text('Haýwanlar'), findsOneWidget);
  });

  testWidgets('settings disables category actions while saving', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = BlockingCategoryDeleteRepository();
    repository.customCategories.add(
      const CustomTransactionCategory(
        id: 'pets',
        label: 'Haýwanlar',
        type: TransactionType.expense,
        colorValue: 0xFF20A88A,
        iconCodePoint: 0xE91D,
      ),
    );
    await tester.pumpWidget(
      PulApp(dependencies: AppDependencies.fromRepository(repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Poz'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Poz'));
    await tester.pump();
    await repository.deleteStarted.future;

    final deleteButton = find.ancestor(
      of: find.byTooltip('Poz'),
      matching: find.byType(IconButton),
    );
    expect(tester.widget<IconButton>(deleteButton).onPressed, isNull);
    expect(
      tester.widget<ListTile>(find.widgetWithText(ListTile, 'Haýwanlar')).onTap,
      isNull,
    );

    repository.deleteGate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('settings exports categories when the ledger is empty', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? clipboardText;
    final messenger = TestDefaultBinaryMessengerBinding.instance
        .defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboardText = (call.arguments as Map<Object?, Object?>)['text']
            as String;
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

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
    await tester.tap(find.text('Çyktary klipboarda kopyala'));
    await tester.pumpAndSettle();

    expect(clipboardText, isNotNull);
    expect(LedgerBackupCodec.decode(clipboardText!), isEmpty);
    expect(
      LedgerBackupCodec.decodeCustomCategories(clipboardText!)!.single.type,
      TransactionType.expense,
    );
    expect(jsonDecode(clipboardText!)['customCategories'], hasLength(1));
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

class BlockingCategoryDeleteRepository extends FakeFinanceRepository {
  final deleteStarted = Completer<void>();
  final deleteGate = Completer<void>();

  @override
  Future<void> deleteCustomCategory(String id) async {
    deleteStarted.complete();
    await deleteGate.future;
    await super.deleteCustomCategory(id);
  }
}
