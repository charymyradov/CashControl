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

part 'add_transaction_page_sections.dart';
part 'add_transaction_page_widgets.dart';

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
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Yzyna',
            icon: const Icon(Icons.arrow_back_rounded, size: 23),
            color: AppColors.ink,
          ),
          title: Text(
            _isEditing ? 'Amaly redaktirle' : 'Täze amal',
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                child: Tooltip(
                  message: 'Hasaplaýjy',
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
              ),
            ),
          ],
          centerTitle: false,
          titleSpacing: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
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

  /// Allows the section builders (in the part file) to trigger a rebuild.
  void _updateState(VoidCallback fn) => setState(fn);
}
