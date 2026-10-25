part of 'add_transaction_page.dart';

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
