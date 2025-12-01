

import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String label;
  final int value;
  final String imageUrl;
  final VoidCallback onAdd;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final Widget? belowButtons; // Optional widget below buttons
  const ItemCard({
    super.key,
    required this.label,
    required this.value,
    required this.imageUrl,
    required this.onAdd,
    required this.onRemove,
    required this.onTap,
    this.belowButtons,
  });

  @override
  Widget build(BuildContext context) {
    final lowerLabel = label.toLowerCase();
 return Container(
  width: 84, // Reduced width by 40%
  height: 140, // Reduced height by 40%
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(
      color: Colors.black,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(7.2), // Reduced border radius by 40%
  ),
  child: InkWell(
    borderRadius: BorderRadius.circular(7.2), // Reduced border radius by 40%
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(4.8), // Reduced padding by 40%
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 🖼️ Image
          Container(
            height: 48, // Reduced height by 40%
            width: 48, // Reduced width by 40%
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.8), // Reduced border radius by 40%
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.8), // Reduced border radius by 40%
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 3), // Reduced space between elements by 40%

          // 🏷️ Label
          SizedBox(
            width: 72, // Reduced width by 40%
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13, // Reduced font size by 40%
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 3), // Reduced space between elements by 40%

          // ➕➖ Counter Row
         value>0? SizedBox(
            height: 43, // Reduced height by 40%
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
  "$value ${ (lowerLabel == 'ac' || lowerLabel == 'fridge') ? 'qty' : 'kg' }",
  style: const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  ),
),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ➖ Remove Button
                    InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(4.8), // Reduced border radius by 40%
                      child: Container(
                        width: 30, // Reduced width by 40%
                        height: 25, // Reduced height by 40%
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4.8), // Reduced border radius by 40%
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.remove,
                          color: Colors.black,
                          size: 12, // Reduced icon size by 40%
                        ),
                      ),
                    ),
                    const SizedBox(width: 5), // Reduced space by 40%
                
                    // Value Text
                    // Text(
                    //   "$value kg",
                    //   style: const TextStyle(
                    //     fontSize: 8.4, // Reduced font size by 40%
                    //     fontWeight: FontWeight.w600,
                    //     color: Colors.black87,
                    //   ),
                    // ),
                    const SizedBox(width: 5), // Reduced space by 40%
                
                    // ➕ Add Button
                    InkWell(
                      onTap: onAdd,
                      borderRadius: BorderRadius.circular(4.8), // Reduced border radius by 40%
                      child: Container(
                        width: 30, // Reduced width by 40%
                        height: 25, // Reduced height by 40%
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4.8), // Reduced border radius by 40%
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.add,
                          color: Colors.black,
                          size: 12, // Reduced icon size by 40%
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ):InkWell( onTap: onAdd,
            child: Container(
              decoration:BoxDecoration(
              color: const Color(0xFF1D4D61), // same background color
              borderRadius: BorderRadius.circular(12), // rounded corners
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.25), // subtle shadow
              //     blurRadius: 4,
              //     offset: const Offset(0, 2),
              //   ),
              // ],
            )
            ,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: const Text(
                  "Sell",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          )

          // Optional widget below buttons
         
        ],
      ),
    ),
  ),
);
 }

}
