part of 'all_transactions_page.dart';

extension on _AllTransactionsPageState {
  Widget _buildGroupedList(
    FinanceState state,
    List<MoneyTransaction> transactions,
  ) {
    final groups = <DateTime, List<MoneyTransaction>>{};
    for (final transaction in transactions) {
      final day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      groups.putIfAbsent(day, () => []).add(transaction);
    }
    final days = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 0, 20, widget.embedded ? 28 : 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SwipeHint(),
          for (final day in days) ..._buildDaySection(state, day, groups[day]!),
        ],
      ),
    );
  }

  List<Widget> _buildDaySection(
    FinanceState state,
    DateTime day,
    List<MoneyTransaction> dayTransactions,
  ) {
    final dayExpense = _sumOf(dayTransactions, TransactionType.expense);
    final dayIncome = _sumOf(dayTransactions, TransactionType.income);
    final categoryGroups = <String, List<MoneyTransaction>>{};
    for (final transaction in dayTransactions) {
      final groupKey = transaction.type == TransactionType.income
          ? 'income:${transaction.id}'
          : 'expense:${transaction.customCategoryId ?? transaction.category.name}';
      categoryGroups.putIfAbsent(groupKey, () => []).add(transaction);
    }
    final groupEntries = categoryGroups.entries.toList();

    return [
      _DayHeader(
        date: day,
        income: dayIncome,
        expense: dayExpense,
        isBalanceHidden: state.isBalanceHidden,
      ),
      SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        child: Column(
          children: [
            for (var index = 0; index < groupEntries.length; index++) ...[
              ..._buildCategoryGroup(
                state,
                day,
                groupEntries[index].key,
                groupEntries[index].value,
              ),
              if (index < groupEntries.length - 1) const Divider(indent: 56),
            ],
          ],
        ),
      ),
      const SizedBox(height: 6),
    ];
  }

  List<Widget> _buildCategoryGroup(
    FinanceState state,
    DateTime day,
    String groupKey,
    List<MoneyTransaction> transactions,
  ) {
    if (transactions.length == 1) {
      return [_buildTransactionRow(state, transactions.single)];
    }

    final first = transactions.first;
    final total = transactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.amount,
    );
    final expansionKey = _expansionKey(day, groupKey);
    final isExpanded = _expandedExpenseGroups.contains(expansionKey);
    final summary = first.copyWith(amount: total, note: '');

    return [
      TransactionTile(
        transaction: summary,
        isBalanceHidden: state.isBalanceHidden,
        onTap: () {
          HapticFeedback.selectionClick();
          _updateState(() {
            if (isExpanded) {
              _expandedExpenseGroups.remove(expansionKey);
            } else {
              _expandedExpenseGroups.add(expansionKey);
            }
          });
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${transactions.length}×',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              isExpanded
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
      if (isExpanded)
        for (final transaction in transactions)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _buildTransactionRow(state, transaction),
          ),
    ];
  }

  Widget _buildTransactionRow(
    FinanceState state,
    MoneyTransaction transaction,
  ) {
    return _SwipeableRow(
      transaction: transaction,
      onEdit: () => _edit(context, transaction),
      onDelete: () => _confirmAndDelete(context, transaction),
      child: TransactionTile(
        transaction: transaction,
        isBalanceHidden: state.isBalanceHidden,
        onTap: () => _edit(context, transaction),
        trailing: PopupMenuButton<_TransactionAction>(
          padding: EdgeInsets.zero,
          iconSize: 18,
          color: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          icon: const Icon(
            Icons.more_vert_rounded,
            color: AppColors.textTertiary,
          ),
          onSelected: (action) {
            if (action == _TransactionAction.edit) {
              _edit(context, transaction);
            } else {
              _confirmAndDelete(context, transaction);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _TransactionAction.edit,
              height: 42,
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18, color: AppColors.ink),
                  SizedBox(width: 10),
                  Text('Redaktirle', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            PopupMenuItem(
              value: _TransactionAction.delete,
              height: 42,
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: AppColors.coralDark,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Poz',
                    style: TextStyle(fontSize: 13, color: AppColors.coralDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(FinanceState state) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.greenSoft,
                    AppColors.green.withValues(alpha: 0.22),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.greenDark,
                size: 29,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _filter == _TransactionFilter.all
                  ? 'Heniz amal ýok'
                  : 'Bu görnüşde amal ýok',
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Täze girdeji ýa-da çykdajy goşup başlaň.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => _openAdd(context),
              style: FilledButton.styleFrom(minimumSize: const Size(190, 48)),
              icon: const Icon(Icons.add_rounded, size: 19),
              label: const Text('Amal goş'),
            ),
          ],
        ),
      ),
    );
  }
}
