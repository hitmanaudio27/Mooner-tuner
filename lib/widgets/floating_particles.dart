import 'dart:math';
import 'package:flutter/material.dart';

/// Iridescent floating particles that move around the screen
class FloatingParticles extends StatefulWidget {
  final int particleCount;

  const FloatingParticles({
    super.key,
    this.particleCount = 40,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Generate particles
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 6 + 2,
        speedX: (_random.nextDouble() - 0.5) * 0.3,
        speedY: (_random.nextDouble() - 0.5) * 0.3,
        hue: _random.nextDouble() * 360,
        opacity: _random.nextDouble() * 0.6 + 0.3,
        pulseSpeed: _random.nextDouble() * 2 + 1,
        pulseOffset: _random.nextDouble() * pi * 2,
      ));
    }
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    
    _controller.addListener(() {
      setState(() {
        _updateParticles();
      });
    });
  }

  void _updateParticles() {
    for (var particle in _particles) {
      // Update position
      particle.x += particle.speedX * 0.003;
      particle.y += particle.speedY * 0.003;
      
      // Wrap around edges
      if (particle.x < -0.1) particle.x = 1.1;
      if (particle.x > 1.1) particle.x = -0.1;
      if (particle.y < -0.1) particle.y = 1.1;
      if (particle.y > 1.1) particle.y = -0.1;
      
      // Update color shimmer
      particle.hue = (particle.hue + 0.5) % 360;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(
        particles: _particles,
        animationValue: _controller.value,
      ),
      child: Container(),
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speedX;
  double speedY;
  double hue;
  double opacity;
  double pulseSpeed;
  double pulseOffset;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.hue,
    required this.opacity,
    required this.pulseSpeed,
    required this.pulseOffset,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Calculate pulsing size
      final pulse = sin(animationValue * pi * 2 * particle.pulseSpeed + particle.pulseOffset);
      final currentSize = particle.size * (0.8 + pulse * 0.2);
      
      // Calculate iridescent color
      final color = HSVColor.fromAHSV(
        particle.opacity,
        particle.hue,
        0.8,
        1.0,
      ).toColor();
      
      final position = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );
      
      // Draw outer glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: particle.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawCircle(position, currentSize * 2, glowPaint);
      
      // Draw main particle with gradient
      final gradientPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: particle.opacity),
            color.withValues(alpha: particle.opacity * 0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: position, radius: currentSize));
      
      canvas.drawCircle(position, currentSize, gradientPaint);
      
      // Draw bright center
      final centerPaint = Paint()
        ..color = Colors.white.withValues(alpha: particle.opacity * 0.8);
      
      canvas.drawCircle(position, currentSize * 0.3, centerPaint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
