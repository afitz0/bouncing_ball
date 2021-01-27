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

  final double _ballSize = 50;
  final double _hoverThreshold = 75.0;

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
            top: (y - (_ballSize / 2)),
            left: (x - (_ballSize / 2)),
            child: FloatingBall(size: _ballSize),
          ),
        ],
      ),
    );
  }

  void _runAwayMaybe(PointerEvent e) {
    Offset diff = e.position - Offset(x, y);
    if (diff.distance < _hoverThreshold) {
      setState(() {
        x = _calcNewCoor(x, diff.dx);
        y = _calcNewCoor(y, diff.dy);
      });
    }
  }

  double _calcNewCoor(double val, double delta) {
    val -= delta;
    val = math.max(val, (_ballSize / 2));
    val = math.min(val, maxX - (_ballSize / 2));
    return val;
  }
}

class FloatingBall extends StatefulWidget {
  final double size;
  final Color color;

  const FloatingBall({Key key, @required this.size, this.color = Colors.blue})
      : super(key: key);

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
        height: widget.size,
        width: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          color: widget.color,
        ),
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(_newRoute(widget.color)),
        ),
      ),
    );
  }

  Route _newRoute(Color floodColor) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          Page2(color: floodColor),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(
            Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeInExpo),
            ),
          ),
          child: ScaleTransition(
            scale: animation.drive(
              Tween(begin: 0.25, end: 1.0).chain(
                CurveTween(curve: Curves.easeOut),
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Offset _getOrigin() {
    final RenderBox renderBoxRed = context.findRenderObject();
    return renderBoxRed.localToGlobal(Offset.zero);
  }
}

class Page2 extends StatelessWidget {
  final Color color;

  const Page2({Key key, this.color}) : super(key: key);

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: color)),
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
