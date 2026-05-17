import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_lens_effect/kinetic_lens_effect.dart';

/// Wraps [child] in the minimum scaffolding a test needs:
/// Directionality + MediaQuery + a concrete size.
Widget testHost(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(800, 600)),
      child: child,
    ),
  );
}

void main() {
  group('LensEffect', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        testHost(
          LensEffect(
            child: MaterialApp(
              home: const Scaffold(body: Text('Hello')),
            ),
          ),
        ),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('LensEffectScope provides controller', (tester) async {
      LensController? captured;

      await tester.pumpWidget(
        testHost(
          LensEffect(
            child: Builder(builder: (ctx) {
              captured = LensEffectScope.of(ctx);
              return const SizedBox();
            }),
          ),
        ),
      );

      expect(captured, isNotNull);
    });

    testWidgets('controller toggle changes isActive', (tester) async {
      final controller = LensController();
      addTearDown(controller.dispose);

      expect(controller.isActive, isTrue);
      controller.toggle();
      expect(controller.isActive, isFalse);
      controller.toggle();
      expect(controller.isActive, isTrue);
    });

    testWidgets('external controller is respected', (tester) async {
      final controller = LensController(
        options: const LensOptions(initiallyActive: false),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        testHost(
          LensEffect(
            controller: controller,
            child: const SizedBox(),
          ),
        ),
      );

      expect(controller.isActive, isFalse);
    });
  });

  group('LensOptions', () {
    test('copyWith overrides fields', () {
      const opts = LensOptions(lensRadius: 100);
      final updated = opts.copyWith(lensRadius: 200);
      expect(updated.lensRadius, 200);
      expect(updated.lensColor, opts.lensColor);
    });
  });
}
