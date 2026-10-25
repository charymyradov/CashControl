import 'package:flutter_test/flutter_test.dart';
import 'package:pul/features/finance/data/backup/ledger_backup_codec.dart';
import 'package:pul/features/finance/domain/entities/money_transaction.dart';
import 'package:pul/features/finance/domain/entities/custom_transaction_category.dart';
import 'package:pul/features/finance/domain/entities/transaction_category.dart';
import 'package:pul/features/finance/domain/entities/transaction_type.dart';

void main() {
  final transactions = [
    MoneyTransaction(
      id: 'income',
      type: TransactionType.income,
      amount: 32000,
      category: TransactionCategory.salary,
      date: DateTime(2026, 10, 1, 9),
      note: 'Aýlyk',
    ),
    MoneyTransaction(
      id: 'market',
      type: TransactionType.expense,
      amount: 640.50,
      category: TransactionCategory.food,
      date: DateTime(2026, 10, 21, 18),
      note: 'Market',
    ),
  ];

  test('round trips the ledger', () {
    const customCategory = CustomTransactionCategory(
      id: 'pets',
      label: 'Haýwanlar',
      type: TransactionType.expense,
      colorValue: 0xFF20A88A,
      iconCodePoint: 0xE91D,
    );
    final customTransaction = transactions.last.copyWith(
      customCategoryId: customCategory.id,
      customCategoryLabel: customCategory.label,
      customCategoryColor: customCategory.colorValue,
      customCategoryIcon: customCategory.iconCodePoint,
    );
    final backup = LedgerBackupCodec.encode(
      [transactions.first, customTransaction],
      customCategories: const [customCategory],
    );

    final restored = LedgerBackupCodec.decode(backup);
    final restoredCategories = LedgerBackupCodec.decodeCustomCategories(backup);

    expect(restored, hasLength(2));
    expect(restored.first.id, 'income');
    expect(restored.first.amount, 32000);
    expect(restored.first.category, TransactionCategory.salary);
    expect(restored.first.date, DateTime(2026, 10, 1, 9));
    expect(restored.last.id, 'market');
    expect(restored.last.amount, 640.50);
    expect(restored.last.note, 'Market');
    expect(restored.last.customCategoryId, customCategory.id);
    expect(restoredCategories, [customCategory]);
  });

  test('writes a readable document', () {
    final backup = LedgerBackupCodec.encode(transactions);

    expect(backup, contains('"app": "pul"'));
    expect(backup, contains('"version": 1'));
    expect(backup, contains('"transactions"'));
    expect(backup, contains('"customCategories"'));
  });

  test('rejects a document of another app', () {
    expect(
      () => LedgerBackupCodec.decode(
        '{"app": "other", "version": 1, "transactions": []}',
      ),
      throwsFormatException,
    );
  });

  test('rejects a damaged document', () {
    expect(() => LedgerBackupCodec.decode('not json'), throwsFormatException);
    expect(() => LedgerBackupCodec.decode(''), throwsFormatException);
  });

  test('rejects an unknown version', () {
    expect(
      () => LedgerBackupCodec.decode(
        '{"app": "pul", "version": 99, "transactions": []}',
      ),
      throwsFormatException,
    );
  });

  test('keeps the readable entries of a partly damaged backup', () {
    final backup =
        '{"app":"pul","version":1,"transactions":['
        '{"id":"good","type":"expense","amount":10,"category":"food",'
        '"date":"2026-10-21T12:00:00.000","note":"Market"},'
        '{"id":"broken"}]}';

    final restored = LedgerBackupCodec.decode(backup);

    expect(restored, hasLength(1));
    expect(restored.first.id, 'good');
  });
}
