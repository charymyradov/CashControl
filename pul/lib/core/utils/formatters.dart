const List<String> _shortMonths = [
  'Ýan',
  'Few',
  'Mar',
  'Apr',
  'Maý',
  'Iýun',
  'Iýul',
  'Awg',
  'Sen',
  'Okt',
  'Noý',
  'Dek',
];

const List<String> _fullMonths = [
  'Ýanwar',
  'Fewral',
  'Mart',
  'Aprel',
  'Maý',
  'Iýun',
  'Iýul',
  'Awgust',
  'Sentýabr',
  'Oktýabr',
  'Noýabr',
  'Dekabr',
];

String formatAmount(double amount) {
  final parts = amount.abs().toStringAsFixed(2).split('.');
  final whole = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '$whole,${parts.last}';
}

String formatMoney(
  double amount, {
  bool showSign = false,
  String symbol = ' TMT',
}) {
  final isNegative = amount < 0;
  final sign = showSign ? (isNegative ? '−' : '+') : (isNegative ? '−' : '');
  return '$sign${formatAmount(amount)}$symbol';
}

String formatSignedMoney(double amount) {
  final sign = amount < 0 ? '−' : '+';
  return '$sign${formatAmount(amount)} TMT';
}

String shortMonth(DateTime date) {
  if (date.month < 1 || date.month > 12) return '';
  return _shortMonths[date.month - 1];
}

String formatDate(DateTime date) {
  return '${date.day} ${shortMonth(date)} ${date.year}';
}

String formatMonthAndYear(DateTime date) {
  if (date.month < 1 || date.month > 12) return '';
  return '${_fullMonths[date.month - 1]} ${date.year}';
}

String formatTransactionDate(DateTime date, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final thisDay = DateTime(today.year, today.month, today.day);
  final thatDay = DateTime(date.year, date.month, date.day);
  final difference = thisDay.difference(thatDay).inDays;

  if (difference == 0) return 'Bu gün';
  if (difference == 1) return 'Dün';
  if (date.year == today.year) {
    return '${date.day} ${shortMonth(date)}';
  }
  return '${date.day} ${shortMonth(date)} ${date.year}';
}

String formatPercent(double value) {
  final rounded = value.roundToDouble();
  if ((value - rounded).abs() < 0.05) return '${rounded.toInt()}%';
  return '${value.toStringAsFixed(1)}%';
}

String compactAmount(double amount) {
  if (amount.abs() >= 1000000) {
    return '${(amount / 1000000).toStringAsFixed(1)}M';
  }
  if (amount.abs() >= 10000) {
    return '${(amount / 1000).toStringAsFixed(1)}K';
  }
  return formatAmount(amount);
}
