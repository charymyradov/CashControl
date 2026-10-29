import 'package:flutter_test/flutter_test.dart';
import 'package:pul/core/utils/formatters.dart';

void main() {
  group('money formatting', () {
    test('uses Turkmen separators', () {
      expect(formatMoney(24580.5), '24.580,50 TMT');
      expect(formatMoney(640), '640,00 TMT');
      expect(formatMoney(-7419.5), '−7.419,50 TMT');
    });

    test('adds a sign for movement values', () {
      expect(formatSignedMoney(32000), '+32.000,00 TMT');
      expect(formatSignedMoney(-180.5), '−180,50 TMT');
    });
  });

  test('formats dates and months', () {
    final date = DateTime(2026, 10, 21);
    expect(formatDate(date), '21 Ekim 2026');
    expect(formatMonthAndYear(date), 'Ekim 2026');
    expect(formatTransactionDate(date, now: DateTime(2026, 10, 21)), 'Bu gün');
    expect(formatTransactionDate(DateTime(2026, 10, 20), now: date), 'Düýn');
    expect(formatTransactionDate(DateTime(2026, 10, 19), now: date), '19 Ekim');
  });
}
