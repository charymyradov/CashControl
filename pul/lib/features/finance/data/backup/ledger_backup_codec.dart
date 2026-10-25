import 'dart:convert';

import '../../domain/entities/money_transaction.dart';
import '../../domain/entities/custom_transaction_category.dart';
import '../models/money_transaction_model.dart';

/// Reads and writes the plain text backup of the ledger.
///
/// The backup is a small JSON document that can be copied into the clipboard
/// or saved into a file by the owner of the app.
abstract final class LedgerBackupCodec {
  /// The version of the backup format written by this build.
  static const formatVersion = 1;

  /// The name of the app inside the backup, used to detect a foreign file.
  static const appName = 'pul';

  /// Turns the transactions into a readable backup document.
  static String encode(
    List<MoneyTransaction> transactions, {
    List<CustomTransactionCategory> customCategories = const [],
  }) {
    final payload = <String, Object?>{
      'app': appName,
      'version': formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'transactions': transactions
          .map((item) => MoneyTransactionModel.fromEntity(item).toJson())
          .toList(),
      'customCategories': customCategories
          .map((category) => category.toJson())
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Reads the transactions of a backup document.
  ///
  /// Throws a [FormatException] when the document does not belong to this
  /// app or cannot be read at all.
  static List<MoneyTransaction> decode(String source) {
    final decoded = _decodeRoot(source);
    final raw = decoded['transactions'];
    if (raw is! List) {
      throw const FormatException('Amallar okalmaýar.');
    }

    final transactions = <MoneyTransaction>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      try {
        transactions.add(MoneyTransactionModel.fromJson(item));
      } on Object {
        // One damaged entry must not throw the whole backup away.
      }
    }

    if (transactions.isEmpty && raw.isNotEmpty) {
      throw const FormatException('Amallar okalmaýar.');
    }

    return transactions;
  }

  static List<CustomTransactionCategory>? decodeCustomCategories(
    String source,
  ) {
    final decoded = _decodeRoot(source);
    final raw = decoded['customCategories'];
    if (raw == null) return null;
    if (raw is! List) {
      throw const FormatException('Kategoriýalar okalmaýar.');
    }
    final categories = <CustomTransactionCategory>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      try {
        categories.add(CustomTransactionCategory.fromJson(item));
      } on Object {
        // Ignore damaged category entries while retaining readable entries.
      }
    }
    if (categories.isEmpty && raw.isNotEmpty) {
      throw const FormatException('Kategoriýalar okalmaýar.');
    }
    return categories;
  }

  static Map<String, dynamic> _decodeRoot(String source) {
    final trimmed = source.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Boş maglumat.');
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(trimmed);
    } on FormatException {
      throw const FormatException('Maglumat dogry okalmaýar.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Maglumat dogry okalmaýar.');
    }
    if (decoded['app'] != appName) {
      throw const FormatException('Bu PUL ätiýaçlygy däl.');
    }
    final version = decoded['version'];
    if (version is! int || version < 1 || version > formatVersion) {
      throw const FormatException('Ätiýaçlygyň wersiýasy gyşygarlanýar.');
    }
    return decoded;
  }
}
