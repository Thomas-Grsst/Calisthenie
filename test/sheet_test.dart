// Planche de contrôle rendue (désactivée par défaut) :
// flutter test test/sheet_test.dart --update-goldens --dart-define=SHEET=true
// Écrit build/sheet_<n>.png pour les ids passés via --dart-define=IDS=a,b,c
import 'dart:io';

import 'package:chalk/poses/library.dart';
import 'package:chalk/widgets/pose_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('planche', (tester) async {
    const ids = String.fromEnvironment('IDS', defaultValue: 'pullup,tuckfl,fullfl,planchelean,vsit,oap');
    const slice = int.fromEnvironment('SLICE', defaultValue: -1);
    final list = slice >= 0 ? moves.skip(slice * 20).take(20).toList() : [for (final id in ids.split(',')) moveById[id]!];
    tester.view.physicalSize = const Size(1900, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: RepaintBoundary(
          key: const ValueKey('sheet'),
          child: Container(
            color: const Color(0xFF121212),
            padding: const EdgeInsets.all(8),
            child: Wrap(spacing: 6, runSpacing: 6, children: [
              for (final mv in list)
                for (var i = 0; i < mv.phases.length; i++)
                  SizedBox(width: const int.fromEnvironment('W', defaultValue: 190).toDouble(), child: PoseImage(move: mv, phase: i, color: const Color(0xFFC8F03C), radius: 6)),
            ]),
          ),
        ),
      ),
    ));
    await expectLater(find.byKey(const ValueKey('sheet')), matchesGoldenFile('../build/sheet.png'));
    stdout.writeln('ok');
  }, skip: !const bool.fromEnvironment('SHEET'));
}
