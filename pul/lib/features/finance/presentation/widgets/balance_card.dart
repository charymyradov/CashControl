import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.monthNet,
    required this.isHidden,
    required this.onToggleVisibility,
  });

  /// The height of the card, shared with the tiles that stand next to it.
  static const height = 150.0;

  final double balance;
  final double monthNet;
  final bool isHidden;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final isPositive = monthNet >= 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        height: height,
        decoration: const BoxDecoration(gradient: AppColors.navyGradient),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CustomPaint(painter: _BalancePatternPainter()),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Jemi balans',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFFB9C7D5),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: isHidden ? 'Balansy görkez' : 'Balansy gizle',
                        child: InkResponse(
                          onTap: onToggleVisibility,
                          radius: 24,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              isHidden
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFFDCE5ED),
                              size: 21,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(
                                    begin: 0.97,
                                    end: 1,
                                  ).animate(animation),
                                  alignment: Alignment.centerLeft,
                                  child: child,
                                ),
                              ),
                          child: Text(
                            isHidden ? '•••••• TMT' : formatMoney(balance),
                            key: ValueKey(isHidden),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 31,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.5,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: isPositive
                                        ? AppColors.green.withValues(
                                            alpha: 0.23,
                                          )
                                        : AppColors.coral.withValues(
                                            alpha: 0.23,
                                          ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isPositive
                                        ? Icons.arrow_upward_rounded
                                        : Icons.arrow_downward_rounded,
                                    color: isPositive
                                        ? const Color(0xFF71E5B6)
                                        : const Color(0xFFFFA69D),
                                    size: 11,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isHidden
                                      ? '•••• ••••'
                                      : '${isPositive ? '+' : '−'}${formatMoney(monthNet.abs())}',
                                  style: TextStyle(
                                    color: isPositive
                                        ? const Color(0xFF8BEBC4)
                                        : const Color(0xFFFFB4AC),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'bu aý',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalancePatternPainter extends CustomPainter {
  const _BalancePatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.075);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.028);

    final first = Path()
      ..moveTo(size.width * 0.46, size.height)
      ..cubicTo(
        size.width * 0.66,
        size.height * 0.7,
        size.width * 0.6,
        size.height * 0.5,
        size.width * 0.84,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 1.02,
        size.height * 0.46,
        size.width * 0.92,
        size.height * 0.05,
        size.width * 1.2,
        -size.height * 0.05,
      );
    canvas.drawPath(first, paint);

    final second = Path()
      ..moveTo(size.width * 0.58, size.height)
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.76,
        size.width * 0.72,
        size.height * 0.54,
        size.width * 0.98,
        size.height * 0.56,
      )
      ..cubicTo(
        size.width * 1.12,
        size.height * 0.57,
        size.width * 1.06,
        size.height * 0.12,
        size.width * 1.25,
        size.height * 0.04,
      );
    canvas.drawPath(second, paint);

    canvas.drawCircle(
      Offset(size.width * 0.94, size.height * 0.28),
      size.height * 0.31,
      fillPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.84, size.height * 0.72),
      size.height * 0.22,
      fillPaint,
    );

    final sparklePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.11)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4;
    final center = Offset(size.width * 0.77, size.height * 0.18);
    for (var index = 0; index < 4; index++) {
      final angle = index * math.pi / 2;
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * 3,
        center + Offset(math.cos(angle), math.sin(angle)) * 7,
        sparklePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BalancePatternPainter oldDelegate) => false;
}
