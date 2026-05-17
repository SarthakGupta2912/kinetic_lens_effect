# kinetic_lens_effect

[![pub version](https://img.shields.io/pub/v/kinetic_lens_effect.svg)](https://pub.dev/packages/kinetic_lens_effect)
[![License: MIT](https://img.shields.io/badge/License-MIT-cyan.svg)](https://opensource.org/licenses/MIT)

A beautiful, zero-dependency Flutter package that adds an animated kinetic dot-grid lens effect to the background of your app. Move the cursor (or finger) and watch the dots react in real-time.

---

## Features

- ✅ **One-widget setup** — wrap with `LensEffect` and you're done
- ✅ **Fully customizable** — colors, lens radius, dot size, spacing, smoothing
- ✅ **Runtime control** — toggle / update options on the fly via `LensController`
- ✅ **External controller support** — bring your own controller
- ✅ **Zero dependencies** — pure Flutter, no third-party packages
- ✅ **Performant** — `RepaintBoundary` + `CustomPainter` keep the background isolated from your UI repaints

---

## Getting started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  kinetic_lens_effect: ^0.1.0
```

Then run:

```sh
flutter pub get
```

---

## Usage

### Minimal setup

```dart
import 'package:kinetic_lens_effect/kinetic_lens_effect.dart';

void main() {
  runApp(
    LensEffect(
      child: MaterialApp(home: MyHomePage()),
    ),
  );
}
```

That's it. Your whole app now has the kinetic lens background.

---

### Customization

```dart
LensEffect(
  options: LensOptions(
    backgroundColor: const Color(0xFF050505), // canvas color
    lensColor: Colors.purpleAccent,           // dot color inside the lens
    dotColor: Colors.white,                   // dot color outside the lens
    dotBaseOpacity: 0.07,                     // idle dot opacity
    lensRadius: 180,                          // lens radius in pixels
    lensForce: 40,                            // max push force on dots
    dotRadius: 1.5,                           // dot size
    dotSpacing: 40,                           // grid spacing (null = auto)
    cursorSmoothing: 0.08,                    // cursor lag (0 = instant)
  ),
  child: MaterialApp(home: MyHomePage()),
)
```

---

### Toggling the effect at runtime

Anywhere inside the `LensEffect` tree:

```dart
// Get the controller
final controller = LensEffectScope.of(context);

// Toggle on/off
controller.toggle();

// Or explicitly
controller.setActive(false);

// Update options (colors, radius, etc.)
controller.updateOptions(
  controller.options.copyWith(lensColor: Colors.orange),
);
```

---

### External controller

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _controller = LensController(
    options: LensOptions(lensColor: Colors.greenAccent),
  );

  @override
  void dispose() {
    _controller.dispose(); // ← you own it, you dispose it
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LensEffect(
      controller: _controller,
      child: MaterialApp(home: MyHomePage()),
    );
  }
}
```

---

## API reference

### `LensEffect`

| Parameter    | Type             | Default              | Description                                |
|--------------|------------------|----------------------|--------------------------------------------|
| `child`      | `Widget`         | required             | Widget rendered on top of the background   |
| `options`    | `LensOptions`    | `LensOptions()`      | Visual + behavior configuration            |
| `controller` | `LensController?`| `null` (auto-created)| Provide your own to control externally     |

### `LensOptions`

| Parameter               | Type     | Default               | Description                            |
|-------------------------|----------|-----------------------|----------------------------------------|
| `backgroundColor`       | `Color`  | `Color(0xFF050505)`   | Canvas/background fill color           |
| `lensColor`             | `Color`  | `Color(0xFF00E5FF)`   | Dot color inside lens radius           |
| `dotColor`              | `Color`  | `Colors.white`        | Dot color outside lens radius          |
| `dotBaseOpacity`        | `double` | `0.07`                | Idle dot opacity                       |
| `lensRadius`            | `double` | `220`                 | Lens effect radius in logical pixels   |
| `lensForce`             | `double` | `55`                  | Max displacement force on dots         |
| `dotRadius`             | `double` | `1.5`                 | Individual dot radius                  |
| `dotSpacing`            | `double?`| `null` (auto)         | Grid spacing; null = 4% of shortest side |
| `cursorSmoothing`       | `double` | `0.08`                | Cursor lerp factor (lower = laggier)   |
| `dotPositionSmoothing`  | `double` | `0.12`                | Dot position lerp factor               |
| `dotIntensitySmoothing` | `double` | `0.18`                | Dot opacity lerp factor                |
| `initiallyActive`       | `bool`   | `true`                | Whether the effect starts enabled      |

### `LensController`

| Method / Property            | Description                                |
|------------------------------|--------------------------------------------|
| `isActive`                   | Whether the lens is currently rendering    |
| `toggle()`                   | Enable ↔ Disable                           |
| `setActive(bool)`            | Explicitly enable or disable               |
| `updateOptions(LensOptions)` | Hot-swap options at runtime                |
| `setPointerPosition(Offset)` | Manually drive cursor (e.g. from tests)    |
| `options`                    | Current `LensOptions`                      |

### `LensEffectScope`

| Method                      | Description                                    |
|-----------------------------|------------------------------------------------|
| `LensEffectScope.of(ctx)`   | Get controller; throws if no `LensEffect` above |
| `LensEffectScope.maybeOf(ctx)` | Get controller or null                      |

---

## Platform support

| Platform | Support |
|----------|---------|
| Android  | ✅      |
| iOS      | ✅      |
| Web      | ✅      |
| macOS    | ✅      |
| Windows  | ✅      |
| Linux    | ✅      |

> On touch platforms pointer events come from `onPointerMove`, so the lens follows the finger while it's touching the screen.

---

## License

MIT — see [LICENSE](LICENSE).
