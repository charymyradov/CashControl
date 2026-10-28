import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/money_transaction.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_state.dart';
import '../widgets/category_quick_strip.dart';
import '../widgets/surface_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_page.dart';
import 'all_transactions_page.dart';

/// The recent transactions list without its own [Scaffold].
///
/// Shared between the standalone page (pushed on top) and the bottom
/// navigation tab on the home screen.
class RecentTransactionsView extends StatelessWidget {
  const RecentTransactionsView({super.key});

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
      child: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          if (state.recentTransactions.isEmpty) {
            return EmptyTransactionsCard(
              onAdd: () {
                // Ignore result on this path — saving already shows a toast
                // on the dashboard.
                Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const AddTransactionPage()),
                );
              },
            );
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              SurfaceCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 3,
                ),
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < state.recentTransactions.length;
                      index++
                    ) ...[
                      TransactionTile(
                        transaction: state.recentTransactions[index],
                        isBalanceHidden: state.isBalanceHidden,
                        onTap: () =>
                            _edit(context, state.recentTransactions[index]),
                      ),
                      if (index < state.recentTransactions.length - 1)
                        const Divider(indent: 56),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AllTransactionsPage(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    minimumSize: const Size(0, 36),
                    textStyle: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Ählisini gör'),
                      SizedBox(width: 3),
                      Icon(Icons.chevron_right_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Opens the edit page for [transaction], keeping the standalone page's
  /// toast behaviour.
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
}

/// Standalone page that wraps [RecentTransactionsView] in its own scaffold.
class RecentTransactionsPage extends StatelessWidget {
  const RecentTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soňky amallar'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, size: 23),
        ),
      ),
      body: const RecentTransactionsView(),
    );
  }
}
