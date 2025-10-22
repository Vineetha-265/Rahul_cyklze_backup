// lib/widgets/item_card.dart
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ItemCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon with subtle grey background
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.grey.shade700, size: 22),
            ),

            const SizedBox(width: 4),

            // Label
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            // Counter controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minus button
               InkWell(
  onTap: onRemove,
  borderRadius: BorderRadius.circular(24),
  child: Container(
    width: 48,
    // padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
    height: 48,
    alignment: Alignment.center,
    child: const Icon(
      Icons.remove,
      color: Colors.black,
      size: 20, // keep small icon, but tappable area = 48dp
    ),
  ),
),


                const SizedBox(width: 8),

                // Value
                Text(
                  "$value kg",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(width: 8),

                // Plus button
             InkWell(
  onTap: onAdd,
  borderRadius: BorderRadius.circular(24),
  child: Container(
    width: 48,
     padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
    height: 48,
    alignment: Alignment.center,
    child: const Icon(
      Icons.add,
      color: Colors.black,
      size: 20, // icon stays small, but tap area is large
    ),
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
