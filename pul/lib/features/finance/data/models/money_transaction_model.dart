import '../../domain/entities/money_transaction.dart';
import '../../domain/entities/transaction_category.dart';
import '../../domain/entities/transaction_type.dart';

class MoneyTransactionModel extends MoneyTransaction {
  const MoneyTransactionModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.category,
    required super.date,
    super.note,
    super.customCategoryId,
    super.customCategoryLabel,
    super.customCategoryColor,
    super.customCategoryIcon,
    super.iconNameId,
    super.iconNameLabel,
    super.iconNameIcon,
  });

  factory MoneyTransactionModel.fromEntity(MoneyTransaction transaction) {
    return MoneyTransactionModel(
      id: transaction.id,
      type: transaction.type,
      amount: transaction.amount,
      category: transaction.category,
      date: transaction.date,
      note: transaction.note,
      customCategoryId: transaction.customCategoryId,
      customCategoryLabel: transaction.customCategoryLabel,
      customCategoryColor: transaction.customCategoryColor,
      customCategoryIcon: transaction.customCategoryIcon,
      iconNameId: transaction.iconNameId,
      iconNameLabel: transaction.iconNameLabel,
      iconNameIcon: transaction.iconNameIcon,
    );
  }

  factory MoneyTransactionModel.fromJson(Map<String, dynamic> json) {
    return MoneyTransactionModel(
      id: json['id'] as String,
      type: TransactionType.values.byName(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      category: TransactionCategory.values.byName(json['category'] as String),
      date: DateTime.parse(json['date'] as String),
      note: (json['note'] as String?) ?? '',
      customCategoryId: json['customCategoryId'] as String?,
      customCategoryLabel: json['customCategoryLabel'] as String?,
      customCategoryColor: json['customCategoryColor'] as int?,
      customCategoryIcon: json['customCategoryIcon'] as int?,
      iconNameId: json['iconNameId'] as String?,
      iconNameLabel: json['iconNameLabel'] as String?,
      iconNameIcon: json['iconNameIcon'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
      'note': note,
      if (customCategoryId != null) 'customCategoryId': customCategoryId,
      if (customCategoryLabel != null)
        'customCategoryLabel': customCategoryLabel,
      if (customCategoryColor != null)
        'customCategoryColor': customCategoryColor,
      if (customCategoryIcon != null) 'customCategoryIcon': customCategoryIcon,
      if (iconNameId != null) 'iconNameId': iconNameId,
      if (iconNameLabel != null) 'iconNameLabel': iconNameLabel,
      if (iconNameIcon != null) 'iconNameIcon': iconNameIcon,
    };
  }
}
