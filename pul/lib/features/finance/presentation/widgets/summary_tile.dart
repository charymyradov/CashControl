import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// One compact income or expense tile that stands next to the balance card.
///
/// The tile is the same width as the balance card, so the value is scaled
/// down when the amount is too long to fit.
class SummaryTile extends StatelessWidget {
  const SummaryTile({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.background,
    required this.borderColor,
    required this.isHidden,
  });

  final String label;
  final String amount;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final Color background;
  final Color borderColor;
  final bool isHidden;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 8, 13, 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 14),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                isHidden ? '•••• tmt' : amount,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
