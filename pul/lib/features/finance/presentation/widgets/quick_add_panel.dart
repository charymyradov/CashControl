import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/transaction_category.dart';
import '../../domain/entities/transaction_icon_name.dart';
import '../../domain/entities/transaction_type.dart';
import 'category_quick_strip.dart';
import 'category_style.dart';
import 'surface_card.dart';

class QuickAddPanel extends StatefulWidget {
  const QuickAddPanel({super.key, required this.onQuickAdd});

  /// Called with the picked amount, category, and optional icon name.
  final void Function(
    double amount,
    TransactionCategory category,
    TransactionIconName? iconName,
  )
  onQuickAdd;

  /// The amounts offered by the round buttons.
  static const amounts = <double>[0.5, 1, 2, 5, 10, 15, 20, 50];

  @override
  State<QuickAddPanel> createState() => _QuickAddPanelState();
}

class _QuickAddPanelState extends State<QuickAddPanel> {
  double? _selectedAmount;
  TransactionCategory? _selectedCategory;
  TransactionIconName? _selectedIconName;

  @override
  Widget build(BuildContext context) {
    final selected = _selectedAmount;
    final category = _selectedCategory ?? TransactionCategory.food;
    final iconNames = category.iconNamesFor(TransactionType.expense);

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF43D79A), AppColors.greenDark],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Çalt goş',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              _SelectedAmountChip(amount: selected),
            ],
          ),
          const SizedBox(height: 10),
          // Two balanced rows of amount buttons.
          Row(
            children: [
              for (final amount in QuickAddPanel.amounts.take(4)) ...[
                Expanded(
                  child: _AmountButton(
                    amount: amount,
                    isSelected: selected == amount,
                    onTap: () => setState(() => _selectedAmount = amount),
                  ),
                ),
                if (amount != QuickAddPanel.amounts[3])
                  const SizedBox(width: 7),
              ],
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              for (final amount in QuickAddPanel.amounts.skip(4)) ...[
                Expanded(
                  child: _AmountButton(
                    amount: amount,
                    isSelected: selected == amount,
                    onTap: () => setState(() => _selectedAmount = amount),
                  ),
                ),
                if (amount != QuickAddPanel.amounts.last)
                  const SizedBox(width: 7),
              ],
            ],
          ),
          const SizedBox(height: 10),
          CategoryQuickStrip(
            categories: TransactionCategory.forType(TransactionType.expense),
            onSelected: (category) {
              setState(() {
                _selectedCategory = category;
                _selectedIconName = null;
              });
              if (_selectedAmount != null) {
                _add(context, category, null);
              }
            },
            selectedCategory: _selectedCategory,
          ),
          if (_selectedCategory != null && iconNames.isNotEmpty) ...[
            const SizedBox(height: 10),
            _IconNameQuickStrip(
              iconNames: iconNames,
              selectedIconName: _selectedIconName,
              onSelected: (iconName) =>
                  setState(() => _selectedIconName = iconName),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: selected == null
                  ? null
                  : () => _add(context, _selectedCategory!, _selectedIconName),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Goşmak',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _add(
    BuildContext context,
    TransactionCategory category,
    TransactionIconName? iconName,
  ) {
    final amount = _selectedAmount;
    if (amount == null) {
      AppToast.show(
        context,
        message: 'Ilki mukdary saýlaň',
        icon: Icons.info_outline_rounded,
      );
      return;
    }

    setState(() => _selectedAmount = null);
    widget.onQuickAdd(amount, category, iconName);
  }
}

/// Shows the picked amount, or a hint while no amount is picked.
class _SelectedAmountChip extends StatelessWidget {
  const _SelectedAmountChip({required this.amount});

  final double? amount;

  @override
  Widget build(BuildContext context) {
    final isPicked = amount != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: isPicked ? AppColors.greenSoft : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPicked ? const Color(0xFFCDEEDD) : Colors.transparent,
        ),
      ),
      child: Text(
        isPicked ? formatMoney(amount!) : 'Mukdary saýlaň',
        style: TextStyle(
          color: isPicked ? AppColors.greenDark : AppColors.textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AmountButton extends StatefulWidget {
  const _AmountButton({
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  final double amount;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_AmountButton> createState() => _AmountButtonState();
}

class _AmountButtonState extends State<_AmountButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : (isSelected ? 1.04 : 1),
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: SizedBox(
          height: 38,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? null : Colors.white,
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4FDFA6), AppColors.greenDark],
                    )
                  : null,
              border: Border.all(
                color: isSelected ? Colors.transparent : AppColors.line,
                width: 1.2,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: AppColors.green.withValues(alpha: 0.38),
                    blurRadius: 14,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  )
                else
                  BoxShadow(
                    color: const Color(0x1017222C),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    _label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _label {
    if (widget.amount == widget.amount.truncateToDouble()) {
      return widget.amount.toInt().toString();
    }
    return widget.amount.toStringAsFixed(1).replaceAll('.', ',');
  }
}

class _IconNameQuickStrip extends StatelessWidget {
  const _IconNameQuickStrip({
    required this.iconNames,
    required this.selectedIconName,
    required this.onSelected,
  });

  final List<TransactionIconName> iconNames;
  final TransactionIconName? selectedIconName;
  final ValueChanged<TransactionIconName> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: iconNames.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final iconName = iconNames[index];
          final isSelected = selectedIconName?.id == iconName.id;
          final color = iconName.category.color;
          return GestureDetector(
            onTap: () => onSelected(iconName),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 61,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 60,
                    height: 38,
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
                      iconName.icon,
                      color: isSelected ? color : const Color(0xFF7B8792),
                      size: 23,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    iconName.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? color : AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
