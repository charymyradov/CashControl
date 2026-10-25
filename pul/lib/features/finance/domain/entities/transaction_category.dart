import 'package:flutter/material.dart';

import 'transaction_type.dart';

enum TransactionCategory {
  food('Iýmit'),
  transport('Ulag'),
  housing('Öý'),
  shopping('Söwda'),
  health('Saglyk'),
  entertainment('Güýmenje'),
  education('Bilim'),
  travel('Syýahat'),
  personal('Şahsy'),
  salary('Aýlyk'),
  business('Iş'),
  investment('Yatyrým'),
  gift('Sowgat'),
  other('Beýleki');

  const TransactionCategory(this.label);

  final String label;

  IconData get icon {
    return switch (this) {
      TransactionCategory.food => Icons.restaurant_rounded,
      TransactionCategory.transport => Icons.directions_bus_rounded,
      TransactionCategory.housing => Icons.home_rounded,
      TransactionCategory.shopping => Icons.shopping_bag_rounded,
      TransactionCategory.health => Icons.medical_services_rounded,
      TransactionCategory.entertainment => Icons.sports_esports_rounded,
      TransactionCategory.education => Icons.school_rounded,
      TransactionCategory.travel => Icons.flight_rounded,
      TransactionCategory.personal => Icons.person_rounded,
      TransactionCategory.salary => Icons.payments_rounded,
      TransactionCategory.business => Icons.work_rounded,
      TransactionCategory.investment => Icons.trending_up_rounded,
      TransactionCategory.gift => Icons.card_giftcard_rounded,
      TransactionCategory.other => Icons.more_horiz_rounded,
    };
  }

  Color get color {
    return switch (this) {
      TransactionCategory.food => const Color(0xFFF44336),
      TransactionCategory.transport => const Color(0xFF2196F3),
      TransactionCategory.housing => const Color(0xFF9C27B0),
      TransactionCategory.shopping => const Color(0xFFFFC107),
      TransactionCategory.health => const Color(0xFF009688),
      TransactionCategory.entertainment => const Color(0xFFE91E63),
      TransactionCategory.education => const Color(0xFF8D6BD1),
      TransactionCategory.travel => const Color(0xFFE0A52B),
      TransactionCategory.personal => const Color(0xFFD65CA5),
      TransactionCategory.salary => const Color(0xFF4CAF50),
      TransactionCategory.business => const Color(0xFF3A8FD8),
      TransactionCategory.investment => const Color(0xFF20A88A),
      TransactionCategory.gift => const Color(0xFFEC407A),
      TransactionCategory.other => const Color(0xFF607D8B),
    };
  }

  bool isAvailableFor(TransactionType type) {
    return switch (type) {
      TransactionType.income => const {
        TransactionCategory.salary,
        TransactionCategory.business,
        TransactionCategory.investment,
        TransactionCategory.gift,
        TransactionCategory.other,
      }.contains(this),
      TransactionType.expense => !const {
        TransactionCategory.salary,
        TransactionCategory.business,
        TransactionCategory.investment,
        TransactionCategory.gift,
      }.contains(this),
    };
  }

  static List<TransactionCategory> forType(TransactionType type) {
    return values.where((category) => category.isAvailableFor(type)).toList();
  }

  static TransactionCategory defaultFor(TransactionType type) {
    return type == TransactionType.income
        ? TransactionCategory.salary
        : TransactionCategory.food;
  }
}
