import 'package:equatable/equatable.dart';

import 'transaction_type.dart';

class CustomTransactionCategory extends Equatable {
  const CustomTransactionCategory({
    required this.id,
    required this.label,
    required this.type,
    required this.colorValue,
    required this.iconCodePoint,
  });

  final String id;
  final String label;
  final TransactionType type;
  final int colorValue;
  final int iconCodePoint;

  factory CustomTransactionCategory.fromJson(Map<String, dynamic> json) {
    return CustomTransactionCategory(
      id: json['id'] as String,
      label: json['label'] as String,
      type: TransactionType.values.byName(json['type'] as String),
      colorValue: json['colorValue'] as int,
      iconCodePoint: json['iconCodePoint'] as int,
    );
  }

  Map<String, Object> toJson() => {
    'id': id,
    'label': label,
    'type': type.name,
    'colorValue': colorValue,
    'iconCodePoint': iconCodePoint,
  };

  @override
  List<Object?> get props => [id, label, type, colorValue, iconCodePoint];
}
