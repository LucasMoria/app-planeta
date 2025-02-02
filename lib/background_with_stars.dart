import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(StarAnimationApp());

class StarAnimationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StarryBackground(),
    );
  }
}

class StarryBackground extends StatefulWidget {
  @override
  _StarryBackgroundState createState() => _StarryBackgroundState();
}

class _StarryBackgroundState extends State<StarryBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final int numberOfStars = 100;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000428), Color(0xFF004e92)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Animated Stars
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: StarPainter(
                  random: _random,
                  animationValue: _controller.value,
                  numberOfStars: numberOfStars,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  final Random random;
  final double animationValue;
  final int numberOfStars;

  StarPainter({
    required this.random,
    required this.animationValue,
    required this.numberOfStars,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint starPaint = Paint()..color = Colors.white.withOpacity(0.8);

    for (int i = 0; i < numberOfStars; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;

      // Pulsating star radius
      double radius = 1.0 + sin(animationValue * 2 * pi * random.nextDouble()) * 1.5;
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
