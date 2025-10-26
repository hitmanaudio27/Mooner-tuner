import 'dart:math';
import 'package:flutter/material.dart';

/// Moon-shaped tuning indicator that shows tuning status
/// Full moon = in tune
/// Waning crescent (left) = flat
/// Waxing crescent (right) = sharp
class MoonTuningIndicator extends StatefulWidget {
  final double? centsDeviation;
  final bool isInTune;

  const MoonTuningIndicator({
    super.key,
    this.centsDeviation,
    this.isInTune = false,
  });

  @override
  State<MoonTuningIndicator> createState() => _MoonTuningIndicatorState();
}

class _MoonTuningIndicatorState extends State<MoonTuningIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseValue = widget.isInTune ? _pulseController.value * 0.1 + 0.95 : 1.0;
        
        return Transform.scale(
          scale: pulseValue,
          child: SizedBox(
            width: 280,
            height: 280,
            child: CustomPaint(
              painter: MoonPainter(
                centsDeviation: widget.centsDeviation,
                isInTune: widget.isInTune,
              ),
            ),
          ),
        );
      },
    );
  }
}

class MoonPainter extends CustomPainter {
  final double? centsDeviation;
  final bool isInTune;

  MoonPainter({
    required this.centsDeviation,
    required this.isInTune,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    if (centsDeviation == null) {
      // No signal - draw empty circle
      final emptyPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      canvas.drawCircle(center, radius, emptyPaint);
      return;
    }

    // Calculate moon phase based on cents deviation
    // -50 cents (flat) = full crescent left
    // 0 cents (in tune) = full moon
    // +50 cents (sharp) = full crescent right
    final phase = (centsDeviation! / 50.0).clamp(-1.0, 1.0);

    // Outer glow
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    if (isInTune) {
      // In tune - bright green/white glow
      glowPaint.color = const Color(0xFF00FF88).withValues(alpha: 0.6);
    } else if (centsDeviation!.abs() > 25) {
      // Very out of tune - red/orange glow
      glowPaint.color = const Color(0xFFFF4444).withValues(alpha: 0.5);
    } else {
      // Slightly out of tune - blue glow
      glowPaint.color = const Color(0xFF2196F3).withValues(alpha: 0.5);
    }

    canvas.drawCircle(center, radius + 5, glowPaint);

    // Main moon body
    final moonPaint = Paint()
      ..style = PaintingStyle.fill;

    if (isInTune) {
      // Full moon - stable bright white
      moonPaint.shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF),
          const Color(0xFFE0E0E0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    } else {
      // Crescent moon - blue-white
      moonPaint.shader = RadialGradient(
        colors: [
          const Color(0xFFE3F2FD),
          const Color(0xFF90CAF9),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    }

    if (phase.abs() < 0.1) {
      // Nearly in tune - draw full circle
      canvas.drawCircle(center, radius, moonPaint);
    } else {
      // Draw crescent
      final path = Path();
      
      if (phase < 0) {
        // Flat - waning crescent on left side
        final crescentWidth = (1 - phase.abs()) * radius * 2;
        
        // Left side of moon
        path.addArc(
          Rect.fromCircle(center: center, radius: radius),
          pi / 2,
          pi,
        );
        
        // Curved inner edge
        final controlPoint = Offset(
          center.dx - radius + crescentWidth,
          center.dy,
        );
        
        path.quadraticBezierTo(
          controlPoint.dx,
          center.dy - radius * 0.7,
          center.dx,
          center.dy - radius,
        );
        
        path.quadraticBezierTo(
          controlPoint.dx,
          center.dy + radius * 0.7,
          center.dx,
          center.dy + radius,
        );
      } else {
        // Sharp - waxing crescent on right side
        final crescentWidth = (1 - phase.abs()) * radius * 2;
        
        // Right side of moon
        path.addArc(
          Rect.fromCircle(center: center, radius: radius),
          -pi / 2,
          pi,
        );
        
        // Curved inner edge
        final controlPoint = Offset(
          center.dx + radius - crescentWidth,
          center.dy,
        );
        
        path.quadraticBezierTo(
          controlPoint.dx,
          center.dy + radius * 0.7,
          center.dx,
          center.dy + radius,
        );
        
        path.quadraticBezierTo(
          controlPoint.dx,
          center.dy - radius * 0.7,
          center.dx,
          center.dy - radius,
        );
      }
      
      path.close();
      canvas.drawPath(path, moonPaint);
    }

    // Add subtle surface texture
    final texturePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Random craters
    final random = Random(42); // Fixed seed for consistent pattern
    for (int i = 0; i < 8; i++) {
      final angle = random.nextDouble() * pi * 2;
      final distance = random.nextDouble() * radius * 0.6;
      final craterCenter = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );
      final craterRadius = random.nextDouble() * 8 + 3;
      
      canvas.drawCircle(craterCenter, craterRadius, texturePaint);
    }

    // Outer ring (subtle)
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  bool shouldRepaint(MoonPainter oldDelegate) {
    return centsDeviation != oldDelegate.centsDeviation ||
        isInTune != oldDelegate.isInTune;
  }
}
