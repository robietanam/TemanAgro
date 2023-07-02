import 'package:flutter/material.dart';

class TargetPainter extends CustomPainter {
  const TargetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Offset sets each circle's center
    canvas.drawCircle(Offset(size.width / 2, 0), 400,
        Paint()..color = const Color(0xFF7972E6));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class TargetPainter2 extends CustomPainter {
  const TargetPainter2();

  @override
  void paint(Canvas canvas, Size size) {
    // Offset sets each circle's center
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width / 2, 0),
            width: size.width * 3 / 2,
            height: size.height / 2),
        Paint()..color = const Color(0xFF7972E6));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
