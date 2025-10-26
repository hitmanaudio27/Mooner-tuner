import 'package:flutter/material.dart';

/// Precise cents deviation meter with needle indicator
class CentsMeter extends StatefulWidget {
  final double? centsDeviation;
  final bool isInTune;

  const CentsMeter({
    super.key,
    this.centsDeviation,
    this.isInTune = false,
  });

  @override
  State<CentsMeter> createState() => _CentsMeterState();
}

class _CentsMeterState extends State<CentsMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _lockController;

  @override
  void initState() {
    super.initState();
    _lockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(CentsMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isInTune && !oldWidget.isInTune) {
      _lockController.forward();
    } else if (!widget.isInTune && oldWidget.isInTune) {
      _lockController.reverse();
    }
  }

  @override
  void dispose() {
    _lockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      height: 100,
      child: CustomPaint(
        painter: CentsMeterPainter(
          centsDeviation: widget.centsDeviation,
          isInTune: widget.isInTune,
          lockValue: _lockController.value,
        ),
      ),
    );
  }
}

class CentsMeterPainter extends CustomPainter {
  final double? centsDeviation;
  final bool isInTune;
  final double lockValue;

  CentsMeterPainter({
    required this.centsDeviation,
    required this.isInTune,
    required this.lockValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final meterWidth = size.width - 40;
    final meterHeight = 8.0;

    // Draw tick marks
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    for (int cents = -50; cents <= 50; cents += 10) {
      final x = center.dx + (cents / 50.0) * (meterWidth / 2);
      final tickHeight = cents == 0 ? 20.0 : (cents % 20 == 0 ? 15.0 : 10.0);
      
      canvas.drawLine(
        Offset(x, center.dy - meterHeight / 2 - 5),
        Offset(x, center.dy - meterHeight / 2 - 5 - tickHeight),
        tickPaint,
      );

      // Draw numbers
      if (cents % 20 == 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: cents.toString(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, center.dy - meterHeight / 2 - 35),
        );
      }
    }

    // Draw meter bar background
    final barRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: meterWidth,
        height: meterHeight,
      ),
      const Radius.circular(4),
    );

    final barPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1);
    canvas.drawRRect(barRect, barPaint);

    // Draw colored zones
    final leftZonePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFFFF5252).withValues(alpha: 0.3),
          const Color(0xFFFF9800).withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(center.dx - meterWidth / 4, center.dy),
        width: meterWidth / 2,
        height: meterHeight,
      ));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx - meterWidth / 4, center.dy),
          width: meterWidth / 2,
          height: meterHeight,
        ),
        const Radius.circular(4),
      ),
      leftZonePaint,
    );

    final rightZonePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          const Color(0xFFFF9800).withValues(alpha: 0.2),
          const Color(0xFFFF5252).withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(center.dx + meterWidth / 4, center.dy),
        width: meterWidth / 2,
        height: meterHeight,
      ));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + meterWidth / 4, center.dy),
          width: meterWidth / 2,
          height: meterHeight,
        ),
        const Radius.circular(4),
      ),
      rightZonePaint,
    );

    // Draw center zone (in-tune zone)
    final centerZonePaint = Paint()
      ..color = const Color(0xFF00FF88).withValues(alpha: 0.2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: meterWidth * 0.08, // ±2 cents zone
          height: meterHeight,
        ),
        const Radius.circular(4),
      ),
      centerZonePaint,
    );

    // Draw needle/indicator
    if (centsDeviation != null) {
      final clampedCents = centsDeviation!.clamp(-50.0, 50.0);
      final needleX = center.dx + (clampedCents / 50.0) * (meterWidth / 2);

      // Needle color based on tuning status
      Color needleColor;
      if (isInTune) {
        // Locked to center - bright green
        needleColor = Color.lerp(
          const Color(0xFF2196F3),
          const Color(0xFF00FF88),
          lockValue,
        )!;
      } else if (clampedCents.abs() > 25) {
        needleColor = const Color(0xFFFF5252);
      } else if (clampedCents.abs() > 10) {
        needleColor = const Color(0xFFFF9800);
      } else {
        needleColor = const Color(0xFF2196F3);
      }

      // Draw needle shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final needlePath = Path()
        ..moveTo(needleX, center.dy - meterHeight / 2 - 8)
        ..lineTo(needleX - 6, center.dy - meterHeight / 2 - 20)
        ..lineTo(needleX + 6, center.dy - meterHeight / 2 - 20)
        ..close();

      canvas.drawPath(needlePath, shadowPaint);

      // Draw needle
      final needlePaint = Paint()
        ..color = needleColor
        ..style = PaintingStyle.fill;

      canvas.drawPath(needlePath, needlePaint);

      // Draw needle glow when in tune
      if (isInTune && lockValue > 0.5) {
        final glowPaint = Paint()
          ..color = const Color(0xFF00FF88).withValues(alpha: lockValue * 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

        canvas.drawPath(needlePath, glowPaint);
      }

      // Draw needle line
      final linePaint = Paint()
        ..color = needleColor
        ..strokeWidth = 2;

      canvas.drawLine(
        Offset(needleX, center.dy - meterHeight / 2 - 8),
        Offset(needleX, center.dy + meterHeight / 2 + 8),
        linePaint,
      );
    }

    // Draw center marker
    final centerMarkerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(center.dx, center.dy - meterHeight / 2 - 5),
      Offset(center.dx, center.dy + meterHeight / 2 + 5),
      centerMarkerPaint,
    );
  }

  @override
  bool shouldRepaint(CentsMeterPainter oldDelegate) {
    return centsDeviation != oldDelegate.centsDeviation ||
        isInTune != oldDelegate.isInTune ||
        lockValue != oldDelegate.lockValue;
  }
}
