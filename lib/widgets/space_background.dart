import 'dart:math';
import 'package:flutter/material.dart';

/// Animated space background with stars and grid
class SpaceBackground extends StatefulWidget {
  const SpaceBackground({super.key});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Generate random stars with more variety
    for (int i = 0; i < 150; i++) {
      _stars.add(Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 0.5,
        opacity: _random.nextDouble() * 0.7 + 0.2,
        twinkleSpeed: _random.nextDouble() * 3 + 0.5,
      ));
    }
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
          painter: SpacePainter(
            stars: _stars,
            animationValue: _controller.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double twinkleSpeed;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.twinkleSpeed,
  });
}

class SpacePainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  SpacePainter({
    required this.stars,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw gradient background
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0A0E27),
          const Color(0xFF1A1F3A),
          const Color(0xFF0A0E27),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gradientPaint);
    
    // Draw animated holographic grid lines
    final gridPaint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    final gridOffset = animationValue * 60;
    
    // Horizontal lines with fade effect
    for (double y = -60; y < size.height + 60; y += 60) {
      final adjustedY = (y + gridOffset) % (size.height + 60);
      final opacity = (sin(adjustedY / size.height * pi) * 0.03 + 0.02).clamp(0.0, 0.05);
      gridPaint.color = const Color(0xFF2196F3).withValues(alpha: opacity);
      
      canvas.drawLine(
        Offset(0, adjustedY),
        Offset(size.width, adjustedY),
        gridPaint,
      );
    }
    
    // Vertical lines with fade effect
    for (double x = -60; x < size.width + 60; x += 60) {
      final adjustedX = (x + gridOffset * 0.5) % (size.width + 60);
      final opacity = (sin(adjustedX / size.width * pi) * 0.03 + 0.02).clamp(0.0, 0.05);
      gridPaint.color = const Color(0xFF2196F3).withValues(alpha: opacity);
      
      canvas.drawLine(
        Offset(adjustedX, 0),
        Offset(adjustedX, size.height),
        gridPaint,
      );
    }
    
    // Draw stars with twinkling effect
    final starPaint = Paint()
      ..style = PaintingStyle.fill;
    
    for (final star in stars) {
      final twinkle = sin(animationValue * pi * 2 * star.twinkleSpeed) * 0.3 + 0.7;
      final opacity = (star.opacity * twinkle).clamp(0.0, 1.0);
      
      starPaint.color = Colors.white.withValues(alpha: opacity);
      
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        starPaint,
      );
    }
    
    // Draw orbital rings (very subtle)
    final ringPaint = Paint()
      ..color = const Color(0xFF2196F3).withValues(alpha: 0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    final center = Offset(size.width / 2, size.height * 0.4);
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(
        center,
        100.0 * i,
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(SpacePainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}
