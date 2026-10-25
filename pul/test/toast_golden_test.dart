import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pul/core/widgets/app_toast.dart';

void main() {
  testWidgets('toast golden', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () {
                    AppToast.show(
                      context,
                      message: 'Işgi • 1 200,00 TMT goşuldy',
                      icon: Icons.check_circle_rounded,
                      actionLabel: 'Redaktirle',
                    );
                  },
                  child: const Text('show'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('show'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('toast_golden.png'),
    );
  });
}
