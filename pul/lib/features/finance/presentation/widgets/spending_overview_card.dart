import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/money_transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../bloc/finance_state.dart';
import 'surface_card.dart';

part 'spending_overview_card_widgets.dart';
part 'spending_overview_card_painters.dart';

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
                tooltip: 'Döwür saýla',
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
