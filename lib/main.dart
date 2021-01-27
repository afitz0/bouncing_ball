import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RunAway(),
    );
  }
}

class RunAway extends StatefulWidget {
  @override
  _RunAwayState createState() => _RunAwayState();
}

class _RunAwayState extends State<RunAway> {
  double x, y;
  double maxX, maxY;

  final threshold = 75.0;

  @override
  Widget build(BuildContext context) {
    // Center us if we're just starting. Need context for media query.
    if (x == null || y == null) {
      var size = MediaQuery.of(context).size;
      x = size.width / 2;
      y = size.height / 2;

      maxX = size.width;
      maxY = size.height;
    }

    return MouseRegion(
      onHover: _runAwayMaybe,
      child: Stack(
        children: <Widget>[
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            top: (y - 25),
            left: (x - 25),
            child: FloatingBall(),
          ),
        ],
      ),
    );
  }

  void _runAwayMaybe(PointerEvent e) {
    Offset diff = e.position - Offset(x, y);
    if (diff.distance < threshold) {
      setState(() {
        x -= diff.dx;
        y -= diff.dy;

        // stop at the edges. Does not account for the size (or offset) of the ball.
        x = math.min(math.max(25, x), maxX - 25);
        y = math.min(math.max(25, y), maxY - 25);
      });
    }
  }
}

class FloatingBall extends StatefulWidget {
  @override
  _FloatingBallState createState() => _FloatingBallState();
}

class _FloatingBallState extends State<FloatingBall>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 0.5),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInSine,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          color: Colors.blue,
        ),
      ),
    );
  }
}
