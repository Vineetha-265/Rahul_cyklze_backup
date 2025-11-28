import 'package:cyklze/screens/general_pickup.dart';
import 'package:cyklze/screens/home_page.dart';
import 'package:flutter/material.dart';

class HalloweenCard extends StatelessWidget {
  const HalloweenCard({super.key});

@override
Widget build(BuildContext context) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GeneralPickupPage()),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // slightly smaller radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4, // tighter shadow
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6), // reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header image/logo
          Image.asset(
            'assets/images/head.png',
            width: 200, // reduced width
            height: 25, // slightly smaller
            fit: BoxFit.cover,
          ),

          const SizedBox(height: 6), // tighter spacing

          // Title text
          const Text(
            "Let's setup your scrap pickup",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w700,
              fontSize: 17, // smaller font
              letterSpacing: 0.0,
            ),
          ),

          const SizedBox(height: 8), // spacing before bottom row

          // Bottom row with button and truck image
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Schedule button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4D61),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // tighter padding
                  child: Text(
                    "Schedule",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14, // smaller font
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),

              // Truck image
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/truck.jpg',
                  width: 70, // reduced width
                  height: 55, // reduced height
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

}
