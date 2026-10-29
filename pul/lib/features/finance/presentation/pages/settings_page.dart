import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/backup/ledger_backup_codec.dart';
import '../../domain/entities/custom_transaction_category.dart';
import '../../domain/entities/money_transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../widgets/surface_card.dart';
import '../widgets/category_style.dart';

part 'settings_page_sections.dart';
part 'settings_page_widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
        appBar: AppBar(
          title: const Text('Sazlamalar'),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Yzyna',
            icon: const Icon(Icons.arrow_back_rounded, size: 23),
          ),
        ),
        body: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            return _buildSettingsList(context, state);
          },
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Ähli amallary öçürmek isleseňiz?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        content: const Text(
          'Häzirki ähli girdejileriňiz we çykdajylaryňyz ýok edilýär. '
          'Bu hereketi yzyna gaýtaryp bolmaýar.',
          style: TextStyle(
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
              minimumSize: const Size(108, 44),
            ),
            child: const Text('Öçür'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<FinanceBloc>().add(const FinanceDataCleared());
      AppToast.show(
        context,
        message: 'Ähli amallar öçürildi',
        icon: Icons.delete_sweep_outlined,
      );
    }
  }

  Future<void> _editCustomCategory(
    BuildContext context,
    CustomTransactionCategory? category,
  ) async {
    final result = await showDialog<CustomTransactionCategory>(
      context: context,
      builder: (_) => _CustomCategoryDialog(
        category: category,
        existing: context.read<FinanceBloc>().state.customCategories,
      ),
    );
    if (result != null && context.mounted) {
      context.read<FinanceBloc>().add(CustomCategorySaved(result));
    }
  }

  Future<void> _confirmDeleteCustomCategory(
    BuildContext context,
    CustomTransactionCategory category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Kategoriýany pozmalymy?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        content: Text(
          '"${category.label}" täze amallarda ulanylyp bilinmez. '
          'Öňki amallar üýtgemez.',
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
    if (confirmed == true && context.mounted) {
      context.read<FinanceBloc>().add(CustomCategoryDeleted(category.id));
    }
  }

  Future<void> _exportBackup(
    BuildContext context,
    List<MoneyTransaction> transactions,
    List<CustomTransactionCategory> customCategories,
  ) async {
    if (transactions.isEmpty && customCategories.isEmpty) {
      _showMessage(context, 'Ätiýaçlyk üçin amal ýa-da kategoriýa ýok.');
      return;
    }

    try {
      await Clipboard.setData(
        ClipboardData(
          text: LedgerBackupCodec.encode(
            transactions,
            customCategories: customCategories,
          ),
        ),
      );
    } on Object {
      if (!context.mounted) return;
      _showMessage(context, 'Klipboarda ýazmak başartmady.');
      return;
    }

    if (!context.mounted) return;
    _showMessage(context, 'Maglumatlar klipboarda kopyalandy.');
  }

  Future<void> _importBackup(BuildContext context) async {
    final ClipboardData? data;
    try {
      data = await Clipboard.getData(Clipboard.kTextPlain);
    } on Object {
      if (!context.mounted) return;
      _showMessage(context, 'Klipboardy okamak başartmady.');
      return;
    }
    if (!context.mounted) return;

    final payload = data?.text;
    if (payload == null || payload.trim().isEmpty) {
      _showMessage(context, 'Klipboard boş.');
      return;
    }

    final List<MoneyTransaction> transactions;
    final List<CustomTransactionCategory>? customCategories;
    try {
      transactions = LedgerBackupCodec.decode(payload);
      customCategories = LedgerBackupCodec.decodeCustomCategories(payload);
    } on FormatException {
      _showMessage(context, 'Klipboarddaky maglumat PUL ätiýaçlygy däl.');
      return;
    }

    final currentCount = context.read<FinanceBloc>().state.transactions.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Ätiýaçlygy getirmeli?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        content: Text(
          'Häzirki $currentCount amal ätiýaçlykdaky ${transactions.length} amal '
          'bilen çalyşylar.',
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
              backgroundColor: AppColors.green,
              minimumSize: const Size(108, 44),
            ),
            child: const Text('Getir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<FinanceBloc>().add(
        LedgerImported(transactions, customCategories: customCategories),
      );
      _showMessage(context, 'Ätiýaçlyk getirildi.');
    }
  }

  void _showMessage(BuildContext context, String message) {
    AppToast.show(context, message: message);
  }
}
