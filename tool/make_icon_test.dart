// Erzeugt assets/icon.png (1024x1024). Aufruf: flutter test tool/make_icon_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('icon', (tester) async {
    await tester.runAsync(() async {
      const s = 1024.0;
      final rec = ui.PictureRecorder();
      final c = Canvas(rec);

      // Hintergrund: abgerundetes Quadrat mit Farbverlauf.
      final bg = RRect.fromRectAndRadius(
          const Rect.fromLTWH(72, 72, s - 144, s - 144), const Radius.circular(210));
      c.drawRRect(
        bg,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7B8CFF), Color(0xFF4A3FD1)],
          ).createShader(bg.outerRect),
      );

      // Buchseite.
      final page = RRect.fromRectAndRadius(
          const Rect.fromLTWH(272, 232, 480, 560), const Radius.circular(36));
      c.drawShadow(Path()..addRRect(page), const Color(0x66000000), 18, true);
      c.drawRRect(page, Paint()..color = const Color(0xFFFFFDF7));

      // Textzeilen.
      final line = Paint()
        ..color = const Color(0xFFC9CCE8)
        ..strokeWidth = 26
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 4; i++) {
        final y = 470.0 + i * 76;
        c.drawLine(Offset(340, y), Offset(i == 3 ? 560 : 684, y), line);
      }

      // Lesezeichen.
      final ribbon = Path()
        ..moveTo(604, 232)
        ..lineTo(700, 232)
        ..lineTo(700, 390)
        ..lineTo(652, 350)
        ..lineTo(604, 390)
        ..close();
      c.drawPath(ribbon, Paint()..color = const Color(0xFFFF7A59));

      // Feder-Kringel als Titel.
      final swirl = Path()
        ..moveTo(340, 340)
        ..cubicTo(400, 270, 450, 400, 500, 330)
        ..cubicTo(530, 290, 550, 330, 560, 340);
      c.drawPath(
        swirl,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFF4A3FD1)
          ..strokeWidth = 26
          ..strokeCap = StrokeCap.round,
      );

      final img = await rec.endRecording().toImage(s.toInt(), s.toInt());
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      await File('assets/icon.png').writeAsBytes(data!.buffer.asUint8List());
    });
  });
}
