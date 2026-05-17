import 'package:flutter/material.dart';

/// Configuration for the [LensEffect] background.
///
/// All parameters are optional — the defaults produce the classic cyan
/// kinetic-lens look shown in the README.
class LensOptions {
  const LensOptions({
    this.backgroundColor = const Color(0xFF050505),
    this.lensColor = const Color(0xFF00E5FF),
    this.dotColor = Colors.white,
    this.dotBaseOpacity = 0.07,
    this.lensRadius = 220,
    this.lensForce = 55,
    this.dotRadius = 1.5,
    this.dotSpacing,
    this.cursorSmoothing = 0.08,
    this.dotPositionSmoothing = 0.12,
    this.dotIntensitySmoothing = 0.18,
    this.initiallyActive = true,
  });

  /// Background color of the canvas. Defaults to near-black.
  final Color backgroundColor;

  /// Color of dots inside the lens radius. Defaults to cyan [Color(0xFF00E5FF)].
  final Color lensColor;

  /// Color of dots outside the lens radius. Defaults to white.
  final Color dotColor;

  /// Base opacity of dots outside the lens. Range 0–1. Defaults to 0.07.
  final double dotBaseOpacity;

  /// Radius (in logical pixels) of the lens effect area. Defaults to 220.
  final double lensRadius;

  /// Max displacement force applied to dots inside the lens. Defaults to 55.
  final double lensForce;

  /// Dot radius in logical pixels. Defaults to 1.5.
  final double dotRadius;

  /// Grid spacing between dots. Defaults to automatic (4% of shortest side,
  /// clamped to 28–70 px). Set explicitly to override.
  final double? dotSpacing;

  /// Smoothing factor for cursor interpolation. Lower = smoother/slower (0–1).
  /// Defaults to 0.08.
  final double cursorSmoothing;

  /// Smoothing factor for dot position interpolation. Defaults to 0.12.
  final double dotPositionSmoothing;

  /// Smoothing factor for dot intensity interpolation. Defaults to 0.18.
  final double dotIntensitySmoothing;

  /// Whether the lens effect starts active. Defaults to true.
  final bool initiallyActive;

  /// Creates a copy with the given fields replaced.
  LensOptions copyWith({
    Color? backgroundColor,
    Color? lensColor,
    Color? dotColor,
    double? dotBaseOpacity,
    double? lensRadius,
    double? lensForce,
    double? dotRadius,
    double? dotSpacing,
    double? cursorSmoothing,
    double? dotPositionSmoothing,
    double? dotIntensitySmoothing,
    bool? initiallyActive,
  }) {
    return LensOptions(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      lensColor: lensColor ?? this.lensColor,
      dotColor: dotColor ?? this.dotColor,
      dotBaseOpacity: dotBaseOpacity ?? this.dotBaseOpacity,
      lensRadius: lensRadius ?? this.lensRadius,
      lensForce: lensForce ?? this.lensForce,
      dotRadius: dotRadius ?? this.dotRadius,
      dotSpacing: dotSpacing ?? this.dotSpacing,
      cursorSmoothing: cursorSmoothing ?? this.cursorSmoothing,
      dotPositionSmoothing: dotPositionSmoothing ?? this.dotPositionSmoothing,
      dotIntensitySmoothing:
          dotIntensitySmoothing ?? this.dotIntensitySmoothing,
      initiallyActive: initiallyActive ?? this.initiallyActive,
    );
  }
}
