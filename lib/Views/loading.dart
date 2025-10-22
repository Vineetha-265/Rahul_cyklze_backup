
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

/// ElegantLoadingOverlay
/// - Reusable full-screen loading overlay with polished animations.
/// - Use LoadingOverlayController.show(context, ...) and .hide() to display it,
///   or embed ElegantLoadingOverlay() directly in your widget tree.
class ElegantLoadingOverlay extends StatefulWidget {
  final String message;
  final Color color;
  final double ringSize;
  final bool barrierDismissible;
  final bool showBouncingDots;
  final bool showShimmerText;
  final VoidCallback? onCancel;

  const ElegantLoadingOverlay({
    super.key,
    this.message = 'Please wait…',
    this.color = const Color(0xFF1D4D61),
    this.ringSize = 92,
    this.barrierDismissible = false,
    this.showBouncingDots = true,
    this.showShimmerText = true,
    this.onCancel,
  });

  @override
  _ElegantLoadingOverlayState createState() => _ElegantLoadingOverlayState();
}

class _ElegantLoadingOverlayState extends State<ElegantLoadingOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  late final AnimationController _dotsController;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    // Smooth continuous rotation for the ring
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Gentle scale pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.96,
      upperBound: 1.04,
    )..repeat(reverse: true);

    // Dots animation
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    // Shimmer gradient cycle
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _dotsController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Widget _buildBouncingDots(Color color) {
    // three dots with staggered vertical translation
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        final t = _dotsController.value;
        double offsetFor(int i) {
          final phase = (t + i * 0.18) % 1.0;
          // simple ease for up-down
          return sin(phase * pi * 2) * 6;
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Transform.translate(
              offset: Offset(0, -offsetFor(i)),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.95),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildShimmerText(String text, Color baseColor) {
    if (!widget.showShimmerText) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerOffset = _shimmerController.value;
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 - shimmerOffset * 2, 0),
              end: Alignment(1.0 - shimmerOffset * 2, 0),
              colors: [
                baseColor.withOpacity(0.85),
                Colors.white.withOpacity(0.95),
                baseColor.withOpacity(0.85),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color;

    return WillPopScope(
      // prevent back unless dismissible
      onWillPop: () async => widget.barrierDismissible,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.barrierDismissible ? widget.onCancel : null,
        child: Stack(
          children: [
            // translucent blurred backdrop
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withOpacity(0.28),
              ),
            ),

            // center card
            Center(
              child: ScaleTransition(
                scale: _pulseController,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // rotating ring + inner icon
                      RotationTransition(
                        turns:
                            Tween(begin: 0.0, end: 1.0).animate(_rotationController),
                        child: SizedBox(
                          width: widget.ringSize,
                          height: widget.ringSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                painter: _GradientRingPainter(baseColor),
                                size: Size(widget.ringSize, widget.ringSize),
                              ),
                              // subtle inner glowing dot
                              Container(
                                width: widget.ringSize * 0.43,
                                height: widget.ringSize * 0.43,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      baseColor.withOpacity(0.18),
                                      baseColor.withOpacity(0.05),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.recycling_outlined,
                                    color: baseColor,
                                    size: widget.ringSize * 0.22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    //   const SizedBox(height: 16),

                    //   // shimmer / plain text
                    //  // _buildShimmerText(widget.message, baseColor),

                    //   const SizedBox(height: 12),

                      // bouncing dots (secondary activity)
                      // if (widget.showBouncingDots)
                      //   _buildBouncingDots(baseColor),

                      // if (widget.onCancel != null)
                      //   Padding(
                      //     padding: const EdgeInsets.only(top: 12),
                      //     child: TextButton(
                      //       onPressed: widget.onCancel,
                      //       child: const Text('Cancel'),
                      //     ),
                      //   ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom gradient ring painter (smooth sweep gradient)
class _GradientRingPainter extends CustomPainter {
  final Color color;
  _GradientRingPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final thickness = size.width * 0.085; // proportional stroke width
    final radius = (size.width - thickness) / 2;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: radius);

    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * pi,
      colors: [
        color.withOpacity(0.98),
        color.withOpacity(0.6),
        color.withOpacity(0.2),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 0.78, 1.0],
      transform: const GradientRotation(pi / 6),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // draw arc slightly less than full so it looks like a spinner
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: radius),
      -pi / 6,
      2 * pi * 0.86,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// LoadingOverlayController: quick API to show/hide overlay via an OverlayEntry.
/// Use LoadingOverlayController.show(context, ...) and .hide().
class LoadingOverlayController {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    String message = 'Please wait…',
    Color color = const Color(0xFF1D4D61),
    bool barrierDismissible = false,
    bool showBouncingDots = true,
    bool showShimmerText = true,
    double ringSize = 92,
    VoidCallback? onCancel,
  }) {
    // if already showing, update nothing (or replace)
    if (_currentEntry != null) return;

    _currentEntry = OverlayEntry(
      builder: (ctx) => Material(
        type: MaterialType.transparency,
        child: ElegantLoadingOverlay(
          message: message,
          color: color,
          barrierDismissible: barrierDismissible,
          showBouncingDots: showBouncingDots,
          showShimmerText: showShimmerText,
          ringSize: ringSize,
          onCancel: () {
            // hide first, then call user callback
            hide();
            onCancel?.call();
          },
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_currentEntry!);
  }

  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }

  static bool get isShowing => _currentEntry != null;
}















// import 'package:flutter/material.dart';



// class CustomLoadingWidget extends StatelessWidget {
//   const CustomLoadingWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.8), // semi-transparent overlay
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               spreadRadius: 2,
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Animated CircularProgressIndicator
//             AnimatedContainer(
//               duration: const Duration(seconds: 1),
//               width: 80,
//               height: 80,
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Adjust color as needed
//                 strokeWidth: 6.0, // Thicker stroke width for a bolder look
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Please wait...',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:math';
// import 'dart:ui';
// import 'package:flutter/material.dart';

// class CustomLoadingWidget extends StatefulWidget {
//   const CustomLoadingWidget({super.key});

//   @override
//   State<CustomLoadingWidget> createState() => _CustomLoadingWidgetState();
// }

// class _CustomLoadingWidgetState extends State<CustomLoadingWidget>
//     with TickerProviderStateMixin {
//   late final AnimationController _rotationController;
//   late final AnimationController _pulseController;

//   @override
//   void initState() {
//     super.initState();

//     // Continuous rotation
//     _rotationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat();

//     // Gentle pulsing effect
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//       lowerBound: 0.95,
//       upperBound: 1.05,
//     )..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _rotationController.dispose();
//     _pulseController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {


//     return Stack(
//       children: [
//         // Subtle translucent overlay background
//         Container(color: Colors.black.withOpacity(0.3)),

//         Center(
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.85),
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 15,
//                       offset: const Offset(0, 6),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     ScaleTransition(
//                       scale: _pulseController,
//                       child: RotationTransition(
//                         turns: _rotationController,
//                         child: CustomPaint(
//                           painter: _GradientRingPainter(Color(0xFF1D4D61)),
//                           size: const Size(80, 80),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 25),
//                    const Text(
//                       "Please wait...",
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Color(0xFF1D4D61),
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Draws the gradient ring
// class _GradientRingPainter extends CustomPainter {
//   final Color color;
//   _GradientRingPainter(this.color);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Rect.fromLTWH(0, 0, size.width, size.height);
//     final gradient = SweepGradient(
//       startAngle: 0,
//       endAngle: 2 * pi,
//       colors: [
//         color.withOpacity(0.9),
//         color.withOpacity(0.5),
//         color.withOpacity(0.1),
//         Colors.transparent
//       ],
//       stops: const [0.0, 0.5, 0.8, 1.0],
//     );

//     final paint = Paint()
//       ..shader = gradient.createShader(rect)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 6
//       ..strokeCap = StrokeCap.round;

//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2 - 6;
//     canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 0,
//         2 * pi * 0.9, false, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

