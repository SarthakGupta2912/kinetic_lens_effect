/// A kinetic dot-grid lens effect background for Flutter apps.
///
/// Wrap your app (or any widget subtree) with [LensEffect] and a reactive
/// dot-grid background will appear behind your content, responding to pointer
/// movement in real-time.
///
/// ```dart
/// void main() {
///   runApp(
///     LensEffect(
///       child: MaterialApp(home: MyHomePage()),
///     ),
///   );
/// }
/// ```
library;

export 'src/lens_effect.dart';
export 'src/lens_controller.dart';
export 'src/lens_options.dart';
