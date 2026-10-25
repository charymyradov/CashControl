/// A deliberately small arithmetic evaluator used by the in-app calculator.
/// It supports +, −, ×, ÷, decimal commas and parentheses.
double? evaluateExpression(String expression) {
  var normalized = expression
      .replaceAll('×', '*')
      .replaceAll('÷', '/')
      .replaceAll('−', '-')
      .replaceAll(',', '.')
      .replaceAll(' ', '');

  if (normalized.isEmpty) return null;

  // A trailing operator is useful while typing, but there is nothing to solve.
  if (RegExp(r'[+\-*/.]$').hasMatch(normalized)) return null;

  final parser = _ExpressionParser(normalized);
  final value = parser.parse();
  if (value == null || !parser.isAtEnd || !value.isFinite) return null;
  return value;
}

String formatCalculatorResult(double value) {
  if (value == value.truncateToDouble()) {
    return value.toInt().toString();
  }
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '')
      .replaceAll('.', ',');
}

class _ExpressionParser {
  _ExpressionParser(this.source);

  final String source;
  int _position = 0;

  bool get isAtEnd => _position >= source.length;

  double? parse() {
    final value = _parseExpression();
    if (value == null) return null;
    return value;
  }

  double? _parseExpression() {
    var value = _parseTerm();
    if (value == null) return null;

    while (!isAtEnd) {
      final character = source[_position];
      if (character != '+' && character != '-') break;
      _position++;
      final rhs = _parseTerm();
      if (rhs == null) return null;
      value = character == '+' ? value! + rhs : value! - rhs;
    }
    return value;
  }

  double? _parseTerm() {
    var value = _parseFactor();
    if (value == null) return null;

    while (!isAtEnd) {
      final character = source[_position];
      if (character != '*' && character != '/') break;
      _position++;
      final rhs = _parseFactor();
      if (rhs == null) return null;
      if (character == '/' && rhs == 0) return null;
      value = character == '*' ? value! * rhs : value! / rhs;
    }
    return value;
  }

  double? _parseFactor() {
    if (isAtEnd) return null;

    if (source[_position] == '-') {
      _position++;
      final value = _parseFactor();
      return value == null ? null : -value;
    }
    if (source[_position] == '+') {
      _position++;
      return _parseFactor();
    }
    if (source[_position] == '(') {
      _position++;
      final value = _parseExpression();
      if (value == null || isAtEnd || source[_position] != ')') return null;
      _position++;
      return value;
    }

    return _parseNumber();
  }

  double? _parseNumber() {
    final start = _position;
    var dots = 0;
    while (!isAtEnd) {
      final character = source[_position];
      if (character == '.') {
        dots++;
        if (dots > 1) return null;
        _position++;
      } else if (_isDigit(character)) {
        _position++;
      } else {
        break;
      }
    }
    if (start == _position) return null;
    return double.tryParse(source.substring(start, _position));
  }

  bool _isDigit(String character) {
    final code = character.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }
}
