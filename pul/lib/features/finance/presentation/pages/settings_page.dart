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
            icon: const Icon(Icons.arrow_back_rounded, size: 23),
          ),
        ),
        body: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
              children: [
                SurfaceCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF43D79A), AppColors.greenDark],
                          ),
                          borderRadius: BorderRadius.circular(19),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'P',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PUL',
                              style: TextStyle(
                                color: AppColors.ink,
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Şahsy pul dolandyryşy',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '1.0.0',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionLabel('GÖRNÜŞ'),
                const SizedBox(height: 8),
                SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: SwitchListTile(
                    value: state.isBalanceHidden,
                    onChanged: (_) => context.read<FinanceBloc>().add(
                      const BalanceVisibilityToggled(),
                    ),
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.green,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFD7DCE0),
                    contentPadding: const EdgeInsets.fromLTRB(16, 3, 12, 3),
                    secondary: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.greenSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        state.isBalanceHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.greenDark,
                        size: 19,
                      ),
                    ),
                    title: const Text(
                      'Balansy gizle',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Mukdarlary başga kişilerden gizläň',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionLabel('KATEGORIÝALAR'),
                const SizedBox(height: 8),
                SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (
                        var index = 0;
                        index < state.customCategories.length;
                        index++
                      ) ...[
                        if (index > 0) const Divider(indent: 70, height: 1),
                        _CustomCategoryTile(
                          category: state.customCategories[index],
                          onEdit: () => _editCustomCategory(
                            context,
                            state.customCategories[index],
                          ),
                          onDelete: () => _confirmDeleteCustomCategory(
                            context,
                            state.customCategories[index],
                          ),
                        ),
                      ],
                      if (state.customCategories.isNotEmpty)
                        const Divider(indent: 70, height: 1),
                      ListTile(
                        onTap: state.isSaving
                            ? null
                            : () => _editCustomCategory(context, null),
                        leading: const _TileIcon(
                          icon: Icons.add_rounded,
                          background: AppColors.greenSoft,
                          foreground: AppColors.greenDark,
                        ),
                        title: const Text(
                          'Täze kategoriýa goş',
                          style: TextStyle(
                            color: AppColors.greenDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionLabel('MAGLUMATLAR'),
                const SizedBox(height: 8),
                SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        onTap: state.isSaving
                            ? null
                            : () => _confirmClear(context),
                        contentPadding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.coralSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete_sweep_outlined,
                            color: AppColors.coralDark,
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Ähli amallary öçür',
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Girdejileriňiz we çykdajylaryňyz hemişelik ýok edilýär',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                        trailing: state.isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.green,
                                ),
                              )
                            : const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textTertiary,
                                size: 20,
                              ),
                      ),
                      const Divider(indent: 70),
                      const ListTile(
                        contentPadding: EdgeInsets.fromLTRB(16, 3, 16, 3),
                        leading: _LocalIcon(),
                        title: Text(
                          'Ýerli saklaýyş',
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Maglumatlar diňe şu enjamda saklanýar',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                        trailing: Icon(
                          Icons.verified_user_outlined,
                          color: AppColors.greenDark,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionLabel('ÄTIÝAÇLYK'),
                const SizedBox(height: 8),
                SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        onTap: state.isSaving
                            ? null
                            : () => _exportBackup(
                                context,
                                state.transactions,
                                state.customCategories,
                              ),
                        contentPadding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
                        leading: const _TileIcon(
                          icon: Icons.copy_all_outlined,
                          background: AppColors.greenSoft,
                          foreground: AppColors.greenDark,
                        ),
                        title: const Text(
                          'Çyktary klipboarda kopyala',
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Ähli amallaryňyz JSON görnüşinde ätiýaçlyk saklamak üçin',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                      ),
                      const Divider(indent: 70),
                      ListTile(
                        onTap: state.isSaving
                            ? null
                            : () => _importBackup(context),
                        contentPadding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
                        leading: const _TileIcon(
                          icon: Icons.content_paste_go_outlined,
                          background: Color(0xFFEAF2FD),
                          foreground: Color(0xFF3A6FA8),
                        ),
                        title: const Text(
                          'Klipboarddan getir',
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Klipboarddaky ätiýaçlyk ähli amallaryňyzy çalyşýar',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.greenTint,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFDDF3E8)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.greenDark,
                        size: 19,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bu wersiýa üçin internet ýa-da daşarky hasap gerek däl. '
                          'Girdejileriňiz we çykdajylaryňyz telefonda ýerli ýagdaýda saklanýar.',
                          style: TextStyle(
                            color: Color(0xFF3E705D),
                            fontSize: 11.5,
                            height: 1.55,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
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
          'Ähli amallary öçürmek isleseňiziz?',
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
        title: const Text('Kategoriýany pozmalymy?'),
        content: Text(
          '"${category.label}" täze amallarda ulanylyp bilinmez. '
          'Öňki amallar üýtgemez.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Ýatyr'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
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
    if (transactions.isEmpty) {
      _showMessage(context, 'Ätiýaçlyk üçin amal ýok.');
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

class _TileIcon extends StatelessWidget {
  const _TileIcon({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: foreground, size: 19),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _LocalIcon extends StatelessWidget {
  const _LocalIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.phone_iphone_rounded,
        color: AppColors.slate,
        size: 19,
      ),
    );
  }
}

class _CustomCategoryTile extends StatelessWidget {
  const _CustomCategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final CustomTransactionCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    return ListTile(
      onTap: onEdit,
      leading: _TileIcon(
        icon: customCategoryIcon(category.iconCodePoint),
        background: color.withValues(alpha: 0.13),
        foreground: color,
      ),
      title: Text(
        category.label,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        category.type == TransactionType.expense ? 'Çykdajy' : 'Girdeji',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Üýtget',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 19),
          ),
          IconButton(
            tooltip: 'Poz',
            onPressed: onDelete,
            color: AppColors.coralDark,
            icon: const Icon(Icons.delete_outline_rounded, size: 19),
          ),
        ],
      ),
    );
  }
}

class _CustomCategoryDialog extends StatefulWidget {
  const _CustomCategoryDialog({required this.category, required this.existing});

  final CustomTransactionCategory? category;
  final List<CustomTransactionCategory> existing;

  @override
  State<_CustomCategoryDialog> createState() => _CustomCategoryDialogState();
}

class _CustomCategoryDialogState extends State<_CustomCategoryDialog> {
  static const _colors = <Color>[
    Color(0xFFE66A5E),
    Color(0xFF3A8FD8),
    Color(0xFF8D6BD1),
    Color(0xFFE0A52B),
    Color(0xFF20A88A),
    Color(0xFFD65CA5),
    Color(0xFF607D8B),
    Color(0xFF506B49),
  ];
  static const _icons = <IconData>[
    Icons.restaurant_rounded,
    Icons.directions_bus_rounded,
    Icons.home_rounded,
    Icons.shopping_bag_rounded,
    Icons.medical_services_rounded,
    Icons.sports_esports_rounded,
    Icons.payments_rounded,
    Icons.work_rounded,
    Icons.card_giftcard_rounded,
    Icons.pets_rounded,
    Icons.school_rounded,
    Icons.flight_rounded,
    Icons.fitness_center_rounded,
    Icons.more_horiz_rounded,
  ];

  late final TextEditingController _nameController;
  late TransactionType _type;
  late Color _color;
  late IconData _icon;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _nameController = TextEditingController(text: category?.label ?? '');
    _type = category?.type ?? TransactionType.expense;
    _color = Color(category?.colorValue ?? _colors.first.toARGB32());
    _icon = customCategoryIcon(
      category?.iconCodePoint ?? _icons.first.codePoint,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      title: Text(
        widget.category == null ? 'Täze kategoriýa' : 'Kategoriýany üýtget',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                maxLength: 24,
                decoration: const InputDecoration(
                  labelText: 'Kategoriýanyň ady',
                  counterText: '',
                ),
                validator: (value) {
                  final label = value?.trim() ?? '';
                  if (label.isEmpty) return 'Adyny giriziň.';
                  final duplicate = widget.existing.any(
                    (item) =>
                        item.id != widget.category?.id &&
                        item.type == _type &&
                        item.label.toLowerCase() == label.toLowerCase(),
                  );
                  return duplicate ? 'Bu kategoriýa eýýäm bar.' : null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Görnüşi',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _typeButton(TransactionType.expense, 'Çykdajy'),
                  const SizedBox(width: 8),
                  _typeButton(TransactionType.income, 'Girdeji'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Reňk',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  for (final color in _colors)
                    GestureDetector(
                      onTap: () => setState(() => _color = color),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _color == color
                                ? AppColors.ink
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: _color == color
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Simge',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final icon in _icons)
                    InkWell(
                      onTap: () => setState(() => _icon = icon),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _icon.codePoint == icon.codePoint
                              ? _color.withValues(alpha: 0.14)
                              : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          size: 19,
                          color: _icon.codePoint == icon.codePoint
                              ? _color
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ýatyr'),
        ),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(backgroundColor: AppColors.green),
          child: const Text('Ýatda sakla'),
        ),
      ],
    );
  }

  Widget _typeButton(TransactionType type, String label) {
    final selected = _type == type;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => setState(() => _type = type),
        style: OutlinedButton.styleFrom(
          foregroundColor: selected ? AppColors.greenDark : AppColors.inkSoft,
          backgroundColor: selected ? AppColors.greenSoft : null,
          side: BorderSide(color: selected ? AppColors.green : AppColors.line),
        ),
        child: Text(label),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      CustomTransactionCategory(
        id:
            widget.category?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        label: _nameController.text.trim(),
        type: _type,
        colorValue: _color.toARGB32(),
        iconCodePoint: _icon.codePoint,
      ),
    );
  }
}
