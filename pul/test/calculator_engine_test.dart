import 'package:flutter_test/flutter_test.dart';
import 'package:pul/core/utils/calculator_engine.dart';

void main() {
  group('evaluateExpression', () {
    test('adds and respects operator precedence', () {
      expect(evaluateExpression('12+8×2'), 28);
      expect(evaluateExpression('100÷4−5'), 20);
    });

    test('supports commas and parentheses', () {
      expect(evaluateExpression('(245,50+4,50)×2'), 500);
    });

    test('rejects incomplete and invalid expressions', () {
      expect(evaluateExpression('12+'), isNull);
      expect(evaluateExpression('12÷0'), isNull);
      expect(evaluateExpression('abc'), isNull);
      expect(evaluateExpression(''), isNull);
    });
  });

  test('formats calculator results with a comma', () {
    expect(formatCalculatorResult(245), '245');
    expect(formatCalculatorResult(245.5), '245,5');
    expect(formatCalculatorResult(0.25), '0,25');
  });
}
