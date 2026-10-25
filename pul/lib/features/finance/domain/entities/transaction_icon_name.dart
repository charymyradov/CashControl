import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'transaction_category.dart';
import 'transaction_type.dart';

part 'transaction_icon_name_expense.dart';
part 'transaction_icon_name_income.dart';

class TransactionIconName extends Equatable {
  const TransactionIconName({
    required this.id,
    required this.label,
    required this.iconCodePoint,
    required this.category,
    required this.type,
  });

  final String id;
  final String label;
  final int iconCodePoint;
  final TransactionCategory category;
  final TransactionType type;

  // ignore: non_const_argument_for_const_parameter
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  factory TransactionIconName.fromJson(Map<String, dynamic> json) {
    return TransactionIconName(
      id: json['id'] as String,
      label: json['label'] as String,
      iconCodePoint: json['iconCodePoint'] as int,
      category: TransactionCategory.values.byName(json['category'] as String),
      type: TransactionType.values.byName(json['type'] as String),
    );
  }

  Map<String, Object> toJson() => {
    'id': id,
    'label': label,
    'iconCodePoint': iconCodePoint,
    'category': category.name,
    'type': type.name,
  };

  /// Every icon name (expenses first, then incomes).
  static final List<TransactionIconName> all = <TransactionIconName>[
    ..._expenseIconNames,
    ..._incomeIconNames,
  ];

  static List<TransactionIconName> forCategory(
    TransactionCategory category,
    TransactionType type,
  ) {
    return all
        .where((item) => item.category == category && item.type == type)
        .toList();
  }

  static TransactionIconName? findById(String id) {
    try {
      return all.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  static TransactionIconName? defaultFor(
    TransactionCategory category,
    TransactionType type,
  ) {
    final list = forCategory(category, type);
    return list.isNotEmpty ? list.first : null;
  }

  @override
  List<Object?> get props => [id, label, iconCodePoint, category, type];
}
