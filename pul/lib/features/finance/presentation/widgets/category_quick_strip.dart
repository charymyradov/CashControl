import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/transaction_category.dart';
import 'category_style.dart';

class CategoryQuickStrip extends StatelessWidget {
  const CategoryQuickStrip({
    super.key,
    required this.categories,
    required this.onSelected,
    this.selectedCategory,
  });

  final List<TransactionCategory> categories;
  final ValueChanged<TransactionCategory> onSelected;
  final TransactionCategory? selectedCategory;

  @override
  Widget build(BuildContext context) {
    // Two balanced rows; every cell has the same width so the icons line up.
    final rowLength = (categories.length / 2).ceil();
    final rows = <List<TransactionCategory>>[
      for (var start = 0; start < categories.length; start += rowLength)
        categories.sublist(
          start,
          (start + rowLength).clamp(0, categories.length),
        ),
    ];

    return Column(
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (var cell = 0; cell < rowLength; cell++) ...[
                if (cell > 0) const SizedBox(width: 8),
                Expanded(
                  child: cell < rows[index].length
                      ? _CategoryShortcut(
                          category: rows[index][cell],
                          isSelected: rows[index][cell] == selectedCategory,
                          onTap: () => onSelected(rows[index][cell]),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _CategoryShortcut extends StatelessWidget {
  const _CategoryShortcut({
    required this.category,
    required this.onTap,
    this.isSelected = false,
  });

  final TransactionCategory category;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected ? category.strongSoftColor : category.softColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected
                      ? category.color.withValues(alpha: 0.45)
                      : category.color.withValues(alpha: 0.12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: category.color.withValues(alpha: 0.16),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(category.icon, color: category.color, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              category.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? category.color : const Color(0xFF626C75),
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

class EmptyTransactionsCard extends StatelessWidget {
  const EmptyTransactionsCard({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.greenSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.greenDark,
              size: 23,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Heniz amal ýok',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ilkinji girdeji ýa-da çykdajyňyzy goşuň.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onAdd,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.greenDark,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Amal goşmak'),
          ),
        ],
      ),
    );
  }
}
