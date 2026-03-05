// import 'package:cyklze/widgets/statusbar.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class OrderDetailsPage extends StatelessWidget {
//   final dynamic item;

//   const OrderDetailsPage({Key? key, required this.item}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final statusLower = item.status.toString().toLowerCase();
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       body: SafeArea(
//         child: Stack(
//           children: [

//             /// 🔵 Gradient Header
//             Container(
//               height: screenHeight * 0.28,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color(0xFF1D4D61),
//                     Color(0xFF2F6B82),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//             ),

//             /// 🔙 Back Button
//             Positioned(
//               top: 10,
//               left: 12,
//               child: CircleAvatar(
//                 backgroundColor: Colors.white.withOpacity(0.2),
//                 child: IconButton(
//                   icon: const Icon(Icons.arrow_back, color: Colors.white),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ),
//             ),

//             /// 📄 Scrollable Content
//             Column(
//               children: [
//                 SizedBox(height: screenHeight * 0.18),

//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Column(
//                       children: [

//                         /// Main Card
//                         Container(
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(28),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.06),
//                                 blurRadius: 20,
//                                 offset: const Offset(0, 10),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [

//                               /// Header Row
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     "Order Details",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   _statusBadge(item.status),
//                                 ],
//                               ),

//                               const SizedBox(height: 24),

//                               /// Progress Bar
//                               if (statusLower != 'cancel' &&
//                                   statusLower != 'cancelled')
//                                 Column(
//                                   children: [
//                                     StatusProgressBar(status: item.code),
//                                     const SizedBox(height: 28),
//                                   ],
//                                 ),

//                               _modernTile(
//                                 icon: Icons.local_shipping_rounded,
//                                 title: "Pickup Type",
//                                 value: item.pickupType,
//                               ),

//                               _modernTile(
//                                 icon: Icons.calendar_month_rounded,
//                                 title: "Scheduled On",
//                                 value: item.time,
//                               ),

//                               _modernTile(
//                                 icon: Icons.description_rounded,
//                                 title: "Details",
//                                 value: item.details,
//                                 isMultiline: true,
//                               ),

//                               const SizedBox(height: 24),

//                               if (statusLower != 'cancel')
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(18),
//                                   child: Image.asset(
//                                     'assets/images/history.jpg',
//                                     height: 200,
//                                     width: double.infinity,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 40),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// 🔵 Modern Info Tile
//   Widget _modernTile({
//     required IconData icon,
//     required String title,
//     required String value,
//     bool isMultiline = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: Row(
//         crossAxisAlignment:
//             isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: const Color(0xFF1D4D61).withOpacity(0.08),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Icon(icon, color: const Color(0xFF1D4D61), size: 22),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: GoogleFonts.poppins(
//                     fontSize: 13,
//                     color: Colors.grey.shade500,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   value,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 🟢 Status Badge
//   Widget _statusBadge(String status) {
//     Color color;

//     switch (status.toLowerCase()) {
//       case "completed":
//       case "done":
//         color = Colors.green;
//         break;
//       case "cancel":
//       case "cancelled":
//         color = Colors.redAccent;
//         break;
//       default:
//         color = Colors.orange;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Text(
//         status,
//         style: GoogleFonts.poppins(
//           color: color,
//           fontWeight: FontWeight.w600,
//           fontSize: 13,
//         ),
//       ),
//     );
//   }
// }


import 'package:cyklze/widgets/statusbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderDetailsPage extends StatelessWidget {
  final dynamic item;

  const OrderDetailsPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusLower = item.status.toString().toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      /// ✅ Simple Modern AppBar
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Pickup Details",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Main Card
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
                /// Status Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Status",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _statusBadge(item.status),
                  ],
                ),
            
                const SizedBox(height: 20),
            
                /// Progress Bar
                if (statusLower != 'cancel' &&
                    statusLower != 'cancelled')
                  Column(
                    children: [
                      StatusProgressBar(status: item.code),
                      const SizedBox(height: 24),
                    ],
                  ),
            
                _modernTile(
                  icon: Icons.local_shipping_outlined,
                  title: "Pickup Type",
                  value: item.pickupType,
                ),
            
                _modernTile(
                  icon: Icons.calendar_today_outlined,
                  title: "Scheduled On",
                  value: item.time,
                ),
            
                _modernTile(
                  icon: Icons.description_outlined,
                  title: "Details",
                  value: item.details,
                  isMultiline: true,
                ),
            
                const SizedBox(height: 20),
            
                if (statusLower != 'cancel')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/history.jpg',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// Modern Info Tile
  Widget _modernTile({
    required IconData icon,
    required String title,
    required String value,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1D4D61).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1D4D61), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Status Badge
  Widget _statusBadge(String status) {
    Color color;

    switch (status.toLowerCase()) {
      case "completed":
      case "done":
        color = Colors.green;
        break;
      case "cancel":
      case "cancelled":
        color = Colors.redAccent;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}