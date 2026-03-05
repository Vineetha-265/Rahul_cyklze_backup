

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
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


class ItemCard1 extends StatefulWidget {
  final String label;
  final String description;
  final String imageUrl;
  final String price; // current price
  final int oldPrice; // old price for strikethrough
  final int discount; // amount off
  final int quantity;
   final BuildContext context;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ItemCard1({
    super.key,
    required this.label,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.quantity,
    required this.onAdd,
    required this.onRemove, required this.context,
  });

  @override
  State<ItemCard1> createState() => _ItemCard1State();
}

class _ItemCard1State extends State<ItemCard1> {
      // var qty =  0;
      
  @override
  Widget build(BuildContext context) {
// qty= widget.quantity;
    String back = widget.price.contains("kg")? "kgs": "Qty";
    return Padding(
     padding: const EdgeInsets.only(left: 4, right: 4),
      child: Container(
        color: Colors.white,
        width: 140, // fixed width similar to your grid item width
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with quantity selector overlay
            Stack(
              children: [
             
ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: CachedNetworkImage(
    imageUrl: widget.imageUrl,
    width: 140,
    height: 140,
    fit: BoxFit.contain,

    placeholder: (context, url) => Container(
      width: 140,
      height: 140,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),

    errorWidget: (context, url, error) => Container(
      width: 140,
      height: 140,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, size: 50),
    ),
  ),
),
      Positioned(
      bottom: 6,
      right: 2,
      child: widget.quantity > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF1D4D61),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1D4D61).withOpacity(0.4),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap:() async{  widget.onRemove();
// setState(() {
//   qty -= 100;
// });
              },
                    child: const Icon(Icons.remove, color: Colors.white, size: 18),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      widget.quantity.toString()+' '+back,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  GestureDetector(
                   onTap:() async{  widget.onAdd();
// setState(() {
//   qty += 100;
// });
              },
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ],
              ),
            )
          : GestureDetector(
              onTap:() async{  widget.onAdd();

              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF1D4D61),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF1D4D61).withOpacity(0.4),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child:  Text(
                  "Sell",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
    )
    
    
    
    ,],
         
         
            ),
      
            const SizedBox(height: 8),
      
            // Price row with current price, old price and discount
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "₹${widget.price}",
                    style:  GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Text(
                //   "₹$oldPrice",
                //   style: const TextStyle(
                //     color: Colors.grey,
                //     decoration: TextDecoration.lineThrough,
                //   ),
                // ),
              ],
            ),
      
            const SizedBox(height: 4),
      
            // Discount text
            // Text(
            //   "₹$discount OFF",
            //   style: TextStyle(
            //     color: Colors.green[700],
            //     fontWeight: FontWeight.w600,
            //     fontSize: 12,
            //   ),
            // ),
      
            const SizedBox(height: 6),
      
            // Product label/title multiline
            Text(
              widget.label,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style:  GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
      
            const SizedBox(height: 4),
      
            // Optional small tag / description line
            Text(
              widget.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class ItemCardSmall extends StatelessWidget {
  final String label;
  final String description;
  final String imageUrl;
  final String price;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ItemCardSmall({
    super.key,
    required this.label,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    String back = price.contains("kg")? "kgs": "Qty";
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Image Section
            Stack(
              children: [
               ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: CachedNetworkImage(
    imageUrl: imageUrl,
    height: 95,
    width: double.infinity,
    fit: BoxFit.cover,

    placeholder: (context, url) => Container(
      height: 95,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),

    errorWidget: (context, url, error) => Container(
      height: 95,
      color: Colors.grey[200],
      child: const Icon(Icons.image, size: 30),
    ),
  ),
),

Positioned(
  bottom: 6,
  right: 1,
  left: 6, // 👈 ADD THIS
  child: Align(
    alignment: Alignment.bottomRight,
    child: quantity > 0
        ? Container(
            constraints: const BoxConstraints(maxWidth: 140), // optional fine control
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1D4D61),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                GestureDetector(
                  onTap: onRemove,
                  child: const Icon(Icons.remove,
                      color: Colors.white, size: 18),
                ),
                Text(
                  '$quantity $back',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                GestureDetector(
                  onTap: onAdd,
                  child:
                      const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ],
            ),
          )   : GestureDetector(
              onTap:onAdd,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF1D4D61),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF1D4D61).withOpacity(0.4),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child:  Text(
                  "Sell",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
    )
)   
              ],
            ),

            const SizedBox(height: 6),

            /// Price
            Container(
              padding:
                   EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "₹$price",
                style:  GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 6),

            /// Title
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:  GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 2),

            /// Description
            Text(
              description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
