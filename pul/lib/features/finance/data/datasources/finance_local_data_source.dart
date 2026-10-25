import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/custom_transaction_category.dart';
import '../models/money_transaction_model.dart';

/// Thrown when the device storage refuses to keep a change.
class FinanceStorageException implements Exception {
  const FinanceStorageException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Keeps the whole ledger inside the local storage of the device.
///
/// The app belongs to a single person and has no account and no server, so
/// every transaction is written to the device preferences and read back when
/// the application starts again. The ledger starts empty: no demo data is
/// ever injected.
class FinanceLocalDataSource {
  FinanceLocalDataSource(this._preferences);

  static const _transactionsKey = 'pul.transactions.v1';
  static const _balanceHiddenKey = 'pul.balanceHidden.v1';
  static const _customCategoriesKey = 'pul.customCategories.v1';

  /// Written by older versions of the app, which seeded the ledger with demo
  /// transactions. It is only used to purge that demo data once.
  static const _legacySeedKey = 'pul.seeded.v1';

  /// Prefix used by the demo transactions of the older versions.
  static const _demoIdPrefix = 'seed-';

  final SharedPreferences _preferences;

  /// Serializes the read-modify-write cycles so two quick actions can never
  /// overwrite each other.
  Future<void> _writeQueue = Future<void>.value();

  /// The one time clean up of the legacy demo data.
  Future<void>? _migration;

  Future<List<MoneyTransactionModel>> readTransactions() async {
    await _ensureMigrated();
    return _readStoredTransactions();
  }

  Future<void> saveTransaction(MoneyTransactionModel transaction) {
    return _synchronized(() async {
      await _ensureMigrated();
      final transactions = await _readStoredTransactions();
      final index = transactions.indexWhere(
        (item) => item.id == transaction.id,
      );
      if (index == -1) {
        transactions.add(transaction);
      } else {
        transactions[index] = transaction;
      }
      transactions.sort(_newestFirst);
      await _writeTransactions(transactions);
    });
  }

  Future<void> deleteTransaction(String id) {
    return _synchronized(() async {
      await _ensureMigrated();
      final transactions = await _readStoredTransactions();
      transactions.removeWhere((item) => item.id == id);
      await _writeTransactions(transactions);
    });
  }

  /// Removes every transaction and leaves an empty ledger behind.
  Future<void> clearAllTransactions() {
    return _synchronized(() async {
      await _ensureMigrated();
      await _writeTransactions(const []);
    });
  }

  /// Replaces the whole ledger with the given transactions.
  Future<void> replaceAllTransactions(
    List<MoneyTransactionModel> transactions,
  ) {
    return _synchronized(() async {
      await _ensureMigrated();
      final sorted = [...transactions]..sort(_newestFirst);
      await _writeTransactions(sorted);
    });
  }

  Future<List<CustomTransactionCategory>> readCustomCategories() async {
    final encoded =
        _preferences.getStringList(_customCategoriesKey) ?? const [];
    final categories = <CustomTransactionCategory>[];
    for (final item in encoded) {
      try {
        categories.add(
          CustomTransactionCategory.fromJson(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        );
      } on Object {
        // Ignore one malformed custom category without losing the others.
      }
    }
    return categories;
  }

  Future<void> saveCustomCategory(CustomTransactionCategory category) {
    return _synchronized(() async {
      final categories = await readCustomCategories();
      final index = categories.indexWhere((item) => item.id == category.id);
      if (index == -1) {
        categories.add(category);
      } else {
        categories[index] = category;
      }
      await _writeCustomCategories(categories);
    });
  }

  Future<void> deleteCustomCategory(String id) {
    return _synchronized(() async {
      final categories = await readCustomCategories();
      categories.removeWhere((item) => item.id == id);
      await _writeCustomCategories(categories);
    });
  }

  bool readBalanceHidden() {
    return _preferences.getBool(_balanceHiddenKey) ?? false;
  }

  Future<void> writeBalanceHidden(bool hidden) async {
    final saved = await _preferences.setBool(_balanceHiddenKey, hidden);
    if (!saved) {
      throw const FinanceStorageException('Balans görnüşi ýatda saklanmady.');
    }
  }

  Future<List<MoneyTransactionModel>> _readStoredTransactions() async {
    final encoded = _preferences.getStringList(_transactionsKey) ?? const [];
    final transactions = <MoneyTransactionModel>[];
    for (final item in encoded) {
      try {
        final json = jsonDecode(item) as Map<String, dynamic>;
        transactions.add(MoneyTransactionModel.fromJson(json));
      } on Object {
        // A single damaged entry must not make the whole ledger unreadable.
      }
    }

    transactions.sort(_newestFirst);
    return transactions;
  }

  Future<void> _writeTransactions(
    List<MoneyTransactionModel> transactions,
  ) async {
    final encoded = transactions
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    final saved = await _preferences.setStringList(_transactionsKey, encoded);
    if (!saved) {
      throw const FinanceStorageException('Amal ýatda saklanmady.');
    }
  }

  Future<void> _writeCustomCategories(
    List<CustomTransactionCategory> categories,
  ) async {
    final encoded = categories
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    final saved = await _preferences.setStringList(
      _customCategoriesKey,
      encoded,
    );
    if (!saved) {
      throw const FinanceStorageException('Kategoriýalar ýatda saklanmady.');
    }
  }

  /// Removes the demo transactions of the older versions, keeping every
  /// transaction the owner entered by hand.
  Future<void> _ensureMigrated() {
    return _migration ??= _removeLegacyDemoData();
  }

  Future<void> _removeLegacyDemoData() async {
    if (!_preferences.containsKey(_legacySeedKey)) return;

    final stored = _preferences.getStringList(_transactionsKey) ?? const [];
    final kept = stored.where((item) => !_isDemoEntry(item)).toList();
    if (kept.length != stored.length) {
      final saved = await _preferences.setStringList(_transactionsKey, kept);
      if (!saved) return;
    }

    await _preferences.remove(_legacySeedKey);
  }

  bool _isDemoEntry(String encoded) {
    try {
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      final id = json['id'];
      return id is String && id.startsWith(_demoIdPrefix);
    } on Object {
      return false;
    }
  }

  /// Runs [action] after every previously queued write has finished.
  Future<T> _synchronized<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    final previous = _writeQueue;
    _writeQueue = completer.future.then<void>((_) {}, onError: (Object _) {});

    previous.then((_) async {
      try {
        completer.complete(await action());
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });

    return completer.future;
  }

  int _newestFirst(MoneyTransactionModel a, MoneyTransactionModel b) {
    final byDate = b.date.compareTo(a.date);
    if (byDate != 0) return byDate;
    return b.id.compareTo(a.id);
  }
}
