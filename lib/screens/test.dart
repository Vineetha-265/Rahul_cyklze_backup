import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cyklze/Provider/pickup_provider.dart';
import 'package:cyklze/SecureStorage/securestorage.dart';
import 'package:cyklze/Views/error.dart';
import 'package:cyklze/Views/loading.dart';
import 'package:cyklze/Views/offline.dart';
import 'package:cyklze/screens/edit_address.dart';
import 'package:cyklze/screens/updated_date.dart';
import 'package:cyklze/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// Make sure you already have your ItemCard widget implemented

class PricesPage extends StatefulWidget {
  const PricesPage({Key? key}) : super(key: key);

  @override
  State<PricesPage> createState() => _PricesPageState();
}
enum PageState {  loggedIn, offline, error,loading }
class _PricesPageState extends State<PricesPage> {
  PageState _state = PageState.loading;
  List<dynamic> householdCategories = [];
   List<dynamic> household = [];
    List<dynamic> commercialCategories = [];
  bool isLoading = true;
  int house_margin = 1000;
  int house_qty_margin = 2;
  int commercial_qty_margin = 3;
  String popup_heading = "";
  String popup_content = "";
  String pickuptype = "pickup";
  String popup_btn = "";
  String popup = "";
  int commercial_margin = 100;
  String commercial_heading = "Commercial Pickup";
  
  String commercial_subheading = "Get Better Prices";
  
  String house_heading = "Household Pickup";
  String house_subheading = "No Stepping Outside";
  int house_last = 100;
String? address;
  int commercial_last = 10000;
                  final List<String> selectedItems = [];
  Map<String, int> qty = {
 
};
List<List<int>> quantities = [];
// bool get hasAnyQuantity =>
//     quantities.any((category) => category.any((item) => item > 0));
  int selectedIndex = 0; 
  // bool get hasAnyQuantity1 => qty.any((item) => item > 0)
   bool get hasAnyQuantity => qty.values.any((item) => item > 0);
  @override
  void initState() {
    super.initState();
    
    fetchPrices();
  loadAddress();
       
  }
  Future<void> loadAddress() async {
  address = await SecureStorage.getAddress();
  setState(() {}); // only if this is inside a StatefulWidget
}

  Future<void> fetchPrices() async {
       setState(() {
    _state = PageState.loading;
    });
    final   provider = Provider.of<PickupProvider>(context, listen: false);
  if (!await provider.hasInternetConnection()) {
       setState(() => _state = PageState.offline);
    return;
  }
    final url = Uri.parse(
        "https://api.cyklze.com/cyklzee/prices");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if(data['email'].toString().isNotEmpty){
          await SecureStorage.saveemail(data['email']);
        }

        setState(() {
          household = data["household"];
             commercial_heading = data["commercial_heading"];
             commercial_subheading = data["commercial_subheading"];
             house_heading = data["house_heading"];
             house_subheading = data["house_subheading"];
          commercialCategories = data["commercial"];
          householdCategories = household;
         house_margin = int.parse(data["house_margin"]);
         house_qty_margin = int.parse(data["house_qty_margin"]);
         commercial_qty_margin = int.parse(data["commercial_qty_margin"]);
         commercial_margin = int.parse(data["commercial_margin"]);
         house_last = int.parse(data["house_last"]);
         commercial_last = int.parse(data["commercial_last"]);
          household = data["household"];
          
            popup_heading = data["popup_heading"];
              popup_content = data["popup_content"];
                popup_btn = data["popup_btn"];
                  popup = data["popup"];
          commercialCategories = data["commercial"];
          householdCategories = household;
          isLoading = false;
          pickuptype = house_heading;
             quantities = householdCategories.map((category) {
      // Handle categories with no items
      final itemsLength = category["items"]?.length ?? 0;
      return List.filled(itemsLength, 0);
    }).toList();
        });
          WidgetsBinding.instance.addPostFrameCallback((_) {
    if(popup.toLowerCase().contains("yes"))showMaxWeightDialog1(context);
  });
   setState(() {
    _state = PageState.loggedIn;
    });
      } else {
      setState(() {
    _state = PageState.error;
    });
      }
    } catch (e) {
      setState(() {
    _state = PageState.error;
    });
    }
  }

  // 🔹 Horizontal Slider Card
  // Widget buildProductCard(dynamic item) {
  //   return Container(
      
  //     width: 180,
  //     margin: const EdgeInsets.only(right: 12),
  //     child: Card(
  //       elevation: 4,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           ClipRRect(
  //             borderRadius:
  //                 const BorderRadius.vertical(top: Radius.circular(12)),
  //             child: Image.network(
  //               item["img"],
  //               height: 110,
  //               width: double.infinity,
  //               fit: BoxFit.cover,
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   item["name"],
  //                   style: const TextStyle(
  //                       fontSize: 16, fontWeight: FontWeight.bold),
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   "₹${item["price"]} per kg",
  //                   style: const TextStyle(
  //                       fontSize: 14, color: Colors.green),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 SizedBox(
  //                   width: double.infinity,
  //                   height: 35,
  //                   child: ElevatedButton(
  //                     onPressed: () {
  //                       print("Sell ${item["name"]}");
  //                     },
  //                     child: const Text("Sell"),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

void showMaxWeightDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Maximum Weight Reached",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "You have entered the maximum weight for a single item.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "OK",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}



    Widget _buildByState() {
    switch (_state) {
     
   case PageState.loading:
        return const  ElegantLoadingOverlay();
      case PageState.loggedIn:
        return mainContent();
      case PageState.error:
        return  ErrorRetry(
              message: "Something went wrong",
              onRetry: fetchPrices,);
      case PageState.offline:
        return OfflineRetry(
      onRetry: fetchPrices, // your function
    );
     
    }
  }





void showMaxWeightDialog1(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        child: 
    Padding(
  padding: const EdgeInsets.all(20.0),
  child: SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Container(
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     shape: BoxShape.circle,
        //   ),
        //   padding: const EdgeInsets.all(16),
        //   child: const Icon(
        //     Icons.warning_amber_rounded,
        //     color: Color(0xFF1D4D61),
        //     size: 40,
        //   ),
        // ),
        const SizedBox(height: 20),
        Text(
          popup_heading ,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          popup_content,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1D4D61),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              popup_btn,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),  );
    },
  );
}
  // 🔹 Category Section (Alternating Layout)
  Widget buildCategorySection(dynamic category, int index,BuildContext context) {
    final items = category["items"];

  
    bool isEvenCategory = index % 2 == 1; // 2nd, 4th, 6th...

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Title
  Padding( padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text( category["category"], style:  GoogleFonts.poppins( fontSize: 20, fontWeight: FontWeight.bold, ), ), )
,
        // 🔥 EVEN CATEGORY → GRID VIEW
        if (isEvenCategory)
    GridView.builder(
   shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(), // avoids nested scrolls
  padding: const EdgeInsets.all(6),
  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 200, // Increased width for mobile to fit 2 per row
    mainAxisSpacing: 6,
    crossAxisSpacing: 6,
    
     mainAxisExtent: 200,
   // childAspectRatio: 0.65, // Adjust to match ItemCard height/width ratio
  ),
  itemCount: items.length,
  itemBuilder: (context, itemIndex) {
    final item = items[itemIndex];

    return InkWell(
      onTap: () {
          showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final bool isKg =
    item["price"].toString().toLowerCase().contains("kg");
      return MaterialSlider(
        label:  item["name"] as String,
        value: qty[item["name"] as String] ?? 0,

        price: item["price"] as String,
          margin: selectedIndex == 1
      ? (isKg ? commercial_margin : commercial_qty_margin)
      : (isKg ? house_margin : house_qty_margin),
        max:selectedIndex == 1? commercial_last:house_last,
        url: item["img"],
         description:  item["description"],
        onAdd: () {if ((qty[item["name"] as String] ?? 100) <=
    (selectedIndex == 1 ? commercial_last : house_last)) {
     setState(() {
                        if(selectedIndex == 1){
                          if(item["price"].toString().toLowerCase().contains("kg")){

                      qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) + commercial_margin;

                          }else{

                      qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) + commercial_qty_margin;

                          }
                          
                   //   quantities[index][itemIndex] += commercial_margin;
                        }
                        else{
                          if(item["price"].toString().toLowerCase().contains("kg")){
   qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) + house_margin;
                          }else{
   qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) + house_qty_margin;
                          }
                   

                    //  quantities[index][itemIndex] += house_margin;
                        }
                      
                    });

    }else{
      showMaxWeightDialog(context);
    }
          
               
                  },
          onRemove: () {
                    setState(() {
                      if ((qty[item["name"] as String]??commercial_margin)  > 0) {
                        if(selectedIndex == 1){

                          if(item["price"].toString().toLowerCase().contains("kg")){
   qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) - commercial_margin;
                          }else{
   qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) - commercial_qty_margin;
                          }
                        

                      //  quantities[index][itemIndex] -= commercial_margin;
                        }
                        else{
if(item["price"].toString().toLowerCase().contains("kg")){
 qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) - house_margin;
}else{
 qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) - house_qty_margin;
}
                       

                        //quantities[index][itemIndex] -= house_margin;
                        }
                      }
                    });}
      );
    },
  );
      },
      child: ItemCardSmall(
        label: item["name"],
        description: item["description"],
        imageUrl: item["img"],
        price: item["price"],
                  quantity: qty[item["name"] as String] ?? 0, // current quantity
       onAdd: () {
   if ((qty[item["name"] as String] ?? 100) <=
    (selectedIndex == 1 ? commercial_last : house_last)) {

   if(selectedIndex == 1){
                          setState(() {
                            if(item["price"].toString().toLowerCase().contains("kg")){
   qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) + commercial_margin;
                            }else{
   qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) + commercial_qty_margin;
                            }
                   

                     // quantities[index][itemIndex] += commercial_margin;
                          });
                        }else{
                           setState(() {
                          if(item["price"].toString().toLowerCase().contains("kg")){

   qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) + house_margin;
                          }else{

   qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) + house_qty_margin;
                          }

                   
                    //  quantities[index][itemIndex] += house_margin;
                    });

                        }
    }else{
      showMaxWeightDialog(context);
    }
        
     
                  },
                  onRemove: () {
                    setState(() {
                      if ((qty[item["name"] as String]??commercial_margin)  > 0) {
                         if(selectedIndex == 1){
                          if(item["price"].toString().toLowerCase().contains("kg")){
   qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) - commercial_margin;
                          }else{
   qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) - commercial_qty_margin;
                          }
                     

                     //   quantities[index][itemIndex] -= commercial_margin;
                         }
                         else{
if(item["price"].toString().toLowerCase().contains("kg")){
  qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) - house_margin;
}else{
  qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) - house_qty_margin;
}
                      

                      //  quantities[index][itemIndex] -= house_margin;
                         }
                      }
                    });}
      ),
    );
  },
)

        // 🔥 ODD CATEGORY → HORIZONTAL SLIDER
        else
  SizedBox(
  height: 250,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.only(left: 14, right: 14),
    itemCount: items.length,
    itemBuilder: (context, itemIndex) {
      final item = items[itemIndex];

      return InkWell(
        onTap: (){
          
          showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final bool isKg =
    item["price"].toString().toLowerCase().contains("kg");
      return MaterialSlider(
        label:  item["name"] as String,
        value:  qty[item["name"] as String] ?? 0,
        url: item["img"],
         margin: selectedIndex == 1
      ? (isKg ? commercial_margin : commercial_qty_margin)
      : (isKg ? house_margin : house_qty_margin),

           max: selectedIndex == 1? commercial_last:house_last,
        price: item["price"] as String,
         description:  item["description"],
        onAdd: () {
   if ((qty[item["name"] as String] ?? 100) <=
    (selectedIndex == 1 ? commercial_last : house_last)) {

  if(selectedIndex == 1){

                    setState(() {
                      if(item["price"].toString().toLowerCase().contains("kg")){
    qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) + commercial_margin;
                      }else{
    qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) + commercial_qty_margin;
                      }
                    
          
                    });
          }else{
              setState(() {
            if(item["price"].toString().toLowerCase().contains("kg")){
    qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) + house_margin;
            }else{
    qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) + house_qty_margin;
            }


                  
                    //  quantities[index][itemIndex] += house_margin;
                    });
          }
      
    }else{
      
showMaxWeightDialog(context);
    }
        
                  },
          onRemove: () {
                    setState(() {
                      if ((qty[item["name"] as String]??commercial_margin)  > 0) {
                         if(selectedIndex == 1){
                          if(item["price"].toString().toLowerCase().contains("kg")){
      qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) - commercial_margin;
                          }else{
      qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) - commercial_qty_margin;
                          }

                  

                       // quantities[index][itemIndex] -= commercial_margin;

                         }
                         else{
if(item["price"].toString().toLowerCase().contains("kg")){
   qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) - house_margin;
}else{
   qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) - house_qty_margin;
}
                     

                     //   quantities[index][itemIndex] -= house_margin;
                         }
                      }
                    });}
      );
    },
  );
     
   
        },
        child: ItemCard1(
          label: item["name"],
          description: item["description"],
          imageUrl: item["img"],
          price: item["price"],
          oldPrice: 225,
          context: context,
          discount: 26,
              quantity: qty[item["name"] as String] ?? 0,
                  // quantities[index][itemIndex], // pass current quantity
        onAdd: () {if ((qty[item["name"] as String] ?? 100) <=
    (selectedIndex == 1 ? commercial_last : house_last)) {
      
  if(selectedIndex == 1){
            setState(() {
    if(item["price"].toString().toLowerCase().contains("kg")){

   qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) + commercial_margin;
    }else{
   qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) + commercial_qty_margin;
    }


            
                     // quantities[index][itemIndex] += commercial_margin;
                    });

          }else{
                setState(() {
if(item["price"].toString().toLowerCase().contains("kg")){
  qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) + house_margin;
}else{
  qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) + house_qty_margin;
}


                
                    //  quantities[index][itemIndex] += house_margin;
                    });
          }
        }else{
showMaxWeightDialog(context);
        }
        
        
                  },
            onRemove: () {
          setState(() {
            if ((qty[item["name"] as String]??commercial_margin)  > 0) {
              if(selectedIndex ==1){
                if(item["price"].toString().toLowerCase().contains("kg")){
   qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) - commercial_margin;
                }else{
   qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) - commercial_qty_margin;
                }
           

      //  quantities[index][itemIndex] -= commercial_margin;
              }else{
if(item["price"].toString().toLowerCase().contains("kg")){
     qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) - house_margin;
}else{
     qty[item["name"] as String] =
    (qty[item["name"] as String] ?? 0) - house_qty_margin;
}
         

    //    quantities[index][itemIndex] -= house_margin;

              }
            }
        
        //     // Flatten the nested list to display all quantities
        //     String allQuantities = quantities.asMap().entries.map((catEntry) {
        // int catIndex = catEntry.key;
        // List<int> itemsList = catEntry.value;
        
        // // Map each item quantity with its item name
        // return itemsList.asMap().entries.map((itemEntry) {
        //   int itemIndex2 = itemEntry.key;
        //   var itemName = householdCategories[catIndex]["items"][itemIndex2]["name"];
        //   int qty = itemEntry.value;
        //   return "$itemName: $qty";
        // }).join(", "); // join items within a category
        //     }).join("\n"); // separate categories with newline
        // final List<String> selectedItems = [];
        
        // for (int i = 0; i < quantities.length; i++) {
        //   final category = householdCategories[i];
        //   final items = category["items"] ?? [];
        
        //   for (int j = 0; j < quantities[i].length; j++) {
        //     final qty = quantities[i][j];
        
        //     if (qty > 0) {
        // final name = items[j]["name"]; // adjust key if different
        // selectedItems.add("$name: $qty Kg");
        //     }
        //   }
        // }
        
        //     // Show SnackBar
        //     ScaffoldMessenger.of(context).showSnackBar(
        // SnackBar(
        //   content: Text(selectedItems.join("\n")),
        //   duration: const Duration(milliseconds: 800),
        //   behavior: SnackBarBehavior.floating,
        //   margin: const EdgeInsets.all(16),
        // ),
        //     );
          });
        },
        
        ),
      );
    },
  ),
),

// ItemCard1(
//   label: "Surf Excel Matic Top Load Detergent Liquid Refill | Tough Dried...",
//   description: "Stain Removal",
//   imageUrl: "https://cyklze.com/iron.jpg",
//   price: 199,
//   oldPrice: 225,
//   discount: 26,
//   quantity: 1, // current quantity
//   onAdd: () => print("Add"),
//   onRemove: () => print("Remove"),
// ),
        const SizedBox(height: 20),
      ],
    );
  }

Widget _buildOption({
  required int index,
  required String title,
  required String subtitle,
  required GestureTapCallback onTap,
}) {
  final bool isSelected = selectedIndex == index;

  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF1D4D61) : Colors.white,
          // ❌ Removed borderRadius
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xFF1D4D61).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? Colors.white : Color(0xFF1D4D61),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isSelected ? Colors.white : Color(0xFF1D4D61),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

 
 Widget mainContent() {
  return Stack(
    children: [
      Column(
        children: [
          Row(
            children: [
              _buildOption(
                onTap: () {
                  qty = {};
                  setState(() {
                    selectedIndex = 0;
                    householdCategories = household;
                    pickuptype = house_heading;
                  });
                },
                index: 0,
                title: house_heading,
                subtitle: house_subheading,
              ),
              _buildOption(
                onTap: () {
                  qty = {};
                  setState(() {
                    selectedIndex = 1;
                    householdCategories = commercialCategories;
                    pickuptype = commercial_heading;
                  });
                },
                index: 1,
                title: commercial_heading,
                subtitle: commercial_subheading,
              ),
            ],
          ),

          Container(
            height: 3,
            width: double.infinity,
            color: const Color(0xFF1D4D61),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: householdCategories.length,
              itemBuilder: (context, index) {
                return buildCategorySection(
                  householdCategories[index],
                  index,
                  context,
                );
              },
            ),
          ),
        ],
      ),

      if (hasAnyQuantity)
        Positioned(
          bottom: 20,
          right: 20,
          child: InkWell(
            onTap: () {
              List<String> allQuantities = qty.entries
                  .where((entry) => entry.value > 0)
                  .map((entry) => "${entry.key}: ${entry.value} Qty")
                  .toList();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PickupDateTimeSelector(
                    names: allQuantities,
                    pickuptype: pickuptype,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1D4D61),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              child: Text(
                "Continue",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
  @override
  Widget build(BuildContext context) {
    Future<void> _goToEditAddress() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditAddressPage(),
    ),
  );

  // This runs AFTER pop
  await loadAddress();
}

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  AppBar(
        
  automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade200,
        elevation: 0,
        titleSpacing: 0,
        title:  Padding(
          padding:  EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // First Row (Icon + 7 minutes)
              Row(
                children:  [
                  // Icon(
                  //   Icons.bolt,
                  //   color: Colors.deepPurple,
                  //   size: 18,
                  // ),
                  SizedBox(width: 6),
                  Text(
  "Cyklze",
  style: GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.bold,
color: Color(0xFF1D4D61),
  ),
),
                ],
              ),

              const SizedBox(height: 4),

              // Second Row (Location + dropdown)
           if(address!=null)   InkWell(
            onTap: _goToEditAddress,
             child: Row(
                  children:  [
                    Expanded(
                      child:Text.rich(
               TextSpan(
                 children: [
                TextSpan(
               text: "Address - ",
               style: GoogleFonts.poppins(
                 fontWeight: FontWeight.bold,
                 color: Colors.black87,
                 fontSize: 14,
               ),
             ),
             
                   TextSpan(
                     text: address,
                     style:  GoogleFonts.poppins(
                       fontWeight: FontWeight.normal,
                       color: Colors.black87,
                       fontSize: 14
                     ),
                   ),
                 ],
               ),
               overflow: TextOverflow.ellipsis,
             )
             
                    ),
                   const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ],
                ),
           ),
            ],
          ),
        ),
      ),
      body:
      _buildByState()
    );
  }
}



class MaterialSlider extends StatefulWidget {
  final String label;
  final int value;
    final int max;
  final int margin;
 final String price;

  final String url;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final String description;

  const MaterialSlider({
    super.key,
    required this.label,
    required this.value,
      required this.max,
    
     required this.margin,
    required this.price,
    required this.url,
    required this.onAdd,
    required this.description,
    required this.onRemove,
  });

  @override
  State<MaterialSlider> createState() => _MaterialSliderState();
}

class _MaterialSliderState extends State<MaterialSlider> {
  late int num; // ✅ Moved here — outside build()

  @override
  void initState() {
    super.initState();
    num = widget.value; // ✅ Initialize once when widget is created
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double imageSize = width * 0.5; // 50% of parent width
// var qty = widget.value;
 String back = widget.price.contains("kg")? "kgs": "Qty";
String lbl = widget.label.toLowerCase();

final add100 = {
  "plastic",
  "glass",
  "paper",
  "books",
  "e-waste",
  "cardboard",
  "iron",
  "copper wire",
  "silver",
  "mixed"
};

final add10 = {
  "copper",
  "brass"
};

final add1 = {
  "fridge",
  "ac"
};

void showMaxWeightDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Maximum Weight Reached",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "You have entered the maximum weight for a single item.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "OK",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
   return Container(
  width: width,
  height: MediaQuery.of(context).size.height * 0.5,
  padding: const EdgeInsets.all(16),
  decoration: const BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  child: SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        // Drag Handle
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        const SizedBox(height: 16),

     ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: CachedNetworkImage(
    imageUrl: widget.url,
    height: imageSize,
    width: imageSize,
    fit: BoxFit.cover,

    placeholder: (context, url) => Container(
      height: imageSize,
      width: imageSize,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),

    errorWidget: (context, url, error) => Container(
      height: imageSize,
      width: imageSize,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported),
    ),
  ),
),

        const SizedBox(height: 12),

        // Label
        Text(
          widget.label,
          style:  GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        // Bottom Section: Description + Button
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // LEFT → Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.price,
                      style:  GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                   Text(
                    "Description",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                 // const SizedBox(height: 6),
                
                ],
              ),
            ),

            const SizedBox(width: 12),

            // RIGHT → Quantity Button
            num > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
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
                          onTap: () {
                            widget.onRemove();
                            setState(() {
                              num = num - widget.margin;
                            });
                          },
                          child: const Icon(
                            Icons.remove,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            num.toString()+' '+back,
                            style:  GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            widget.onAdd();
                            if(num < widget.max){
                               setState(() {
                              num += widget.margin;
                            });
                            }
                            
                          
                          },
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      widget.onAdd();
                      setState(() {
                        num += widget.margin;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF1D4D61),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Color(0xFF1D4D61).withOpacity(0.4),
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
          ],
        ),
  SizedBox(height: 10,),
  
  Text(
                    widget.description,
                    style:  GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),

        const SizedBox(height: 20),
      ],
    ),
  ),
);

  }
}
