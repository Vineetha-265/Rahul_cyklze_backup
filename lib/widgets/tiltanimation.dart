import 'package:flutter/material.dart';

class TiltAnimation extends StatefulWidget {
  final Widget child;

  const TiltAnimation({super.key, required this.child});

  @override
  State<TiltAnimation> createState() => _TiltAnimationState();
}

class _TiltAnimationState extends State<TiltAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _tilt;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _tilt = Tween<double>(
      begin: -0.08, // left tilt (radians)
      end: 0.08,    // right tilt
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tilt,
      child: widget.child,
      builder: (context, child) {
        return Transform.rotate(
          angle: _tilt.value,
          child: child,
        );
      },
    );
  }
}
