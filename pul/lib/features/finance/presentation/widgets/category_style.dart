import 'package:flutter/material.dart';

import '../../domain/entities/transaction_category.dart';
import '../../domain/entities/transaction_icon_name.dart';
import '../../domain/entities/transaction_type.dart';

extension TransactionCategoryStyle on TransactionCategory {
  Color get softColor => color.withValues(alpha: 0.13);

  Color get strongSoftColor => color.withValues(alpha: 0.2);

  List<TransactionIconName> iconNamesFor(TransactionType type) {
    return TransactionIconName.forCategory(this, type);
  }
}

IconData customCategoryIcon(int codePoint) {
  const icons = <IconData>[
    Icons.restaurant_rounded,
    Icons.directions_bus_rounded,
    Icons.home_rounded,
    Icons.shopping_bag_rounded,
    Icons.medical_services_rounded,
    Icons.sports_esports_rounded,
    Icons.payments_rounded,
    Icons.work_rounded,
    Icons.card_giftcard_rounded,
    Icons.pets_rounded,
    Icons.school_rounded,
    Icons.flight_rounded,
    Icons.fitness_center_rounded,
    Icons.more_horiz_rounded,
    Icons.free_breakfast_rounded,
    Icons.lunch_dining_rounded,
    Icons.dinner_dining_rounded,
    Icons.fastfood_rounded,
    Icons.local_cafe_rounded,
    Icons.shopping_cart_rounded,
    Icons.cookie_rounded,
    Icons.delivery_dining_rounded,
    Icons.directions_subway_rounded,
    Icons.local_taxi_rounded,
    Icons.local_gas_station_rounded,
    Icons.local_parking_rounded,
    Icons.build_circle_rounded,
    Icons.account_balance_rounded,
    Icons.bolt_rounded,
    Icons.water_drop_rounded,
    Icons.local_fire_department_rounded,
    Icons.wifi_rounded,
    Icons.handyman_rounded,
    Icons.chair_rounded,
    Icons.checkroom_rounded,
    Icons.devices_rounded,
    Icons.face_rounded,
    Icons.menu_book_rounded,
    Icons.local_pharmacy_rounded,
    Icons.medical_information_rounded,
    Icons.local_hospital_rounded,
    Icons.health_and_safety_rounded,
    Icons.movie_rounded,
    Icons.tv_rounded,
    Icons.event_rounded,
    Icons.palette_rounded,
    Icons.star_rounded,
    Icons.access_time_rounded,
    Icons.work_outline_rounded,
    Icons.attach_money_rounded,
    Icons.percent_rounded,
    Icons.trending_up_rounded,
    Icons.apartment_rounded,
    Icons.monetization_on_rounded,
    Icons.computer_rounded,
    Icons.currency_bitcoin_rounded,
    Icons.hotel_rounded,
    Icons.explore_rounded,
    Icons.content_cut_rounded,
    Icons.subscriptions_rounded,
    Icons.assignment_rounded,
    Icons.savings_rounded,
  ];
  return icons.firstWhere(
    (icon) => icon.codePoint == codePoint,
    orElse: () => Icons.more_horiz_rounded,
  );
}
