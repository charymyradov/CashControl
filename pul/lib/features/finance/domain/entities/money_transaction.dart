import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'transaction_category.dart';
import 'transaction_type.dart';

class MoneyTransaction extends Equatable {
  const MoneyTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
    this.customCategoryId,
    this.customCategoryLabel,
    this.customCategoryColor,
    this.customCategoryIcon,
    this.iconNameId,
    this.iconNameLabel,
    this.iconNameIcon,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final TransactionCategory category;
  final DateTime date;
  final String note;
  final String? customCategoryId;
  final String? customCategoryLabel;
  final int? customCategoryColor;
  final int? customCategoryIcon;
  final String? iconNameId;
  final String? iconNameLabel;
  final int? iconNameIcon;

  bool get isIncome => type == TransactionType.income;

  double get signedAmount => isIncome ? amount : -amount;

  String get title => note.trim().isNotEmpty
      ? note.trim()
      : (iconNameLabel ?? customCategoryLabel ?? category.label);

  IconData get displayIcon {
    if (iconNameIcon != null) {
      // ignore: non_const_argument_for_const_parameter
      return IconData(iconNameIcon!, fontFamily: 'MaterialIcons');
    }
    if (customCategoryIcon != null) {
      // ignore: non_const_argument_for_const_parameter
      return IconData(customCategoryIcon!, fontFamily: 'MaterialIcons');
    }
    return category.icon;
  }

  Color get displayColor => category.color;

  MoneyTransaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    TransactionCategory? category,
    DateTime? date,
    String? note,
    String? customCategoryId,
    String? customCategoryLabel,
    int? customCategoryColor,
    int? customCategoryIcon,
    String? iconNameId,
    String? iconNameLabel,
    int? iconNameIcon,
  }) {
    return MoneyTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      customCategoryId: customCategoryId ?? this.customCategoryId,
      customCategoryLabel: customCategoryLabel ?? this.customCategoryLabel,
      customCategoryColor: customCategoryColor ?? this.customCategoryColor,
      customCategoryIcon: customCategoryIcon ?? this.customCategoryIcon,
      iconNameId: iconNameId ?? this.iconNameId,
      iconNameLabel: iconNameLabel ?? this.iconNameLabel,
      iconNameIcon: iconNameIcon ?? this.iconNameIcon,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    amount,
    category,
    date,
    note,
    customCategoryId,
    customCategoryLabel,
    customCategoryColor,
    customCategoryIcon,
    iconNameId,
    iconNameLabel,
    iconNameIcon,
  ];
}
