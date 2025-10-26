import 'dart:math';
import 'package:flutter/material.dart';

/// Animated orbital rings that rotate around the moon
class OrbitalRings extends StatefulWidget {
  final bool isActive;
  final bool isInTune;

  const OrbitalRings({
    super.key,
    this.isActive = false,
    this.isInTune = false,
  });

  @override
  State<OrbitalRings> createState() => _OrbitalRingsState();
}

class _OrbitalRingsState extends State<OrbitalRings>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: OrbitalRingsPainter(
            rotation: _controller.value * 2 * pi,
            isActive: widget.isActive,
            isInTune: widget.isInTune,
          ),
          child: Container(),
        );
      },
    );
  }
}

class OrbitalRingsPainter extends CustomPainter {
  final double rotation;
  final bool isActive;
  final bool isInTune;

  OrbitalRingsPainter({
    required this.rotation,
    required this.isActive,
    required this.isInTune,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = min(size.width, size.height) / 2 - 20;

    if (!isActive) {
      // Draw subtle static rings when inactive
      final inactivePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.05)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      for (int i = 1; i <= 3; i++) {
        canvas.drawCircle(center, baseRadius * 0.5 * i, inactivePaint);
      }
      return;
    }

    // Active state - draw animated rings
    final ringColor = isInTune
        ? const Color(0xFF00FF88)
        : const Color(0xFF2196F3);

    // Ring 1 - Inner fast
    _drawAnimatedRing(
      canvas,
      center,
      baseRadius * 0.45,
      rotation,
      ringColor.withValues(alpha: 0.4),
      2.0,
    );

    // Ring 2 - Middle medium
    _drawAnimatedRing(
      canvas,
      center,
      baseRadius * 0.60,
      -rotation * 0.7,
      ringColor.withValues(alpha: 0.3),
      1.5,
    );

    // Ring 3 - Outer slow
    _drawAnimatedRing(
      canvas,
      center,
      baseRadius * 0.75,
      rotation * 0.5,
      ringColor.withValues(alpha: 0.2),
      1.0,
    );

    // Add orbital dots
    if (isInTune) {
      _drawOrbitalDots(canvas, center, baseRadius * 0.60, rotation * 2, ringColor);
    }
  }

  void _drawAnimatedRing(
    Canvas canvas,
    Offset center,
    double radius,
    double rotation,
    Color color,
    double strokeWidth,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw dashed ring effect
    const dashCount = 40;
    const dashLength = pi * 2 / dashCount;
    
    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        final startAngle = i * dashLength + rotation;
        final rect = Rect.fromCircle(center: center, radius: radius);
        canvas.drawArc(rect, startAngle, dashLength * 0.7, false, paint);
      }
    }
  }

  void _drawOrbitalDots(
    Canvas canvas,
    Offset center,
    double radius,
    double rotation,
    Color color,
  ) {
    const dotCount = 8;
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * 2 * pi + rotation;
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;
      final dotPosition = Offset(x, y);

      canvas.drawCircle(dotPosition, 4, glowPaint);
      canvas.drawCircle(dotPosition, 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(OrbitalRingsPainter oldDelegate) {
    return rotation != oldDelegate.rotation ||
        isActive != oldDelegate.isActive ||
        isInTune != oldDelegate.isInTune;
  }
}
