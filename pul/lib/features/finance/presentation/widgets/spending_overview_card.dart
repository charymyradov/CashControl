import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/money_transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../bloc/finance_state.dart';
import 'surface_card.dart';

enum SpendingPeriod {
  thisMonth('Bu aý'),
  lastMonth('Geçen aý'),
  threeMonths('3 aý');

  const SpendingPeriod(this.label);

  final String label;

  ({DateTime start, DateTime end}) range([DateTime? now]) {
    final date = now ?? DateTime.now();
    final currentStart = DateTime(date.year, date.month);
    return switch (this) {
      SpendingPeriod.thisMonth => (
        start: currentStart,
        end: DateTime(date.year, date.month + 1),
      ),
      SpendingPeriod.lastMonth => (
        start: DateTime(date.year, date.month - 1),
        end: currentStart,
      ),
      SpendingPeriod.threeMonths => (
        start: DateTime(date.year, date.month - 2),
        end: DateTime(date.year, date.month + 1),
      ),
    };
  }
}

class SpendingOverviewCard extends StatefulWidget {
  const SpendingOverviewCard({super.key, required this.state});

  final FinanceState state;

  @override
  State<SpendingOverviewCard> createState() => _SpendingOverviewCardState();
}

class _SpendingOverviewCardState extends State<SpendingOverviewCard> {
  SpendingPeriod _period = SpendingPeriod.thisMonth;

  @override
  Widget build(BuildContext context) {
    final range = _period.range();
    final categoryTransactions = widget.state
        .transactionsBetween(range.start, range.end)
        .where((item) => item.type == TransactionType.expense)
        .toList();
    final total = categoryTransactions.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final entries = _buildEntries(categoryTransactions, total);
    final periodMonths = _period == SpendingPeriod.threeMonths ? 3 : 1;
    final previousStart = DateTime(
      range.start.year,
      range.start.month - periodMonths,
    );
    final previousTotal = widget.state.expenseBetween(
      previousStart,
      range.start,
    );

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Çykdajy statistikasy',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              PopupMenuButton<SpendingPeriod>(
                initialValue: _period,
                onSelected: (period) => setState(() => _period = period),
                color: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 8,
                shadowColor: const Color(0x2217222C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                itemBuilder: (context) {
                  return SpendingPeriod.values.map((period) {
                    return PopupMenuItem<SpendingPeriod>(
                      value: period,
                      height: 42,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              period.label,
                              style: TextStyle(
                                color: period == _period
                                    ? AppColors.greenDark
                                    : AppColors.ink,
                                fontSize: 13,
                                fontWeight: period == _period
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (period == _period)
                            const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: AppColors.greenDark,
                            ),
                        ],
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(11, 7, 8, 7),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _period.label,
                        style: const TextStyle(
                          color: Color(0xFF5F6972),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF7A858E),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            _EmptyStatistics(isHidden: widget.state.isBalanceHidden)
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        key: ValueKey('${_period.name}-$total'),
                        duration: const Duration(milliseconds: 560),
                        curve: Curves.easeOutCubic,
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, progress, _) {
                          return CustomPaint(
                            size: const Size.square(130),
                            painter: _DonutChartPainter(
                              entries: entries,
                              progress: progress,
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.state.isBalanceHidden
                                    ? '•••• TMT'
                                    : formatMoney(total),
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'çykdajy',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      for (var index = 0; index < entries.length; index++) ...[
                        if (index > 0) const SizedBox(height: 9),
                        _LegendRow(
                          entry: entries[index],
                          isHidden: widget.state.isBalanceHidden,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          if (widget.state.transactions.isNotEmpty) ...[
            _MonthlySpendingChart(
              state: widget.state,
              isHidden: widget.state.isBalanceHidden,
            ),
            const SizedBox(height: 16),
            _PeriodComparison(
              currentLabel: _period.label,
              currentTotal: total,
              previousTotal: previousTotal,
              isHidden: widget.state.isBalanceHidden,
            ),
          ],
        ],
      ),
    );
  }

  List<_ChartEntry> _buildEntries(
    List<MoneyTransaction> transactions,
    double total,
  ) {
    if (total <= 0) return const [];

    final totals = <String, _ChartEntry>{};
    for (final transaction in transactions) {
      final customId = transaction.customCategoryId;
      final iconNameId = transaction.iconNameId;
      final key = customId != null
          ? 'custom:$customId'
          : iconNameId != null
          ? 'icon:$iconNameId'
          : 'built-in:${transaction.category.name}';
      final customColor = transaction.customCategoryColor;
      final entry = totals[key];
      totals[key] = _ChartEntry(
        label:
            transaction.iconNameLabel ??
            transaction.customCategoryLabel ??
            transaction.category.label,
        value: (entry?.value ?? 0) + transaction.amount,
        color: customColor == null
            ? transaction.category.color
            : Color(customColor),
        share: 0,
      );
    }
    final sorted = totals.values.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.length <= 4) {
      return sorted
          .map(
            (entry) => _ChartEntry(
              label: entry.label,
              value: entry.value,
              color: entry.color,
              share: entry.value / total,
            ),
          )
          .toList();
    }

    final visible = sorted.take(3).map((entry) {
      return _ChartEntry(
        label: entry.label,
        value: entry.value,
        color: entry.color,
        share: entry.value / total,
      );
    }).toList();

    final remaining = sorted
        .skip(3)
        .fold<double>(0, (sum, entry) => sum + entry.value);
    visible.add(
      _ChartEntry(
        label: 'Beýleki',
        value: remaining,
        color: AppColors.slate,
        share: remaining / total,
      ),
    );
    return visible;
  }
}

class _ChartEntry {
  const _ChartEntry({
    required this.label,
    required this.value,
    required this.color,
    required this.share,
  });

  final String label;
  final double value;
  final Color color;
  final double share;
}

class _MonthlySpendingChart extends StatelessWidget {
  const _MonthlySpendingChart({required this.state, required this.isHidden});

  final FinanceState state;
  final bool isHidden;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = List.generate(
      6,
      (index) => DateTime(now.year, now.month - 5 + index),
    );
    final values = months.map((month) {
      return state.expenseBetween(month, DateTime(month.year, month.month + 1));
    }).toList();
    final maximum = values.fold<double>(0, math.max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Soňky 6 aýyň çykdajysy',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 88,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var index = 0; index < months.length; index++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (index == months.length - 1 &&
                            values[index] > 0 &&
                            !isHidden)
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              formatMoney(values[index]),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          height: maximum == 0
                              ? 4
                              : 6 + (values[index] / maximum * 38),
                          decoration: BoxDecoration(
                            color: index == months.length - 1
                                ? AppColors.green
                                : AppColors.green.withValues(alpha: 0.32),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          shortMonth(months[index]),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PeriodComparison extends StatelessWidget {
  const _PeriodComparison({
    required this.currentLabel,
    required this.currentTotal,
    required this.previousTotal,
    required this.isHidden,
  });

  final String currentLabel;
  final double currentTotal;
  final double previousTotal;
  final bool isHidden;

  @override
  Widget build(BuildContext context) {
    final maximum = math.max(currentTotal, previousTotal);
    final difference = currentTotal - previousTotal;
    final change = previousTotal == 0
        ? null
        : (difference / previousTotal * 100).abs();
    final increase = difference > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Öňki döwür bilen deňeşdirme',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (change != null)
              Text(
                '${increase ? '+' : '−'}${formatPercent(change)}',
                style: TextStyle(
                  color: increase ? AppColors.coralDark : AppColors.greenDark,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        _ComparisonRow(
          label: currentLabel,
          value: currentTotal,
          maximum: maximum,
          color: AppColors.green,
          isHidden: isHidden,
        ),
        const SizedBox(height: 8),
        _ComparisonRow(
          label: 'Öňki döwür',
          value: previousTotal,
          maximum: maximum,
          color: AppColors.blue,
          isHidden: isHidden,
        ),
      ],
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.value,
    required this.maximum,
    required this.color,
    required this.isHidden,
  });

  final String label;
  final double value;
  final double maximum;
  final Color color;
  final bool isHidden;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: maximum == 0 ? 0 : value / maximum,
              minHeight: 8,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 68,
          child: Text(
            isHidden ? '••••' : formatMoney(value),
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.entry, required this.isHidden});

  final _ChartEntry entry;
  final bool isHidden;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: entry.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            entry.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF5B6670),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 78,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isHidden ? '••••' : formatMoney(entry.value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                formatPercent(entry.share * 100),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyStatistics extends StatelessWidget {
  const _EmptyStatistics({required this.isHidden});

  final bool isHidden;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
      child: Row(
        children: [
          SizedBox(
            width: 118,
            height: 118,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size.square(118),
                  painter: _EmptyDonutPainter(),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isHidden ? '•••• TMT' : '0,00 TMT',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.35,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'çykdajy',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Text(
              'Bu döwür üçin çykdajy ýok.\nTäze amal goşup başlaň.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({required this.entries, required this.progress});

  final List<_ChartEntry> entries;
  final double progress;

  static const _strokeWidth = 17.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) - _strokeWidth) / 2;

    final background = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..color = AppColors.surfaceMuted;
    canvas.drawCircle(center, radius, background);

    if (entries.isEmpty || progress <= 0) return;

    if (entries.length == 1) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = entries.first.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        paint,
      );
      return;
    }

    final gap = 0.055;
    var startAngle = -math.pi / 2;

    for (final entry in entries) {
      final fullSweep = entry.share * 2 * math.pi;
      final sweep = math.max(0.0, fullSweep - gap);
      if (sweep <= 0) {
        startAngle += fullSweep * progress;
        continue;
      }

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = entry.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + gap / 2,
        sweep * progress,
        false,
        paint,
      );
      startAngle += fullSweep * progress;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.entries != entries;
  }
}

class _EmptyDonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 16.0;
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AppColors.surfaceMuted;
    canvas.drawCircle(center, radius, paint);

    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = AppColors.greenSoft;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 0.7,
      false,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _EmptyDonutPainter oldDelegate) => false;
}
