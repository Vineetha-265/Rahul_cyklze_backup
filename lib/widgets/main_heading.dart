import 'package:flutter/material.dart';

class BigSaleText extends StatelessWidget {
  const BigSaleText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // BIG SALE
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFB85CFF), Color(0xFF6225FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            "BIG SALE",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: Colors.white, // gets replaced by gradient
              shadows: [
                Shadow(
                  blurRadius: 4,
                  offset: Offset(2, 3),
                  color: Colors.black26,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Subtitle: THE BIGGEST INDIAN GROCERY SALE
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF6E1EFF),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            "THE BIGGEST INDIAN GROCERY SALE",
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Dates: 31ST OCT - 6TH NOV
        const Text(
          "31ST OCT - 6TH NOV",
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
