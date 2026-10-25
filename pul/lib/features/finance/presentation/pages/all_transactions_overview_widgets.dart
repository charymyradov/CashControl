part of 'all_transactions_page.dart';

class _EmbeddedHeader extends StatelessWidget {
  const _EmbeddedHeader({required this.transactionCount});

  final int transactionCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ähli amallar',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${formatMonthAndYear(DateTime.now())} • $transactionCount amal',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.income,
    required this.expense,
    required this.transactionCount,
    required this.isBalanceHidden,
  });

  final double income;
  final double expense;
  final int transactionCount;
  final bool isBalanceHidden;

  @override
  Widget build(BuildContext context) {
    final net = income - expense;
    final totalFlow = income + expense;
    final incomeFlex = totalFlow <= 0
        ? 1
        : (income / totalFlow * 1000).round().clamp(1, 999).toInt();
    final expenseFlex = totalFlow <= 0 ? 1 : 1000 - incomeFlex;
    final netLabel = isBalanceHidden
        ? '•••• TMT'
        : net == 0
        ? formatMoney(0)
        : formatSignedMoney(net);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        gradient: AppColors.navyGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26162B3E),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: Color(0xFF7FE7BC),
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Net akym',
                style: TextStyle(
                  color: Color(0xB3FFFFFF),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  '$transactionCount amal',
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            netLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.9,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 6,
              child: totalFlow <= 0
                  ? const ColoredBox(color: Color(0x24FFFFFF))
                  : Row(
                      children: [
                        if (income > 0)
                          Expanded(
                            flex: incomeFlex,
                            child: const ColoredBox(color: Color(0xFF5FE0AF)),
                          ),
                        if (income > 0 && expense > 0)
                          const SizedBox(width: 2),
                        if (expense > 0)
                          Expanded(
                            flex: expenseFlex,
                            child: const ColoredBox(color: Color(0xFFFF9C90)),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _OverviewMetric(
                  label: 'Girdeji',
                  value: isBalanceHidden
                      ? '••••'
                      : '+${formatMoney(income)}',
                  icon: Icons.arrow_upward_rounded,
                  color: const Color(0xFF7FE7BC),
                ),
              ),
              Container(
                width: 1,
                height: 30,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: Colors.white.withValues(alpha: 0.12),
              ),
              Expanded(
                child: _OverviewMetric(
                  label: 'Çykdajy',
                  value: isBalanceHidden
                      ? '••••'
                      : '−${formatMoney(expense)}',
                  icon: Icons.arrow_downward_rounded,
                  color: const Color(0xFFFF9C90),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 27,
          height: 27,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 15),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0x99FFFFFF),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
