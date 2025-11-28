// // lib/widgets/item_card.dart
// import 'package:flutter/material.dart';

// class ItemCard extends StatelessWidget {
//   final String label;
//   final int value;
//   final IconData icon;
//   final VoidCallback onAdd;
//   final VoidCallback onRemove;

//   const ItemCard({
//     super.key,
//     required this.label,
//     required this.value,
//     required this.icon,
//     required this.onAdd,
//     required this.onRemove,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       // color: Colors.white,
//       // elevation: 0,
//       // margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
//       // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // Icon with subtle grey background
//             Container(
//               padding: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: Colors.grey.shade700, size: 22),
//             ),

//             const SizedBox(width: 4),

//             // Label
//             Expanded(
//               child: Text(
//                 label,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),

//             // Counter controls
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Minus button
//                InkWell(
//   onTap: onRemove,
//   borderRadius: BorderRadius.circular(24),
//   child: Container(
//     width: 48,
//     // padding: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//     height: 48,
//     alignment: Alignment.center,
//     child: const Icon(
//       Icons.remove,
//       color: Colors.black,
//       size: 20, // keep small icon, but tappable area = 48dp
//     ),
//   ),
// ),


//                 const SizedBox(width: 8),

//                 // Value
//                 Text(
//                   "$value kg",
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),

//                 const SizedBox(width: 8),

//                 // Plus button
//              InkWell(
//   onTap: onAdd,
//   borderRadius: BorderRadius.circular(24),
//   child: Container(
//     width: 48,
//      padding: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//     height: 48,
//     alignment: Alignment.center,
//     child: const Icon(
//       Icons.add,
//       color: Colors.black,
//       size: 20, // icon stays small, but tap area is large
//     ),
//   ),
// ),

//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';

// class ItemCard extends StatelessWidget {
//   final String label;
//   final int value;
//   final String imageUrl;
//   final VoidCallback onAdd;
//    final VoidCallback onTap;
//   final VoidCallback onRemove;
//   final Widget? belowButtons; // 👈 optional widget below the + / - buttons

//   const ItemCard({
//     super.key,
//     required this.label,
//     required this.value,
//     required this.imageUrl,
//     required this.onAdd,
//     required this.onRemove,
//     this.belowButtons, required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(
//     color: Colors.black, // Border color
//     width: 2,            // Border width
//         ),
//         borderRadius: BorderRadius.circular(12), // Rounded corners
//       ),
//       child: InkWell(
//           onTap:onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(8),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // 🖼️ Image at the top
//         Container(
//           height: 80,
//           width: 80,
//           decoration: BoxDecoration(
//             color: Colors.white, // 👈 white background
//             borderRadius: BorderRadius.circular(8), // 👈 rounded corners
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.asset(
//         imageUrl,
//         fit: BoxFit.cover,
//             ),
//           ),
//         )
//         ,
        
//               const SizedBox(height: 8),
        
//               // 🏷️ Item label
//               Text(
//                 label,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
        
//               const SizedBox(height: 8),
        
//               // ➕➖ Counter Row
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Minus button
//                   InkWell(
//                     onTap: onRemove,
//                     borderRadius: BorderRadius.circular(12),
//                     child: Container(
//                       width: 24,
//                       height: 24,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       alignment: Alignment.center,
//                       child: const Icon(Icons.remove, color: Colors.black, size: 20),
//                     ),
//                   ),
        
//                   const SizedBox(width: 8),
        
//                   // Value
//                   Text(
//                     "$value kg",
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
        
//                   const SizedBox(width: 8),
        
//                   // Plus button
//                   InkWell(
//                     onTap: onAdd,
//                     borderRadius: BorderRadius.circular(12),
//                     child: Container(
//                       width: 24,
//                       height: 24,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       alignment: Alignment.center,
//                       child: const Icon(Icons.add, color: Colors.black, size: 20),
//                     ),
//                   ),
//                 ],
//               ),
        
             
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


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


// import 'package:flutter/material.dart';

// class ItemCard extends StatelessWidget {
//   final String label;
//   final int value;
//   final String imageUrl;
//   final VoidCallback onAdd;
//   final VoidCallback onTap;
//   final VoidCallback onRemove;
//   final Widget? belowButtons;

//   const ItemCard({
//     super.key,
//     required this.label,
//     required this.value,
//     required this.imageUrl,
//     required this.onAdd,
//     required this.onRemove,
//     required this.onTap,
//     this.belowButtons,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 130, // 🔒 Fixed width
//       height: 200, // 🔒 Fixed height
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(
//           color: Colors.black,
//           width: 2,
//         ),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(8),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               // 🖼️ Image section
//               Container(
//                 width: 80, // fixed width
//                 height: 80, // fixed height
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.asset(
//                     imageUrl,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 8),

//               // 🏷️ Label
//               SizedBox(
//                 height: 30, // fixed height for label text
//                 child: Text(
//                   label,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                 ),
//               ),

//               const SizedBox(height: 8),

//               // ➕➖ Counter
//               SizedBox(
//                 height: 30,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // ➖ button
//                     InkWell(
//                       onTap: onRemove,
//                       borderRadius: BorderRadius.circular(10),
//                       child: Container(
//                         width: 24,
//                         height: 24,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade300,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         alignment: Alignment.center,
//                         child: const Icon(Icons.remove, size: 20, color: Colors.black),
//                       ),
//                     ),

//                     const SizedBox(width: 8),

//                     // value text
//                     SizedBox(
//                       width: 45, // fixed width for value text
//                       child: Text(
//                         "$value kg",
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),

//                     const SizedBox(width: 8),

//                     // ➕ button
//                     InkWell(
//                       onTap: onAdd,
//                       borderRadius: BorderRadius.circular(10),
//                       child: Container(
//                         width: 24,
//                         height: 24,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade300,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         alignment: Alignment.center,
//                         child: const Icon(Icons.add, size: 20, color: Colors.black),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               if (belowButtons != null) ...[
//                 const SizedBox(height: 8),
//                 belowButtons!,
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';

// class ItemCard extends StatelessWidget {
//   final String label;
//   final int value;
//   final String imageUrl;
//   final VoidCallback onAdd;
//   final VoidCallback onRemove;
//   final Widget? belowButtons;

//   const ItemCard({
//     super.key,
//     required this.label,
//     required this.value,
//     required this.imageUrl,
//     required this.onAdd,
//     required this.onRemove,
//     this.belowButtons,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // 🧠 Get screen dimensions
//     final screenWidth = MediaQuery.of(context).size.width;

//     // 🔹 Dynamically calculate sizes based on screen width
//     final imageSize = screenWidth * 0.2; // 20% of screen width
//     final buttonSize = screenWidth * 0.11; // dynamic button size
//     final fontSize = screenWidth * 0.035; // adaptive text size

//     return Expanded(
//       // color: Colors.white,
//       // elevation: 1,
//       // margin: const EdgeInsets.all(6),
//       // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Padding(
//         padding: const EdgeInsets.all(8),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // 🖼️ Image at the top
//             Center(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.asset(
//                   imageUrl,
//                   height: imageSize,
//                   width: imageSize,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),

//             SizedBox(height: screenWidth * 0.02),

//             // 🏷️ Item label
//             Text(
//               label,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: fontSize + 1,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),

//             SizedBox(height: screenWidth * 0.02),

//             // ➕➖ Counter Row
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Minus button
//                 InkWell(
//                   onTap: onRemove,
//                   borderRadius: BorderRadius.circular(24),
//                   child: Container(
//                     width: buttonSize,
//                     height: buttonSize,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     alignment: Alignment.center,
//                     child: Icon(Icons.remove,
//                         color: Colors.black, size: buttonSize * 0.45),
//                   ),
//                 ),

//                 SizedBox(width: screenWidth * 0.02),

//                 // Value
//                 Text(
//                   "$value kg",
//                   style: TextStyle(
//                     fontSize: fontSize,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),

//                 SizedBox(width: screenWidth * 0.02),

//                 // Plus button
//                 InkWell(
//                   onTap: onAdd,
//                   borderRadius: BorderRadius.circular(24),
//                   child: Container(
//                     width: buttonSize,
//                     height: buttonSize,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     alignment: Alignment.center,
//                     child: Icon(Icons.add,
//                         color: Colors.black, size: buttonSize * 0.45),
//                   ),
//                 ),
//               ],
//             ),

//             // ⬇️ Below the buttons
//             if (belowButtons != null) ...[
//               SizedBox(height: screenWidth * 0.02),
//               belowButtons!,
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }



