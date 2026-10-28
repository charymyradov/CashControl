import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/calculator_engine.dart';
import '../../../../core/utils/formatters.dart';

Future<double?> showAmountCalculator(
  BuildContext context, {
  double initialValue = 0,
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    builder: (context) {
      return _CalculatorSheet(initialValue: initialValue);
    },
  );
}

class _CalculatorSheet extends StatefulWidget {
  const _CalculatorSheet({required this.initialValue});

  final double initialValue;

  @override
  State<_CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<_CalculatorSheet> {
  late String _expression;
  bool _solved = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _expression = widget.initialValue > 0
        ? formatCalculatorResult(widget.initialValue)
        : '';
  }

  double? get _currentValue => evaluateExpression(_expression);

  @override
  Widget build(BuildContext context) {
    final preview = _currentValue;
    final showPreview =
        preview != null &&
        RegExp(r'[+\-*/]')
            .hasMatch(_expression.replaceFirst(RegExp(r'^-'), ''));

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lineStrong,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Hasaplaýjy',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceMuted,
                    foregroundColor: AppColors.ink,
                    minimumSize: const Size.square(36),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: BoxDecoration(
                gradient: AppColors.navyGradient,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _expression.isEmpty ? '0' : _expression,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_hasError)
                    const Text(
                      'Aňlatmany barlap görüň',
                      style: TextStyle(
                        color: Color(0xFFFFADA4),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      showPreview
                          ? '= ${formatAmount(preview)}'
                          : 'Netijäni almak üçin = basyň',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.54),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _CalcKey(
                  label: 'C',
                  foreground: AppColors.coralDark,
                  background: AppColors.coralSoft,
                  onTap: () => _setExpression(''),
                ),
                _CalcKey(label: '(', onTap: () => _append('(')),
                _CalcKey(label: ')', onTap: () => _append(')')),
                _CalcKey(
                  label: '÷',
                  isOperator: true,
                  onTap: () => _append('÷'),
                ),
              ],
            ),
            Row(
              children: [
                _CalcKey(label: '7', onTap: () => _append('7')),
                _CalcKey(label: '8', onTap: () => _append('8')),
                _CalcKey(label: '9', onTap: () => _append('9')),
                _CalcKey(
                  label: '×',
                  isOperator: true,
                  onTap: () => _append('×'),
                ),
              ],
            ),
            Row(
              children: [
                _CalcKey(label: '4', onTap: () => _append('4')),
                _CalcKey(label: '5', onTap: () => _append('5')),
                _CalcKey(label: '6', onTap: () => _append('6')),
                _CalcKey(
                  label: '−',
                  isOperator: true,
                  onTap: () => _append('−'),
                ),
              ],
            ),
            Row(
              children: [
                _CalcKey(label: '1', onTap: () => _append('1')),
                _CalcKey(label: '2', onTap: () => _append('2')),
                _CalcKey(label: '3', onTap: () => _append('3')),
                _CalcKey(
                  label: '+',
                  isOperator: true,
                  onTap: () => _append('+'),
                ),
              ],
            ),
            Row(
              children: [
                _CalcKey(label: '0', flex: 2, onTap: () => _append('0')),
                _CalcKey(label: ',', onTap: () => _append(',')),
                _CalcKey(
                  label: '⌫',
                  foreground: AppColors.ink,
                  icon: Icons.backspace_outlined,
                  onTap: _backspace,
                ),
                _CalcKey(
                  label: '=',
                  background: AppColors.green,
                  foreground: Colors.white,
                  onTap: _solve,
                ),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () {
                final value = _currentValue;
                if (value == null) {
                  setState(() => _hasError = true);
                  return;
                }
                Navigator.of(context).pop(value);
              },
              child: const Text('Netijäni ulanmak'),
            ),
          ],
        ),
      ),
    );
  }

  void _append(String value) {
    setState(() {
      _hasError = false;
      if (_solved) {
        final isOperator = RegExp(r'[+\-×÷*/]').hasMatch(value);
        _expression = isOperator ? _expression : '';
        _solved = false;
      }
      if (value == ',') {
        final tail = _expression.split(RegExp(r'[+\-×÷*/()]')).last;
        if (tail.contains(',')) return;
      }
      _expression += value;
    });
  }

  void _setExpression(String value) {
    setState(() {
      _expression = value;
      _solved = false;
      _hasError = false;
    });
  }

  void _backspace() {
    if (_expression.isEmpty) return;
    setState(() {
      _expression = _expression.substring(0, _expression.length - 1);
      _solved = false;
      _hasError = false;
    });
  }

  void _solve() {
    final value = _currentValue;
    if (value == null) {
      setState(() => _hasError = true);
      return;
    }
    setState(() {
      _expression = formatCalculatorResult(value);
      _solved = true;
      _hasError = false;
    });
  }
}

class _CalcKey extends StatelessWidget {
  const _CalcKey({
    required this.label,
    required this.onTap,
    this.icon,
    this.isOperator = false,
    this.background = AppColors.surfaceMuted,
    this.foreground = AppColors.ink,
    this.flex = 1,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isOperator;
  final Color background;
  final Color foreground;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          height: 54,
          child: Material(
            color: isOperator ? AppColors.greenSoft : background,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              borderRadius: BorderRadius.circular(15),
              child: Center(
                child: icon != null
                    ? Icon(icon, size: 20, color: foreground)
                    : Text(
                        label,
                        style: TextStyle(
                          color: isOperator ? AppColors.greenDark : foreground,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
