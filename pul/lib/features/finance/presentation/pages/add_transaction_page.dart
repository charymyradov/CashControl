import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/money_transaction.dart';
import '../../domain/entities/custom_transaction_category.dart';
import '../../domain/entities/transaction_category.dart';
import '../../domain/entities/transaction_icon_name.dart';
import '../../domain/entities/transaction_type.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../widgets/calculator_sheet.dart';
import '../widgets/category_style.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({
    super.key,
    this.transaction,
    this.initialCategory,
    this.initialType,
  });

  final MoneyTransaction? transaction;
  final TransactionCategory? initialCategory;
  final TransactionType? initialType;

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  late TransactionType _type;
  late TransactionCategory _category;
  CustomTransactionCategory? _customCategory;
  TransactionIconName? _iconName;
  late DateTime _date;
  late String _note;
  late String _amountRaw;

  bool _awaitingSave = false;
  String? _pendingSaveId;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _type = transaction?.type ?? widget.initialType ?? TransactionType.expense;
    _category =
        transaction?.category ??
        (widget.initialCategory?.isAvailableFor(_type) == true
            ? widget.initialCategory!
            : TransactionCategory.defaultFor(_type));
    if (transaction?.customCategoryId != null) {
      for (final category
          in context.read<FinanceBloc>().state.customCategories) {
        if (category.id == transaction!.customCategoryId) {
          _customCategory = category;
          break;
        }
      }
      _customCategory ??= CustomTransactionCategory(
        id: transaction!.customCategoryId!,
        label: transaction.customCategoryLabel ?? transaction.category.label,
        type: _type,
        colorValue: transaction.customCategoryColor ?? 0xFF607D8B,
        iconCodePoint:
            transaction.customCategoryIcon ??
            Icons.more_horiz_rounded.codePoint,
      );
    }
    if (transaction?.iconNameId != null) {
      _iconName = TransactionIconName.findById(transaction!.iconNameId!);
    }
    _date = transaction?.date ?? DateTime.now();
    _note = transaction?.note ?? '';
    _amountRaw = transaction == null
        ? ''
        : transaction.amount.toStringAsFixed(2).replaceAll('.', ',');
  }

  double get _amount {
    if (_amountRaw.trim().isEmpty) return 0;
    return double.tryParse(_amountRaw.replaceAll(',', '.')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FinanceBloc, FinanceState>(
      listenWhen: (previous, current) =>
          previous.isSaving != current.isSaving ||
          previous.lastSavedId != current.lastSavedId ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (_pendingSaveId == null) return;

        if (!state.isSaving && state.lastSavedId == _pendingSaveId) {
          Navigator.of(context).pop(true);
          return;
        }

        if (!state.isSaving && state.errorMessage != null) {
          setState(() {
            _awaitingSave = false;
            _pendingSaveId = null;
          });
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTypeSelector(),
                      const SizedBox(height: 14),
                      _buildAmount(),
                      const SizedBox(height: 12),
                      _buildKeypad(),
                      const SizedBox(height: 20),
                      _buildCategoryPicker(),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        text: formatDate(_date),
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.notes_rounded,
                        text: _note.isEmpty ? 'Bellik goş' : _note,
                        isPlaceholder: _note.isEmpty,
                        onTap: _editNote,
                      ),
                      const SizedBox(height: 18),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Yzyna',
            icon: const Icon(Icons.arrow_back_rounded, size: 23),
            color: AppColors.ink,
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              _isEditing ? 'Amaly redaktirle' : 'Täze amal',
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: _openCalculator,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Icon(
                  Icons.calculate_outlined,
                  color: AppColors.inkSoft,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _TypeButton(
            label: 'Çykdajy',
            icon: Icons.arrow_downward_rounded,
            isSelected: _type == TransactionType.expense,
            selectedBackground: const Color(0xFFFDDFDA),
            selectedForeground: AppColors.coralDark,
            onTap: () => _setType(TransactionType.expense),
          ),
          _TypeButton(
            label: 'Girdeji',
            icon: Icons.arrow_upward_rounded,
            isSelected: _type == TransactionType.income,
            selectedBackground: const Color(0xFFDDF5E9),
            selectedForeground: AppColors.greenDark,
            onTap: () => _setType(TransactionType.income),
          ),
        ],
      ),
    );
  }

  Widget _buildAmount() {
    return Column(
      children: [
        SizedBox(
          height: 58,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _formatAmountEntry(_amountRaw),
                    style: TextStyle(
                      color: _amountRaw.isEmpty
                          ? AppColors.textTertiary
                          : AppColors.ink,
                      fontSize: 43,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.8,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'TMT',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const _BlinkingCursor(),
                ],
              ),
            ),
          ),
        ),
        Text(
          _amountRaw.isEmpty ? 'Tutary gir' : 'Mukdar',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildKeypad() {
    const numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
    final keys = <_KeypadAction>[
      ...numbers.map(
        (item) => _KeypadAction(label: item, onTap: () => _appendAmount(item)),
      ),
      _KeypadAction(label: ',', onTap: () => _appendAmount(',')),
      _KeypadAction(label: '0', onTap: () => _appendAmount('0')),
      _KeypadAction(
        label: '⌫',
        icon: Icons.backspace_outlined,
        onTap: _backspaceAmount,
      ),
    ];

    return SizedBox(
      height: 248,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                for (var row = 0; row < 4; row++) ...[
                  if (row > 0) const SizedBox(height: 8),
                  Expanded(
                    child: Row(
                      children: [
                        for (var column = 0; column < 3; column++) ...[
                          if (column > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _KeypadButton(
                              key: ValueKey(
                                'keypad-${keys[row * 3 + column].label}',
                              ),
                              action: keys[row * 3 + column],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 101,
            child: Column(
              children: [
                // ÜSTTEKİ "Hasapla" BUTONU
                Expanded(
                  flex: 3, // İsterseniz bu oranı değiştirebilirsiniz (örneğin flex: 2 yaparsanız daha kısa olur)
                  child: Material(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(15),
                    clipBehavior:
                        Clip.antiAlias, // KÖŞELERİN KIRPILMASI İÇİN ŞART
                    child: InkWell(
                      onTap: _openCalculator,
                      // InkWell'a borderRadius vermeye gerek yok, Material zaten kırpıyor
                      child: const Center(
                        // Center ile içeriği tam ortalarız
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calculate_outlined,
                              color: AppColors.textSecondary,
                              size: 22,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Hasapla',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ALTTKİ YEŞİL OK BUTONU (Aynı kalabilir)
                Expanded(
                  flex: 2,
                  child: Material(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(15),
                    clipBehavior: Clip.antiAlias, // Bunu yeşil butona da eklemek iyi bir pratiktir
                    child: InkWell(
                      onTap: _awaitingSave ? null : _submit,
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPicker() {
    final categories = TransactionCategory.forType(_type);
    final customCategories = context
        .watch<FinanceBloc>()
        .state
        .customCategories
        .where((item) => item.type == _type)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategoriýa',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: categories.length + customCategories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 9),
            itemBuilder: (context, index) {
              if (index >= categories.length) {
                final category = customCategories[index - categories.length];
                return _CustomCategoryChoice(
                  key: ValueKey('custom-category-${category.id}'),
                  category: category,
                  isSelected: category.id == _customCategory?.id,
                  onTap: () => setState(() {
                    _customCategory = category;
                    _category = TransactionCategory.other;
                    _iconName = null;
                  }),
                );
              }
              final category = categories[index];
              return _CategoryChoice(
                key: ValueKey('category-${category.name}'),
                category: category,
                isSelected: category == _category,
                onTap: () => setState(() {
                  _category = category;
                  _customCategory = null;
                  _iconName = null;
                }),
              );
            },
          ),
        ),
        _buildIconNamePicker(),
      ],
    );
  }

  Widget _buildIconNamePicker() {
    final iconNames = _category.iconNamesFor(_type);
    if (iconNames.isEmpty) return const SizedBox.shrink();

    final hasCustomCategory = _customCategory != null;
    final showIconNames = !hasCustomCategory;

    if (!showIconNames) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Tür / Detay',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: iconNames.length,
            separatorBuilder: (_, _) => const SizedBox(width: 9),
            itemBuilder: (context, index) {
              final iconName = iconNames[index];
              final isSelected = _iconName?.id == iconName.id;
              return _IconNameChoice(
                key: ValueKey('icon-name-${iconName.id}'),
                iconName: iconName,
                isSelected: isSelected,
                onTap: () => setState(() => _iconName = iconName),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return FilledButton(
      onPressed: _awaitingSave ? null : _submit,
      child: _awaitingSave
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            )
          : Text(_isEditing ? 'Üýtgeşmäni sakla' : 'Amaly ýatda sakla'),
    );
  }

  void _setType(TransactionType type) {
    if (_type == type) return;
    setState(() {
      _type = type;
      if (_customCategory?.type != type) _customCategory = null;
      if (!_category.isAvailableFor(type)) {
        _category = TransactionCategory.defaultFor(type);
      }
      _iconName = null;
    });
  }

  void _appendAmount(String value) {
    setState(() {
      if (value == ',') {
        if (_amountRaw.contains(',')) return;
        if (_amountRaw.isEmpty) _amountRaw = '0';
        _amountRaw += ',';
        return;
      }

      final digitsOnly = _amountRaw.replaceAll(',', '');
      if (digitsOnly.length >= 9) return;

      final decimalIndex = _amountRaw.indexOf(',');
      if (decimalIndex != -1 && _amountRaw.length - decimalIndex - 1 >= 2) {
        return;
      }

      if (_amountRaw == '0') {
        _amountRaw = value;
      } else {
        _amountRaw += value;
      }
    });
  }

  void _backspaceAmount() {
    if (_amountRaw.isEmpty) return;
    setState(() {
      _amountRaw = _amountRaw.substring(0, _amountRaw.length - 1);
    });
  }

  String _formatAmountEntry(String raw) {
    if (raw.isEmpty) return '0,00';
    final parts = raw.split(',');
    final wholeDigits = parts.first.isEmpty ? '0' : parts.first;
    final grouped = wholeDigits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    if (parts.length == 1) return '$grouped,00';
    return '$grouped,${parts[1]}';
  }

  Future<void> _openCalculator() async {
    HapticFeedback.selectionClick();
    final result = await showAmountCalculator(context, initialValue: _amount);
    if (result == null || !mounted) return;

    setState(() {
      _amountRaw = result <= 0
          ? ''
          : result.toStringAsFixed(2).replaceAll('.', ',');
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 5, 12, 31),
      helpText: 'Senäni saýla',
      cancelText: 'Ýatyr',
      confirmText: 'Saýla',
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
  }

  Future<void> _editNote() async {
    final controller = TextEditingController(text: _note);
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lineStrong,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Bellik',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 80,
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.done,
                onSubmitted: (value) =>
                    Navigator.of(sheetContext).pop(value.trim()),
                style: const TextStyle(fontSize: 14.5),
                decoration: InputDecoration(
                  hintText: 'Mysal: Azyk önümleri',
                  hintStyle: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceMuted,
                  counterText: '',
                  contentPadding: const EdgeInsets.all(15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: AppColors.green,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () =>
                    Navigator.of(sheetContext).pop(controller.text.trim()),
                child: const Text(' Ýazmak'),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();

    if (!mounted) return;
    if (note != null) {
      setState(() => _note = note);
    }
  }

  void _submit() {
    if (_awaitingSave) return;
    FocusScope.of(context).unfocus();

    if (_amount <= 0) {
      _showMessage('Mukdary giriziň.');
      return;
    }

    final id =
        widget.transaction?.id ??
        DateTime.now().microsecondsSinceEpoch.toString();

    final transaction = MoneyTransaction(
      id: id,
      type: _type,
      amount: _amount,
      category: _category,
      date: _date,
      note: _note.trim(),
      customCategoryId: _customCategory?.id,
      customCategoryLabel: _customCategory?.label,
      customCategoryColor: _customCategory?.colorValue,
      customCategoryIcon: _customCategory?.iconCodePoint,
      iconNameId: _iconName?.id,
      iconNameLabel: _iconName?.label,
      iconNameIcon: _iconName?.icon.codePoint,
    );

    setState(() {
      _awaitingSave = true;
      _pendingSaveId = id;
    });

    context.read<FinanceBloc>().add(TransactionSaved(transaction));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedBackground,
    required this.selectedForeground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color selectedBackground;
  final Color selectedForeground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        // AnimatedContainer yerine AnimatedContainer + ClipRRect kullanıyoruz
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? selectedBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(
              12,
            ), // İç butonların köşe yuvarlaklığı
          ),
          // İçeriğin (Icon ve Text) her zaman ortada ve tam ortalanmış olmasını sağlar
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize
                  .min, // Row'un sadece içeriği kadar yer kaplamasını sağlar
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? selectedForeground
                      : const Color(0xFF7C858D),
                ),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? selectedForeground
                        : const Color(0xFF7C858D),
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KeypadAction {
  const _KeypadAction({required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({super.key, required this.action});

  final _KeypadAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(15),
        child: Center(
          child: action.icon == null
              ? Text(
                  action.label,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.3,
                  ),
                )
              : Icon(action.icon, color: AppColors.inkSoft, size: 21),
        ),
      ),
    );
  }
}

class _CategoryChoice extends StatelessWidget {
  const _CategoryChoice({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final TransactionCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 61,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 60,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? category.softColor : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? category.color.withValues(alpha: 0.45)
                      : Colors.transparent,
                  width: 1.2,
                ),
              ),
              child: Icon(
                category.icon,
                color: isSelected ? category.color : const Color(0xFF7B8792),
                size: 23,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? category.color : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomCategoryChoice extends StatelessWidget {
  const _CustomCategoryChoice({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final CustomTransactionCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 61,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 60,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.13)
                    : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? color.withValues(alpha: 0.45)
                      : Colors.transparent,
                  width: 1.2,
                ),
              ),
              child: Icon(
                customCategoryIcon(category.iconCodePoint),
                color: isSelected ? color : const Color(0xFF7B8792),
                size: 23,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconNameChoice extends StatelessWidget {
  const _IconNameChoice({
    super.key,
    required this.iconName,
    required this.isSelected,
    required this.onTap,
  });

  final TransactionIconName iconName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = iconName.category.color;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 61,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 60,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.13) : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? color.withValues(alpha: 0.45)
                      : Colors.transparent,
                  width: 1.2,
                ),
              ),
              child: Icon(
                iconName.icon,
                color: isSelected ? color : const Color(0xFF7B8792),
                size: 23,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              iconName.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    required this.onTap,
    this.isPlaceholder = false,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isPlaceholder
                        ? AppColors.textSecondary
                        : AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.15,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: 2,
        height: 33,
        margin: const EdgeInsets.only(left: 1, bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
