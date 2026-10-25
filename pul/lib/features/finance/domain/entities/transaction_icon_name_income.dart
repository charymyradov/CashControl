part of 'transaction_icon_name.dart';

/// Income icon names, grouped by category.
final List<TransactionIconName> _incomeIconNames = <TransactionIconName>[

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
