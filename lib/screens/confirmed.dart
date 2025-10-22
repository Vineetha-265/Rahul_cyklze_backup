import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:cyklze/screens/help_page.dart';
import 'package:cyklze/screens/home_page.dart';
import 'package:cyklze/screens/pickup_history.dart';
import 'package:flutter/material.dart';


class PickupConfirmedPage extends StatefulWidget {
  const PickupConfirmedPage({super.key});

  @override
  State<PickupConfirmedPage> createState() => _PickupConfirmedPageState();
}

class _PickupConfirmedPageState extends State<PickupConfirmedPage>
    with TickerProviderStateMixin {
  late final AnimationController _tickController;
  late final Animation<double> _tickScale;
  late final Animation<double> _tickRotate;

  late final AnimationController _pulseController;

  late final AnimationController _sheetController;
  late final Animation<Offset> _sheetOffset;

  late final ConfettiController _confettiController;
  final int _secondsRemaining = 10;
  late Timer _timer;
  @override
  void initState() {
    super.initState();

    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _tickScale = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _tickController, curve: Curves.elasticOut),
    );
    _tickRotate = Tween<double>(begin: -0.25, end: 0.0).animate(
      CurvedAnimation(parent: _tickController, curve: Curves.elasticOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _sheetOffset = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _sheetController, curve: Curves.easeOut));

    // confetti
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    _tickController.forward();
    _confettiController.play();
// _startCountdown();
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _sheetController.forward();
    });
  }

  @override
  void dispose() {
    _tickController.dispose();
    _pulseController.dispose();
    _sheetController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

Widget _optionTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.white,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Semantics(
        label: 'Option Tile for $title', 
        button: true,  
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Semantics(
                label: 'Icon for $title',  
                child: CircleAvatar(
                  backgroundColor: color,
                  radius: 22,
                  child: Icon(icon, size: 20, color: Colors.white),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      label: 'Title: $title',
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: color),
                      ),
                    ),
                    const SizedBox(height: 4),
                  Semantics(
  label: 'Subtitle: $subtitle',
  child: Text(
    subtitle,
    style: const TextStyle(
      fontSize: 13,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  ),
),

                  ],
                ),
              ),
              Semantics(
                label: 'Go to the next screen',
                child: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black26),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
  void _navigateToHome(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating back to home...'),
        duration: Duration(seconds: 1),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    });
  }

  @override
Widget build(BuildContext context) {
  const Color primary = Color(0xFF1D4D61);
  const Color accent = Color(0xFF1D4D61);

  return PopScope(
      canPop: false, 
       onPopInvokedWithResult: (bool didPop, void result) {
    if (!didPop) {
      _navigateToHome(context);
    }
  },
    child: Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(builder: (context, constraints) {
        final double maxW = constraints.maxWidth;
        final double maxH = constraints.maxHeight;
        final double badgeSize = min(160, min(maxW * 0.45, maxH * 0.28));
        final double rippleBase = badgeSize * 1.1;
    
    
        return Stack(
          children: [
          
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary.withOpacity(0.15), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
    
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Semantics(
                      header: true,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         
                          Text(
                            'Pickup Confirmed',
                            style: TextStyle(
                              fontSize: maxW < 360 ? 16 : 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                         
                        ],
                      ),
                    ),
    
                    const SizedBox(height: 18),
                    SizedBox(
                      height: rippleBase * 2.4,
                      width: rippleBase * 2.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                   
                          Semantics(
                            label: 'Confetti animation to celebrate pickup confirmation',
                            child: Stack(
                              alignment: Alignment.center,
                              children: List.generate(20, (index) {
                                final icons = [
                                  Icons.local_drink_rounded, 
                                  Icons.description_rounded, 
                                  Icons.fitness_center_rounded, 
                                  Icons.inbox_rounded,
                                  Icons.laptop_rounded, 
                                ];
                                final icon = icons[Random().nextInt(icons.length)];
                                final angle = Random().nextDouble() * 2 * pi;
                                final distance = Random().nextDouble() * 150 + 50;
    
                                return AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    final progress = _pulseController.value;
                                    final dx = cos(angle) * distance * progress;
                                    final dy = sin(angle) * distance * progress;
                                    return Transform.translate(
                                      offset: Offset(dx, dy),
                                      child: Icon(icon,
                                          color: Colors.primaries[index % Colors.primaries.length],
                                          size: 24),
                                    );
                                  },
                                );
                              }),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              double scale = 0.8 + _pulseController.value * 0.4;
                              double opacity = (1 - _pulseController.value).clamp(0.0, 0.5);
                              return Semantics(
                                label: 'Pulsing circle animation indicating success',
                                child: Container(
                                  width: badgeSize * scale,
                                  height: badgeSize * scale,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primary.withOpacity(opacity),
                                  ),
                                ),
                              );
                            },
                          ),
                          AnimatedBuilder(
                            animation: _tickController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _tickRotate.value,
                                child: Transform.scale(
                                  scale: _tickScale.value,
                                  child: child,
                                ),
                              );
                            },
                            child: Semantics(
                              label: 'Checkmark icon indicating pickup is confirmed',
                              child: Container(
                                width: badgeSize,
                                height: badgeSize,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8)),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: badgeSize * 0.7,
                                    height: badgeSize * 0.7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [primary, accent],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                            color: primary.withOpacity(0.35),
                                            blurRadius: 10,
                                            offset: const Offset(0, 6)),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.check_rounded,
                                          size: 44, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    
                    const SizedBox(height: 18),
                    Semantics(
                      label: 'Congratulatory message',
                      child: Text(
                        'You’re awesome! ✨',
                        style: TextStyle(
                            fontSize: maxW < 360 ? 20 : 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87),
                      ),
                    ),
    
                    const SizedBox(height: 8),
                 Semantics(
    label:
        'Description: Pickup scheduled successfully. Thanks for choosing us.',
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        'Pickup scheduled successfully. Thanks for choosing us.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.bold, 
        ),
      ),
    ),
    ),
    
    
                    const SizedBox(height: 40),
    
                    Semantics(
                      container: true,
                      label: 'Options',
                      child: Column(
                        children: [
                          const SizedBox(height: 14),
                          _optionTile(
                            icon: Icons.fire_truck_outlined,
                            title: 'Track Pickups',
                            subtitle: 'You can see the pickup history',
                            color: const Color(0xFF1D4D61),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RequestsPage()),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          _optionTile(
                            icon: Icons.help_outline_rounded,
                            title: 'Need Help?',
                            subtitle: 'Contact support or chat',
                            color: const Color(0xFF1D4D61),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const HelpPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
    
                    const SizedBox(height: 30),
    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    ),
  );
}


}

