part of 'spending_overview_card.dart';

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({required this.entries, required this.progress});

  final List<_ChartEntry> entries;
  final double progress;

  static const _strokeWidth = 17.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) - _strokeWidth) / 2;

    final background = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..color = AppColors.surfaceMuted;
    canvas.drawCircle(center, radius, background);

    if (entries.isEmpty || progress <= 0) return;

    if (entries.length == 1) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = entries.first.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        paint,
      );
      return;
    }

    final gap = 0.055;
    var startAngle = -math.pi / 2;

    for (final entry in entries) {
      final fullSweep = entry.share * 2 * math.pi;
      final sweep = math.max(0.0, fullSweep - gap);
      if (sweep <= 0) {
        startAngle += fullSweep * progress;
        continue;
      }

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = entry.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + gap / 2,
        sweep * progress,
        false,
        paint,
      );
      startAngle += fullSweep * progress;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.entries != entries;
  }
}

class _EmptyDonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 16.0;
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AppColors.surfaceMuted;
    canvas.drawCircle(center, radius, paint);

    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = AppColors.greenSoft;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 0.7,
      false,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _EmptyDonutPainter oldDelegate) => false;
}
