part of 'settings_page.dart';

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
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

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
