import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'lens_controller.dart';
import 'lens_options.dart';

// ---------------------------------------------------------------------------
// InheritedWidget — provides the controller down the tree
// ---------------------------------------------------------------------------

class LensEffectScope extends InheritedWidget {
  const LensEffectScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final LensController controller;

  static LensController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LensEffectScope>();
    assert(scope != null,
        'No LensEffect found. Wrap your widget tree with LensEffect.');
    return scope!.controller;
  }

  static LensController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LensEffectScope>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(LensEffectScope oldWidget) =>
      controller != oldWidget.controller;
}

// ---------------------------------------------------------------------------
// LensEffect — the main public widget
// ---------------------------------------------------------------------------

class LensEffect extends StatefulWidget {
  const LensEffect({
    super.key,
    required this.child,
    this.options = const LensOptions(),
    this.controller,
  });
  final Widget child;
  final LensOptions options;
  final LensController? controller;

  @override
  State<LensEffect> createState() => _LensEffectState();
}

class _LensEffectState extends State<LensEffect>
    with SingleTickerProviderStateMixin {
  late LensController _controller;
  late Ticker _ticker;
  bool _ownsController = false;

  // Key on the Stack so we can convert global -> local pointer coords.
  // This is what makes the effect accurate when LensEffect is NOT full-screen.
  final GlobalKey _canvasKey = GlobalKey();

  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = LensController(options: widget.options);
      _ownsController = true;
    }
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration _) {
    if (!mounted) return;
    if (_lastSize != Size.zero) {
      _controller.tick(_lastSize);
    }
  }

  @override
  void didUpdateWidget(LensEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_ownsController) _controller.dispose();
      if (widget.controller != null) {
        _controller = widget.controller!;
        _ownsController = false;
      } else {
        _controller = LensController(options: widget.options);
        _ownsController = true;
      }
    } else if (_ownsController && widget.options != oldWidget.options) {
      _controller.updateOptions(widget.options);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  // The core fix: convert the raw global pointer position into the local
  // coordinate space of the canvas widget. Without this, the effect origin
  // is always at (0,0) of the screen, not of the LensEffect widget — so
  // the cursor and effect drift apart whenever LensEffect is not full-screen.
  void _onPointerEvent(Offset globalPosition) {
    final RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final Offset local =
        box != null ? box.globalToLocal(globalPosition) : globalPosition;
    _controller.setPointerPosition(local);
  }

  @override
  Widget build(BuildContext context) {
    return LensEffectScope(
      controller: _controller,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerHover: (e) => _onPointerEvent(e.position),
        onPointerMove: (e) => _onPointerEvent(e.position),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            if (size != _lastSize) {
              _lastSize = size;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _controller.invalidateGrid();
              });
            }
            return Stack(
              key: _canvasKey,
              textDirection: TextDirection.ltr,
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: _LensCanvas(controller: _controller),
                  ),
                ),
                widget.child,
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _LensCanvas
// ---------------------------------------------------------------------------

class _LensCanvas extends StatelessWidget {
  const _LensCanvas({required this.controller});
  final LensController controller;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LensPainter(controller: controller),
      child: const SizedBox.expand(),
    );
  }
}

// ---------------------------------------------------------------------------
// _LensPainter
// ---------------------------------------------------------------------------

class _LensPainter extends CustomPainter {
  _LensPainter({required this.controller}) : super(repaint: controller);
  final LensController controller;

  static final Paint _paint = Paint()..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final opts = controller.options;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = opts.backgroundColor,
    );

    final Offset mouse = controller.smoothedPos;
    final bool active = controller.isActive;
    final double radiusSq = opts.lensRadius * opts.lensRadius;

    for (final dot in controller.dots) {
      final double dx = mouse.dx - dot.baseX;
      final double dy = mouse.dy - dot.baseY;
      final bool inRadius = active && (dx * dx + dy * dy) < radiusSq;

      final Color baseColor = inRadius ? opts.lensColor : opts.dotColor;
      _paint.color = baseColor.withValues(alpha: dot.intensity.clamp(0.0, 1.0));

      canvas.drawCircle(
        Offset(dot.x, dot.y),
        opts.dotRadius,
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(_LensPainter old) =>
      !identical(old.controller, controller);
}
