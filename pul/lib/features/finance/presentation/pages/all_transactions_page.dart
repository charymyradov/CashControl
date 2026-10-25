import 'package:flutter/material.dart';
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

const List<String> _shortMonths = [
  'Ýan',
  'Few',
  'Mar',
  'Apr',
  'Maý',
  'Iýun',
  'Iýul',
  'Awg',
  'Sen',
  'Okt',
  'Noý',
  'Dek',
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
            final transactions = _filtered(state.transactions);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.embedded)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Ähli amallar',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                  child: _buildFilterBar(state),
                ),
                Expanded(
                  child: transactions.isEmpty
                      ? _buildEmpty(state)
                      : _buildGroupedList(state, transactions),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterBar(FinanceState state) {
    final visibleIncome = _filtered(
      state.transactions,
      filter: _TransactionFilter.income,
    ).fold<double>(0, (sum, item) => sum + item.amount);
    final visibleExpense = _filtered(
      state.transactions,
      filter: _TransactionFilter.expense,
    ).fold<double>(0, (sum, item) => sum + item.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final filter in _TransactionFilter.values)
              _FilterChip(
                label: filter.label,
                selected: filter == _filter,
                onTap: () => setState(() => _filter = filter),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _SummaryPill(
              label: 'Girdeji',
              value: state.isBalanceHidden
                  ? '••••'
                  : '+${formatMoney(visibleIncome)}',
              color: AppColors.greenDark,
              background: AppColors.greenSoft,
            ),
            const SizedBox(width: 8),
            _SummaryPill(
              label: 'Çykdajy',
              value: state.isBalanceHidden
                  ? '••••'
                  : '−${formatMoney(visibleExpense)}',
              color: AppColors.coralDark,
              background: AppColors.coralSoft,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGroupedList(
    FinanceState state,
    List<MoneyTransaction> transactions,
  ) {
    final groups = <String, List<MoneyTransaction>>{};
    for (final transaction in transactions) {
      final key = formatDate(transaction.date);
      groups.putIfAbsent(key, () => []).add(transaction);
    }

    final sortedKeys = groups.keys.toList()
      ..sort((a, b) {
        final dateA = _parseDateKey(a);
        final dateB = _parseDateKey(b);
        return dateB.compareTo(dateA);
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
      children: [
        for (final key in sortedKeys)
          ..._buildDaySection(state, key, groups[key]!),
      ],
    );
  }

  List<Widget> _buildDaySection(
    FinanceState state,
    String key,
    List<MoneyTransaction> dayTransactions,
  ) {
    final dayExpense = dayTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final dayIncome = dayTransactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final categoryGroups = <String, List<MoneyTransaction>>{};
    for (final transaction in dayTransactions) {
      final groupKey = transaction.type == TransactionType.income
          ? 'income:${transaction.id}'
          : 'expense:${transaction.customCategoryId ?? transaction.category.name}';
      categoryGroups.putIfAbsent(groupKey, () => []).add(transaction);
    }
    final groupEntries = categoryGroups.entries.toList();

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  key,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (dayExpense > 0)
                  _DailyTotalChip(
                    label: 'Çykdajy',
                    value: '−${formatMoney(dayExpense)}',
                    color: AppColors.coralDark,
                    background: AppColors.coralSoft,
                  ),
                if (dayIncome > 0)
                  _DailyTotalChip(
                    label: 'Girdeji',
                    value: '+${formatMoney(dayIncome)}',
                    color: AppColors.greenDark,
                    background: AppColors.greenSoft,
                  ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
      SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        child: Column(
          children: [
            for (var index = 0; index < groupEntries.length; index++) ...[
              ..._buildCategoryGroup(
                state,
                key,
                groupEntries[index].key,
                groupEntries[index].value,
              ),
              if (index < groupEntries.length - 1) const Divider(indent: 56),
            ],
          ],
        ),
      ),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _buildCategoryGroup(
    FinanceState state,
    String dayKey,
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
    final expansionKey = '$dayKey:$groupKey';
    final isExpanded = _expandedExpenseGroups.contains(expansionKey);
    final summary = first.copyWith(amount: total, note: '');

    return [
      TransactionTile(
        transaction: summary,
        isBalanceHidden: state.isBalanceHidden,
        onTap: () {
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
        for (var index = 0; index < transactions.length; index++)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _buildTransactionRow(state, transactions[index]),
          ),
    ];
  }

  Widget _buildTransactionRow(
    FinanceState state,
    MoneyTransaction transaction,
  ) {
    return TransactionTile(
      transaction: transaction,
      isBalanceHidden: state.isBalanceHidden,
      onTap: () => _edit(context, transaction),
      trailing: PopupMenuButton<_TransactionAction>(
        padding: EdgeInsets.zero,
        iconSize: 18,
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(
          Icons.more_vert_rounded,
          color: AppColors.textTertiary,
        ),
        onSelected: (action) {
          if (action == _TransactionAction.edit) {
            _edit(context, transaction);
          } else {
            _confirmDelete(context, transaction);
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
    );
  }

  DateTime _parseDateKey(String key) {
    final parts = key.split(' ');
    if (parts.length != 3) return DateTime(1970);
    final day = int.tryParse(parts[0]) ?? 1;
    final monthStr = parts[1];
    final year = int.tryParse(parts[2]) ?? 1970;
    final month = _shortMonths.indexOf(monthStr) + 1;
    return DateTime(year, month > 0 ? month : 1, day);
  }

  Widget _buildEmpty(FinanceState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: const BoxDecoration(
                color: AppColors.greenSoft,
                shape: BoxShape.circle,
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

  Future<void> _confirmDelete(
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

    if (confirmed == true && context.mounted) {
      context.read<FinanceBloc>().add(TransactionDeleted(transaction.id));
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ink : AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.ink : AppColors.line,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  final String label;
  final String value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyTotalChip extends StatelessWidget {
  const _DailyTotalChip({
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  final String label;
  final String value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
