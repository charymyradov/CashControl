part of 'add_transaction_page.dart';

extension on _AddTransactionPageState {
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
                    onTap: () => _updateState(() {
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
                  onTap: () => _updateState(() {
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
                  onTap: () => _updateState(() => _iconName = iconName),
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
}
