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

part 'all_transactions_sections.dart';
part 'all_transactions_overview_widgets.dart';
part 'all_transactions_row_widgets.dart';

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
                  tooltip: 'Yzyna',
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
                tooltip: 'Amal goş',
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

  String _expansionKey(DateTime day, String groupKey) {
    return '${day.year}-${day.month}-${day.day}:$groupKey';
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
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(dialogContext).pop(true);
            },
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

  /// Allows the section builders (in the part file) to trigger a rebuild.
  void _updateState(VoidCallback fn) => setState(fn);
}
