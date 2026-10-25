import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'transaction_category.dart';
import 'transaction_type.dart';

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

  static List<TransactionIconName> all = [
    /// YД°YECEK (Gider)
    TransactionIconName(
      id: 'food_breakfast',
      label: 'KahvaltД±',
      iconCodePoint: Icons.free_breakfast_rounded.codePoint,
      category: TransactionCategory.food,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'food_lunch',
      label: 'Г–Дџle YemeДџi',
      iconCodePoint: Icons.lunch_dining_rounded.codePoint,
      category: TransactionCategory.food,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'food_dinner',
      label: 'AkЕџam YemeДџi',
      iconCodePoint: Icons.dinner_dining_rounded.codePoint,
      category: TransactionCategory.food,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'food_fastfood',
      label: 'Fast Food',
      iconCodePoint: Icons.fastfood_rounded.codePoint,
      category: TransactionCategory.food,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'food_cafe',
      label: 'Kafe / Kahve',
      iconCodePoint: Icons.local_cafe_rounded.codePoint,
      category: TransactionCategory.food,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'food_groceries',
      label: 'Market / AlД±ЕџveriЕџ',
      iconCodePoint: Icons.shopping_cart_rounded.codePoint,
      category: TransactionCategory.food,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'food_snack',
      label: 'AtД±ЕџtД±rmalД±k',
      iconCodePoint: Icons.cookie_rounded.codePoint,
      category: TransactionCategory.food,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'food_delivery',
      label: 'Yemek SipariЕџi',
      iconCodePoint: Icons.delivery_dining_rounded.codePoint,
      category: TransactionCategory.food,
      type: TransactionType.expense,
    ),

    /// ULAЕћIM (Gider)
    TransactionIconName(
      id: 'transport_bus',
      label: 'OtobГјs / MetrobГјs',
      iconCodePoint: Icons.directions_bus_rounded.codePoint,
      category: TransactionCategory.transport,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'transport_metro',
      label: 'Metro / Tramvay',
      iconCodePoint: Icons.directions_subway_rounded.codePoint,
      category: TransactionCategory.transport,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'transport_taxi',
      label: 'Taksi / UlaЕџД±m',
      iconCodePoint: Icons.local_taxi_rounded.codePoint,
      category: TransactionCategory.transport,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'transport_fuel',
      label: 'YakД±t',
      iconCodePoint: Icons.local_gas_station_rounded.codePoint,
      category: TransactionCategory.transport,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'transport_parking',
      label: 'Park / Otopark',
      iconCodePoint: Icons.local_parking_rounded.codePoint,
      category: TransactionCategory.transport,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'transport_car_service',
      label: 'AraГ§ Servis / BakД±m',
      iconCodePoint: Icons.build_circle_rounded.codePoint,
      category: TransactionCategory.transport,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'transport_flight',
      label: 'UГ§ak Bileti',
      iconCodePoint: Icons.flight_rounded.codePoint,
      category: TransactionCategory.transport,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'transport_other',
      label: 'DiДџer UlaЕџД±m',
      iconCodePoint: Icons.directions_car_rounded.codePoint,
      category: TransactionCategory.transport,
      type: TransactionType.expense,
    ),

    /// EV / YAЕћAM (Gider)
    TransactionIconName(
      id: 'housing_rent',
      label: 'Kira',
      iconCodePoint: Icons.home_rounded.codePoint,
      category: TransactionCategory.housing,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'housing_mortgage',
      label: 'Д°potek / Kredi',
      iconCodePoint: Icons.account_balance_rounded.codePoint,
      category: TransactionCategory.housing,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'housing_electricity',
      label: 'Elektrik',
      iconCodePoint: Icons.bolt_rounded.codePoint,
      category: TransactionCategory.housing,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'housing_water',
      label: 'Su',
      iconCodePoint: Icons.water_drop_rounded.codePoint,
      category: TransactionCategory.housing,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'housing_gas',
      label: 'DoДџalgaz',
      iconCodePoint: Icons.local_fire_department_rounded.codePoint,
      category: TransactionCategory.housing,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'housing_internet',
      label: 'Д°nternet / TV',
      iconCodePoint: Icons.wifi_rounded.codePoint,
      category: TransactionCategory.housing,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'housing_maintenance',
      label: 'Tadilat / OnarД±m',
      iconCodePoint: Icons.handyman_rounded.codePoint,
      category: TransactionCategory.housing,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'housing_furniture',
      label: 'Mobilya / Dekorasyon',
      iconCodePoint: Icons.chair_rounded.codePoint,
      category: TransactionCategory.housing,
      type: TransactionType.expense,
    ),

    /// ALIЕћVERД°Ећ (Gider)
    TransactionIconName(
      id: 'shopping_clothing',
      label: 'Giyim / AyakkabД±',
      iconCodePoint: Icons.checkroom_rounded.codePoint,
      category: TransactionCategory.shopping,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'shopping_electronics',
      label: 'Elektronik',
      iconCodePoint: Icons.devices_rounded.codePoint,
      category: TransactionCategory.shopping,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'shopping_cosmetics',
      label: 'Kozmetik / KiЕџisel BakД±m',
      iconCodePoint: Icons.face_rounded.codePoint,
      category: TransactionCategory.shopping,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'shopping_books',
      label: 'Kitap / Dergi',
      iconCodePoint: Icons.menu_book_rounded.codePoint,
      category: TransactionCategory.shopping,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'shopping_gifts',
      label: 'Hediye',
      iconCodePoint: Icons.card_giftcard_rounded.codePoint,
      category: TransactionCategory.shopping,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'shopping_other',
      label: 'DiДџer AlД±ЕџveriЕџ',
      iconCodePoint: Icons.shopping_bag_rounded.codePoint,
      category: TransactionCategory.shopping,
      type: TransactionType.expense,
    ),

    /// SAДћLIK (Gider)
    TransactionIconName(
      id: 'health_doctor',
      label: 'Doktor / Kontrol',
      iconCodePoint: Icons.medical_services_rounded.codePoint,
      category: TransactionCategory.health,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'health_pharmacy',
      label: 'Eczane / Д°laГ§',
      iconCodePoint: Icons.local_pharmacy_rounded.codePoint,
      category: TransactionCategory.health,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'health_dental',
      label: 'DiЕџ Hekimi',
      iconCodePoint: Icons.medical_information_rounded.codePoint,
      category: TransactionCategory.health,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'health_hospital',
      label: 'Hastane / Acil',
      iconCodePoint: Icons.local_hospital_rounded.codePoint,
      category: TransactionCategory.health,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'health_insurance',
      label: 'SaДџlД±k SigortasД±',
      iconCodePoint: Icons.health_and_safety_rounded.codePoint,
      category: TransactionCategory.health,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'health_wellness',
      label: 'Spor / Wellness',
      iconCodePoint: Icons.fitness_center_rounded.codePoint,
      category: TransactionCategory.health,
      type: TransactionType.expense,
    ),

    /// EДћLENCE (Gider)
    TransactionIconName(
      id: 'entertainment_movies',
      label: 'Sinema / Film',
      iconCodePoint: Icons.movie_rounded.codePoint,
      category: TransactionCategory.entertainment,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'entertainment_games',
      label: 'Oyun / Konsol',
      iconCodePoint: Icons.sports_esports_rounded.codePoint,
      category: TransactionCategory.entertainment,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'entertainment_streaming',
      label: 'YayД±n / Abonelik',
      iconCodePoint: Icons.tv_rounded.codePoint,
      category: TransactionCategory.entertainment,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'entertainment_events',
      label: 'Konser / Etkinlik',
      iconCodePoint: Icons.event_rounded.codePoint,
      category: TransactionCategory.entertainment,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'entertainment_hobby',
      label: 'Hobi / EДџlence',
      iconCodePoint: Icons.palette_rounded.codePoint,
      category: TransactionCategory.entertainment,
      type: TransactionType.expense,
    ),

    /// BД°LД°M / EДћД°TД°M (Gider)
    TransactionIconName(
      id: 'education_course',
      label: 'Kurs / EДџitim',
      iconCodePoint: Icons.school_rounded.codePoint,
      category: TransactionCategory.education,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'education_books',
      label: 'Kitap / Ders KitabД±',
      iconCodePoint: Icons.menu_book_rounded.codePoint,
      category: TransactionCategory.education,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'education_online',
      label: 'Online Kurs',
      iconCodePoint: Icons.computer_rounded.codePoint,
      category: TransactionCategory.education,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'education_certification',
      label: 'Sertifika / SД±nav',
      iconCodePoint: Icons.assignment_rounded.codePoint,
      category: TransactionCategory.education,
      type: TransactionType.expense,
    ),

    /// SEYAHAT (Gider)
    TransactionIconName(
      id: 'travel_flight',
      label: 'UГ§ak Bileti',
      iconCodePoint: Icons.flight_rounded.codePoint,
      category: TransactionCategory.travel,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'travel_hotel',
      label: 'Otel / Konaklama',
      iconCodePoint: Icons.hotel_rounded.codePoint,
      category: TransactionCategory.travel,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'travel_transport',
      label: 'Yerel UlaЕџД±m',
      iconCodePoint: Icons.directions_bus_rounded.codePoint,
      category: TransactionCategory.travel,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'travel_food',
      label: 'Seyahat YemeДџi',
      iconCodePoint: Icons.restaurant_rounded.codePoint,
      category: TransactionCategory.travel,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'travel_activity',
      label: 'Aktivite / Tur',
      iconCodePoint: Icons.explore_rounded.codePoint,
      category: TransactionCategory.travel,
      type: TransactionType.expense,
    ),

    /// ЕћAHSI (Gider)
    TransactionIconName(
      id: 'personal_haircut',
      label: 'SaГ§ / BakД±m',
      iconCodePoint: Icons.content_cut_rounded.codePoint,
      category: TransactionCategory.personal,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'personal_gym',
      label: 'Spor Salonu',
      iconCodePoint: Icons.fitness_center_rounded.codePoint,
      category: TransactionCategory.personal,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'personal_clothing',
      label: 'KiЕџisel AlД±ЕџveriЕџ',
      iconCodePoint: Icons.checkroom_rounded.codePoint,
      category: TransactionCategory.personal,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'personal_subscription',
      label: 'Abonelikler',
      iconCodePoint: Icons.subscriptions_rounded.codePoint,
      category: TransactionCategory.personal,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'personal_other',
      label: 'DiДџer Ећahsi',
      iconCodePoint: Icons.person_rounded.codePoint,
      category: TransactionCategory.personal,
      type: TransactionType.expense,
    ),

    /// MAAЕћ (Gelir)
    TransactionIconName(
      id: 'salary_main',
      label: 'Ana MaaЕџ',
      iconCodePoint: Icons.payments_rounded.codePoint,
      category: TransactionCategory.salary,
      type: TransactionType.income,
    ),
    TransactionIconName(
      id: 'salary_bonus',
      label: 'Prim / Bonus',
      iconCodePoint: Icons.star_rounded.codePoint,
      category: TransactionCategory.salary,
      type: TransactionType.income,
    ),
    TransactionIconName(
      id: 'salary_overtime',
      label: 'Fazla Mesai',
      iconCodePoint: Icons.access_time_rounded.codePoint,
      category: TransactionCategory.salary,
      type: TransactionType.income,
    ),
    TransactionIconName(
      id: 'salary_freelance',
      label: 'Serbest Г‡alД±Еџma',
      iconCodePoint: Icons.work_outline_rounded.codePoint,
      category: TransactionCategory.salary,
      type: TransactionType.income,
    ),
    TransactionIconName(
      id: 'salary_other',
      label: 'DiДџer Gelir',
      iconCodePoint: Icons.attach_money_rounded.codePoint,
      category: TransactionCategory.salary,
      type: TransactionType.income,
    ),

    /// Д°Ећ (Gelir)
    TransactionIconName(
      id: 'business_income',
      label: 'Д°Еџ Geliri',
      iconCodePoint: Icons.work_rounded.codePoint,
      category: TransactionCategory.business,
      type: TransactionType.income,
    ),
    TransactionIconName(
      id: 'business_commission',
      label: 'Komisyon',
      iconCodePoint: Icons.percent_rounded.codePoint,
      category: TransactionCategory.business,
      type: TransactionType.income,
    ),
    TransactionIconName(
      id: 'business_investment',
      label: 'YatД±rД±m Getirisi',
      iconCodePoint: Icons.trending_up_rounded.codePoint,
      category: TransactionCategory.business,
      type: TransactionType.income,
    ),
    TransactionIconName(
      id: 'business_rental',
      label: 'Kira Geliri',
      iconCodePoint: Icons.apartment_rounded.codePoint,
      category: TransactionCategory.business,
      type: TransactionType.income,
    ),

    /// YATIRIM (Gelir)
    TransactionIconName(
      id: 'investment_stocks',
      label: 'Hisse Senedi',
      iconCodePoint: Icons.trending_up_rounded.codePoint,
      category: TransactionCategory.investment,
      type: TransactionType.income,
    ),
    TransactionIconName(
      id: 'investment_crypto',
      label: 'Kripto Para',
      iconCodePoint: Icons.currency_bitcoin_rounded.codePoint,
      category: TransactionCategory.investment,
      type: TransactionType.income,
    ),
    TransactionIconName(
      id: 'investment_dividend',
      label: 'TemettГј',
      iconCodePoint: Icons.attach_money_rounded.codePoint,
      category: TransactionCategory.investment,
      type: TransactionType.income,
    ),
    TransactionIconName(
      id: 'investment_interest',
      label: 'Faiz Geliri',
      iconCodePoint: Icons.savings_rounded.codePoint,
      category: TransactionCategory.investment,
      type: TransactionType.income,
    ),
    TransactionIconName(
      id: 'investment_other',
      label: 'DiДџer YatД±rД±m',
      iconCodePoint: Icons.account_balance_rounded.codePoint,
      category: TransactionCategory.investment,
      type: TransactionType.income,
    ),

    /// HEDД°YE (Gelir)
    TransactionIconName(
      id: 'gift_received',
      label: 'AlД±nan Hediye',
      iconCodePoint: Icons.card_giftcard_rounded.codePoint,
      category: TransactionCategory.gift,
      type: TransactionType.income,
    ),
    TransactionIconName(
      id: 'gift_cash',
      label: 'Nakit Hediye',
      iconCodePoint: Icons.monetization_on_rounded.codePoint,
      category: TransactionCategory.gift,
      type: TransactionType.income,
    ),

    /// DД°ДћER (Her iki tГјr)
    TransactionIconName(
      id: 'other_expense',
      label: 'DiДџer Gider',
      iconCodePoint: Icons.more_horiz_rounded.codePoint,
      category: TransactionCategory.other,
      type: TransactionType.expense,
    ),
    TransactionIconName(
      id: 'other_income',
      label: 'DiДџer Gelir',
      iconCodePoint: Icons.more_horiz_rounded.codePoint,
      category: TransactionCategory.other,
      type: TransactionType.income,
    ),
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
