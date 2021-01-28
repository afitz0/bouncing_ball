import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';

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
      home: Center(child: RunAway()),
    );
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Container(
          height: widget.size,
          width: widget.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class RunAway extends StatefulWidget {
  @override
  _RunAwayState createState() => _RunAwayState();
}

class _RunAwayState extends State<RunAway> {
  double x, y;

  double _width;
  double _height;
  final double _ballSize = 50;
  final double _hoverThreshold = 75.0;
  final double _padding = 64.0;

  @override
  Widget build(BuildContext context) {
    // Center us if we're just starting. Need context for media query.
    if (x == null || y == null) {
      _width = MediaQuery.of(context).size.width - _padding * 2;
      _height = MediaQuery.of(context).size.height - _padding * 2;
      x = _width / 2;
      y = _height / 2;
    }

    return Padding(
      padding: EdgeInsets.all(_padding),
      child: MouseRegion(
        onHover: _runAwayMaybe,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(style: BorderStyle.solid),
                  color: Colors.transparent,
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              top: y - (_ballSize / 2),
              left: x - (_ballSize / 2),
              width: _ballSize,
              height: _ballSize,
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(_newRoute(Colors.blue)),
                child: FloatingBall(size: _ballSize, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _runAwayMaybe(PointerEvent e) {
    Offset diff = e.localPosition - Offset(x, y);
    if (diff.distance < _hoverThreshold) {
      setState(() {
        x = _calcNewCoor(x, diff.dx, _width);
        // will the ball floating up and down, substract another half-height of the ball for y
        y = _calcNewCoor(y, diff.dy, _height - (_ballSize / 2));
      });
    }
  }

  double _calcNewCoor(double val, double delta, double max) {
    val -= delta;
    val = math.max(val, (_ballSize / 2));
    val = math.min(val, max - (_ballSize / 2));
    return val;
  }

  Route _newRoute(Color floodColor) {
    double xAlign = ((x + _ballSize / 2) - _width / 2) / (_width / 2);
    double yAlign = ((y + _ballSize) - _height / 2) / (_height / 2);
    Alignment scaleAlign = Alignment(xAlign, yAlign);
    print(scaleAlign);

    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          Page2(color: floodColor),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(
            Tween(begin: 0.25, end: 1.0).chain(
              CurveTween(curve: Curves.easeInExpo),
            ),
          ),
          child: ScaleTransition(
            alignment: scaleAlign,
            scale: animation.drive(
              Tween(begin: 0.0, end: 1.0).chain(
                CurveTween(curve: Curves.easeOut),
              ),
            ),
            child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return ClipRRect(
                    child: child,
                    borderRadius:
                        BorderRadius.circular(90 * (1 - animation.value)),
                  );
                },
                child: child),
          ),
        );
      },
    );
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
          Align(
            alignment: Alignment.center,
            child: Image(image: AssetImage('assets/dash.png')),
          ),
        ],
      ),
    );
  }
}
