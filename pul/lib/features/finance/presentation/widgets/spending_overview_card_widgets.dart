part of 'spending_overview_card.dart';

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
