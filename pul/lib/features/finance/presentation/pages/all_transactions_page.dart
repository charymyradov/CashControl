import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/money_transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../widgets/surface_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_page.dart';

const List<String> _weekDays = [
  'Duşenbe',
  'Sişenbe',
  'Çarşenbe',
  'Penşenbe',
  'Anna',
  'Şenbe',
  'Ýekşenbe',
];

enum _TransactionFilter {
  all('Ähli'),
  income('Girdejiler'),
  expense('Çykdajylar');

  const _TransactionFilter(this.label);

  final String label;
}

enum _TransactionAction { edit, delete }

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key, this.embedded = false});

  /// Renders the all-transactions screen inside the dashboard tab.
  final bool embedded;

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  _TransactionFilter _filter = _TransactionFilter.all;
  final Set<String> _expandedExpenseGroups = {};

  @override
  Widget build(BuildContext context) {
    return BlocListener<FinanceBloc, FinanceState>(
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        AppToast.show(
          context,
          message: state.errorMessage!,
          icon: Icons.error_outline_rounded,
        );
      },
      child: Scaffold(
        appBar: widget.embedded
            ? null
            : AppBar(
                title: const Text('Ähli amallar'),
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 23),
                ),
                actions: [
                  IconButton(
                    onPressed: () => _openAdd(context),
                    tooltip: 'Amal goş',
                    icon: const Icon(Icons.add_rounded, size: 23),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
        floatingActionButton: widget.embedded
            ? null
            : FloatingActionButton(
                onPressed: () => _openAdd(context),
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: const CircleBorder(),
                child: const Icon(Icons.add_rounded, size: 26),
              ),
        body: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final visible = _filtered(state.transactions);
            final income = _sumOf(visible, TransactionType.income);
            final expense = _sumOf(visible, TransactionType.expense);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.embedded)
                  _EmbeddedHeader(transactionCount: state.transactions.length),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    widget.embedded ? 10 : 2,
                    20,
                    0,
                  ),
                  child: _OverviewCard(
                    income: income,
                    expense: expense,
                    transactionCount: visible.length,
                    isBalanceHidden: state.isBalanceHidden,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 13, 20, 6),
                  child: _FilterBar(
                    state: state,
                    selected: _filter,
                    onChanged: (filter) {
                      HapticFeedback.selectionClick();
                      setState(() => _filter = filter);
                    },
                  ),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? _buildEmpty(state)
                      : _buildGroupedList(state, visible),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

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

    return ListView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, widget.embedded ? 28 : 110),
      children: [
        const _SwipeHint(),
        for (final day in days) ..._buildDaySection(state, day, groups[day]!),
      ],
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
          setState(() {
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

  String _expansionKey(DateTime day, String groupKey) {
    return '${day.year}-${day.month}-${day.day}:$groupKey';
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

  double _sumOf(List<MoneyTransaction> transactions, TransactionType type) {
    return transactions
        .where((item) => item.type == type)
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  List<MoneyTransaction> _filtered(
    List<MoneyTransaction> transactions, {
    _TransactionFilter? filter,
  }) {
    final activeFilter = filter ?? _filter;
    return switch (activeFilter) {
      _TransactionFilter.all => transactions,
      _TransactionFilter.income =>
        transactions
            .where((item) => item.type == TransactionType.income)
            .toList(),
      _TransactionFilter.expense =>
        transactions
            .where((item) => item.type == TransactionType.expense)
            .toList(),
    };
  }

  Future<void> _openAdd(BuildContext context) async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddTransactionPage()));
    if (saved == true && context.mounted) {
      AppToast.show(
        context,
        message: 'Amal goşuldy',
        icon: Icons.check_circle_rounded,
      );
    }
  }

  Future<void> _edit(BuildContext context, MoneyTransaction transaction) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddTransactionPage(transaction: transaction),
      ),
    );
    if (saved == true && context.mounted) {
      AppToast.show(
        context,
        message: 'Amal täzelendi',
        icon: Icons.check_circle_rounded,
      );
    }
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    MoneyTransaction transaction,
  ) async {
    final confirmed = await _askDelete(context, transaction);
    if (!confirmed || !context.mounted) return;
    _delete(context, transaction);
  }

  Future<bool> _askDelete(
    BuildContext context,
    MoneyTransaction transaction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Amaly pozmalymy?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        content: Text(
          '“${transaction.title}” amaly hemişelik pozular.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Ýatyr'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.coral,
              minimumSize: const Size(92, 44),
            ),
            child: const Text('Poz'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _delete(BuildContext context, MoneyTransaction transaction) {
    final bloc = context.read<FinanceBloc>();
    bloc.add(TransactionDeleted(transaction.id));
    AppToast.show(
      context,
      message: 'Amal pozuldy',
      icon: Icons.delete_outline_rounded,
      actionLabel: 'Yzyna al',
      onAction: () => bloc.add(TransactionSaved(transaction)),
    );
  }
}

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
