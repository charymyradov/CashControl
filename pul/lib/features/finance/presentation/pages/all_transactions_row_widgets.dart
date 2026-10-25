part of 'all_transactions_page.dart';

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.state,
    required this.selected,
    required this.onChanged,
  });

  final FinanceState state;
  final _TransactionFilter selected;
  final ValueChanged<_TransactionFilter> onChanged;

  int _countOf(_TransactionFilter filter) {
    return switch (filter) {
      _TransactionFilter.all => state.transactions.length,
      _TransactionFilter.income => state.transactions
          .where((item) => item.type == TransactionType.income)
          .length,
      _TransactionFilter.expense => state.transactions
          .where((item) => item.type == TransactionType.expense)
          .length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0617222C),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          for (final filter in _TransactionFilter.values)
            Expanded(
              child: _FilterSegment(
                label: filter.label,
                count: _countOf(filter),
                selected: filter == selected,
                onTap: () => onChanged(filter),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterSegment extends StatelessWidget {
  const _FilterSegment({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x1F17222C),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '$count',
                style: TextStyle(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.55)
                      : AppColors.textTertiary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(4, 2, 4, 4),
      child: Row(
        children: [
          Icon(
            Icons.swipe_rounded,
            size: 13,
            color: AppColors.textTertiary,
          ),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'Çalt etmek üçin saga ýa-da çepe süýşüriň',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.date,
    required this.income,
    required this.expense,
    required this.isBalanceHidden,
  });

  final DateTime date;
  final double income;
  final double expense;
  final bool isBalanceHidden;

  String get _label {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = today.difference(date).inDays;
    if (difference == 0) return 'Bu gün';
    if (difference == 1) return 'Dün';
    final base = '${date.day} ${shortMonth(date)}';
    return date.year == now.year ? base : '$base ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final net = income - expense;
    final netColor = net > 0
        ? AppColors.greenDark
        : net < 0
        ? AppColors.coralDark
        : AppColors.textSecondary;
    final netLabel = isBalanceHidden
        ? '••••'
        : net == 0
        ? formatMoney(0)
        : formatSignedMoney(net);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Row(
        children: [
          Text(
            _label,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            _weekDays[date.weekday - 1],
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            netLabel,
            style: TextStyle(
              color: netColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeableRow extends StatelessWidget {
  const _SwipeableRow({
    required this.transaction,
    required this.child,
    required this.onEdit,
    required this.onDelete,
  });

  final MoneyTransaction transaction;
  final Widget child;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('swipe-${transaction.id}'),
      direction: DismissDirection.horizontal,
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.28,
        DismissDirection.endToStart: 0.28,
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          HapticFeedback.selectionClick();
          onEdit();
          return false;
        }
        HapticFeedback.mediumImpact();
        await onDelete();
        return false;
      },
      background: const _SwipeBackground(
        alignment: Alignment.centerLeft,
        color: AppColors.green,
        icon: Icons.edit_rounded,
      ),
      secondaryBackground: const _SwipeBackground(
        alignment: Alignment.centerRight,
        color: AppColors.coral,
        icon: Icons.delete_outline_rounded,
      ),
      child: child,
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
