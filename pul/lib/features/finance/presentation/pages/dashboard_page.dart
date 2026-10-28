import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/money_transaction.dart';
import '../../domain/entities/transaction_category.dart';
import '../../domain/entities/transaction_icon_name.dart';
import '../../domain/entities/transaction_type.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_add_panel.dart';
import '../widgets/spending_overview_card.dart';
import '../widgets/summary_tile.dart';
import 'add_transaction_page.dart';
import 'all_transactions_page.dart';
import 'settings_page.dart';

/// Home screen holding the dashboard and all-transactions tabs.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  /// Selected bottom navigation tab: 0 = Home, 1 = Ähli amallar.
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: state.isReady
              ? FloatingActionButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _openAdd(context);
                  },
                  tooltip: 'Amal goş',
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  highlightElevation: 2,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add_rounded, size: 28),
                )
              : null,
          bottomNavigationBar: AppBottomNav(
            currentIndex: _tab,
            onHome: () {
              HapticFeedback.selectionClick();
              setState(() => _tab = 0);
            },
            onTransactions: () {
              HapticFeedback.selectionClick();
              setState(() => _tab = 1);
            },
            onCalculate: () => _openAdd(context),
          ),
          body: SafeArea(
            bottom: false,
            child: switch (state.status) {
              FinanceStatus.initial || FinanceStatus.loading
                  when state.transactions.isEmpty =>
                const _LoadingView(),
              FinanceStatus.failure when state.transactions.isEmpty =>
                _ErrorView(
                  message:
                      state.errorMessage ?? 'Maglumatlary ýüklemek başartmady.',
                  onRetry: () =>
                      context.read<FinanceBloc>().add(const FinanceStarted()),
                ),
              _ => IndexedStack(
                index: _tab,
                children: [
                  _buildContent(context, state),
                  const AllTransactionsPage(embedded: true),
                ],
              ),
            },
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, FinanceState state) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
      children: [
        _Header(
          onSettings: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SettingsPage()));
          },
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BalanceCard(
                balance: state.totalBalance,
                monthNet: state.monthlyNet,
                isHidden: state.isBalanceHidden,
                onToggleVisibility: () {
                  HapticFeedback.lightImpact();
                  context.read<FinanceBloc>().add(
                    const BalanceVisibilityToggled(),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: (BalanceCard.height - 12) / 2,
                    child: SummaryTile(
                      label: 'Girdeji',
                      amount: '+${formatMoney(state.monthlyIncome)}',
                      icon: Icons.arrow_upward_rounded,
                      color: AppColors.greenDark,
                      iconColor: AppColors.green,
                      background: AppColors.greenSoft,
                      borderColor: const Color(0xFFD8F2E6),
                      isHidden: state.isBalanceHidden,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: (BalanceCard.height - 12) / 2,
                    child: SummaryTile(
                      label: 'Çykdajy',
                      amount: '−${formatMoney(state.monthlyExpense)}',
                      icon: Icons.arrow_downward_rounded,
                      color: AppColors.coralDark,
                      iconColor: AppColors.coral,
                      background: AppColors.coralSoft,
                      borderColor: const Color(0xFFF9DDD8),
                      isHidden: state.isBalanceHidden,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        QuickAddPanel(
          onQuickAdd: (amount, category, iconName) =>
              _quickAdd(context, amount: amount, category: category, iconName: iconName),
        ),
        const SizedBox(height: 14),
        SpendingOverviewCard(state: state),
      ],
    );
  }

  /// Writes a small expense to the local storage right away.
  void _quickAdd(
    BuildContext context, {
    required double amount,
    required TransactionCategory category,
    TransactionIconName? iconName,
  }) {
    final transaction = MoneyTransaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: TransactionType.expense,
      amount: amount,
      category: category,
      date: DateTime.now(),
      note: '',
      iconNameId: iconName?.id,
      iconNameLabel: iconName?.label,
      iconNameIcon: iconName?.icon.codePoint,
    );

    context.read<FinanceBloc>().add(TransactionSaved(transaction));
    HapticFeedback.lightImpact();

    final displayLabel = iconName?.label ?? category.label;
    AppToast.show(
      context,
      message: '$displayLabel • ${formatMoney(amount)} goşuldy',
      icon: Icons.check_circle_rounded,
      duration: const Duration(seconds: 4),
      actionLabel: 'Redaktirle',
      onAction: () => _edit(context, transaction),
    );
  }

  Future<void> _openAdd(
    BuildContext context, {
    TransactionCategory? category,
  }) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddTransactionPage(initialCategory: category),
      ),
    );
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
}

class _Header extends StatelessWidget {
  const _Header({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE9EEF1), Color(0xFFD4DEE4)],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C17222C),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppColors.navy,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pullarym',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.7,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatMonthAndYear(DateTime.now()),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onSettings,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: const Tooltip(
                message: 'Sazlamalar',
                child: Icon(
                  Icons.settings_outlined,
                  color: AppColors.inkSoft,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF43D79A), AppColors.greenDark],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Text(
              'P',
              style: TextStyle(
                color: Colors.white,
                fontSize: 31,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.green,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Maglumatlar ýüklenýär...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: const BoxDecoration(
                color: AppColors.coralSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.coralDark,
                size: 27,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onRetry();
              },
              style: FilledButton.styleFrom(minimumSize: const Size(150, 46)),
              child: const Text('Täzeden synanyş'),
            ),
          ],
        ),
      ),
    );
  }
}
