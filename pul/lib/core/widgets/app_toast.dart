import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A small floating pill that confirms an action.
///
/// The Material snack bar always spans the whole width of the screen, so a
/// short message looks heavy. This toast only takes the space it needs.
abstract final class AppToast {
  static OverlayEntry? _current;

  /// Shows the toast and replaces the one that is still on the screen.
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    _current?.remove();
    _current = null;

    final entry = OverlayEntry(
      builder: (context) => _AppToast(
        message: message,
        icon: icon,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
        onDismissed: () {
          _current?.remove();
          _current = null;
        },
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }
}

class _AppToast extends StatefulWidget {
  const _AppToast({
    required this.message,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<_AppToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..forward();
    _timer = Timer(widget.duration, _close);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    if (!mounted) return;
    _controller.reverse().whenComplete(() => widget.onDismissed());
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Positioned(
      left: 0,
      right: 0,
      bottom: media.padding.bottom + 88,
      child: Semantics(
        liveRegion: true,
        container: true,
        child: FadeTransition(
          opacity: _controller,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.35),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: Material(
              type: MaterialType.transparency,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: media.size.width - 32),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x2E17222C),
                          blurRadius: 22,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: Colors.white70, size: 18),
                          const SizedBox(width: 9),
                        ],
                        Flexible(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        if (widget.actionLabel != null) ...[
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              _close();
                              widget.onAction?.call();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              minimumSize: const Size(0, 34),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textStyle: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(widget.actionLabel!),
                          ),
                        ],
                      ],
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
}
