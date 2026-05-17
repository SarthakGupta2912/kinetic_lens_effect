import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'lens_options.dart';

/// Internal representation of a single dot in the grid.
class LensDot {
  LensDot({
    required this.baseX,
    required this.baseY,
    required this.x,
    required this.y,
    this.intensity = 0.03,
  });
  final double baseX;
  final double baseY;
  double x;
  double y;
  double intensity;
}

/// Controls the lens animation state.
///
/// You can obtain the controller from a [LensEffectScope] to programmatically
/// toggle the effect, change options, or move the cursor from code:
///
/// ```dart
/// final controller = LensEffectScope.of(context);
/// controller.setActive(false); // turn off the effect
/// ```
class LensController extends ChangeNotifier {
  LensController({LensOptions options = const LensOptions()})
      : _options = options,
        _isActive = options.initiallyActive;
  LensOptions _options;

  // ── Public state ──────────────────────────────────────────────────────────

  LensOptions get options => _options;

  bool _isActive;

  /// Whether the lens effect is currently rendering.
  bool get isActive => _isActive;

  // ── Internal animation state ──────────────────────────────────────────────

  Offset _smoothedPos = const Offset(-2000, -2000);
  Offset _targetPos = const Offset(-2000, -2000);

  List<LensDot> dots = [];
  bool _gridInitialized = false;
  Size _lastGridSize = Size.zero;

  Offset get smoothedPos => _smoothedPos;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Enable or disable the lens effect at runtime.
  void setActive(bool value) {
    if (_isActive == value) return;
    _isActive = value;
    notifyListeners();
  }

  /// Toggle the lens effect.
  void toggle() => setActive(!_isActive);

  /// Update options at runtime (e.g., change colors or radius).
  void updateOptions(LensOptions newOptions) {
    _options = newOptions;
    // Grid spacing may have changed — rebuild the grid on next tick.
    _gridInitialized = false;
    dots.clear();
    notifyListeners();
  }

  /// Report the current pointer position (in global coordinates).
  void setPointerPosition(Offset pos) {
    _targetPos = pos;
  }

  // ── Internal tick (called every frame by the Ticker) ─────────────────────

  void tick(Size size) {
    _ensureGrid(size);
    _interpolateCursor();
    _updateDots();
    notifyListeners();
  }

  // ── Grid management ───────────────────────────────────────────────────────

  void _ensureGrid(Size size) {
    if (_gridInitialized && size == _lastGridSize) return;
    _gridInitialized = true;
    _lastGridSize = size;
    _buildGrid(size);
  }

  void _buildGrid(Size size) {
    dots.clear();
    final double spacing =
        _options.dotSpacing ?? (size.shortestSide * 0.04).clamp(28.0, 70.0);
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        dots.add(LensDot(baseX: x, baseY: y, x: x, y: y));
      }
    }
  }

  void invalidateGrid() {
    _gridInitialized = false;
    dots.clear();
  }

  // ── Per-frame updates ─────────────────────────────────────────────────────

  void _interpolateCursor() {
    final dx = _targetPos.dx - _smoothedPos.dx;
    final dy = _targetPos.dy - _smoothedPos.dy;
    final k = _options.cursorSmoothing;
    _smoothedPos = Offset(_smoothedPos.dx + dx * k, _smoothedPos.dy + dy * k);
  }

  void _updateDots() {
    final double radius = _options.lensRadius;
    final double radiusSq = radius * radius;
    final double force = _options.lensForce;
    final double baseOpacity = _options.dotBaseOpacity;
    final double pk = _options.dotPositionSmoothing;
    final double ik = _options.dotIntensitySmoothing;

    for (final dot in dots) {
      final double dx = _smoothedPos.dx - dot.baseX;
      final double dy = _smoothedPos.dy - dot.baseY;
      final double distSq = dx * dx + dy * dy;

      double targetX = dot.baseX;
      double targetY = dot.baseY;
      double targetIntensity;

      if (_isActive && distSq < radiusSq && distSq > 0) {
        final double dist = math.sqrt(distSq);
        final double t = (radius - dist) / radius;
        final double f = t * t * t;
        targetX -= (dx / dist) * f * force;
        targetY -= (dy / dist) * f * force;
        targetIntensity = 0.12 + f * 0.88;
      } else {
        targetIntensity = _isActive ? baseOpacity : 0.03;
      }

      dot.x += (targetX - dot.x) * pk;
      dot.y += (targetY - dot.y) * pk;
      dot.intensity += (targetIntensity - dot.intensity) * ik;
    }
  }
}
