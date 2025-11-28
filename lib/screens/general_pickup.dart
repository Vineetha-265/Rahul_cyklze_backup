import 'package:cyklze/Provider/pickup_provider.dart';
import 'package:cyklze/screens/address.dart';
import 'package:cyklze/screens/price_page.dart';
import 'package:cyklze/widgets/date_time.dart';
import 'package:intl/intl.dart';
import 'dart:io'; 
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cyklze/widgets/item_card.dart';
import 'package:cyklze/widgets/time_chip.dart';
import 'package:provider/provider.dart';
class GeneralPickupPage extends StatefulWidget {
  const GeneralPickupPage({super.key});

  @override
  State<GeneralPickupPage> createState() => _GeneralPickupPageState();
}


class _GeneralPickupPageState extends State<GeneralPickupPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottomButton = true;
  int plasticKg = 0;
  int glassKg = 0;
  int paperKg = 0;
  int metalKg = 0;
  int ewasteKg = 0;
  int cardKg = 0;
  int bookskg = 0;
  int cwirekg = 0;
  int wirekg = 0;
  int silverkg = 0;
  int brasskg = 0;
  int fridgekg = 0;
  int ackg = 0;
  int mixedkg = 0;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      // Show button only when not near the bottom
      if (maxScroll - currentScroll > 100) {
        if (!_showScrollToBottomButton) {
          setState(() => _showScrollToBottomButton = true);
        }
      } else {
        if (_showScrollToBottomButton) {
          setState(() => _showScrollToBottomButton = false);
        }
      }
    });
  }
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  String? selectedDate;
  String? selectedTimeRange;

Future<void> _pickDate() async {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final maxDate = tomorrow.add(const Duration(days: 7));

  final picked = await showDatePicker(
    context: context,
    firstDate: tomorrow,
    lastDate: tomorrow.add(const Duration(days: 7)),
    initialDate: tomorrow,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1D4D61),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1D4D61),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    final dateOnly = DateTime(picked.year, picked.month, picked.day);
    final formatted = DateFormat('dd MMM yyyy').format(dateOnly);

    setState(() {
      selectedDate = formatted;
    });
  }
}


bool get showGoToAddressButton {
  return plasticKg != 0 ||
         glassKg != 0 ||
         paperKg != 0 ||
         metalKg != 0 ||
         ewasteKg != 0 ||
         cardKg != 0 ||
         bookskg != 0 ||
         cwirekg != 0 ||
         wirekg != 0 ||
         silverkg != 0 ||
         brasskg != 0 ||
         fridgekg != 0 ||
         ackg != 0 ||
         mixedkg != 0;
}



  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                        fontWeight: FontWeight.w800, color: Colors.black)),
          if (subtitle != null) ...[
          
            Text(subtitle,
                  style: TextStyle(
    color: Colors.grey[600],      
    fontWeight: FontWeight.w400,   
    height: 1.3,                   
  )),
          ],
        ],
      ),
    );
  }

void _showWelcomeDialog(BuildContext context,selectedItems) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: SingleChildScrollView( 
          padding: const EdgeInsets.all(20),
        child: PickupDateTimeSelector(names: selectedItems,),),
      );
    },
  );
}


@override
Widget build(BuildContext context) {

   void confirmAction(BuildContext context) async{
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFFF5F5F5),
      title: Semantics(
        label: 'confirmation',
        child: const Text(
          "Entered Maximum weight",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1D4D61),
          ),
        ),
      ),
      content: Semantics(
        label: 'Entered Maximum weight',
        child: const Text(
          "Weight is more than 4000+ and thanks for your input.",
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
       
        Semantics(
          label: 'ok',
          button: true,
          child: ElevatedButton(
            onPressed: () async{
              Navigator.pop(ctx);
             
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4D61),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("ok"),
          ),
        ),
      ],
    ),
  );
}

  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
           colors: [Color(0xFF1D4D61), Color(0xFF163B4B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: const Text(
        "Pickup",
        style: TextStyle(color: Colors.white,  fontSize: 16,
                        fontWeight: FontWeight.w800,),
      ),
     actions: [
    Padding(
      padding: const EdgeInsets.only(right: 3),
      child: GestureDetector(
        onTap: () {
            Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const PricePage()),
  );
          // your action here
        },
        child: Container(
          width: 70,
          padding: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF1D4D61), // same background
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white, // white border
              width: 1.8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Check",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            //  SizedBox(height: 0.5),
              Text(
                "Prices", // <-- dynamic price
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ],  leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Back',
      ),
      
    ),
    body:
    Stack(
      children: [
         SingleChildScrollView(
           //controller: _scrollController,
      padding: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _buildSectionTitle(
            "Add Estimated Weight",
            subtitle:
                "Select the approximate weight of your recyclables to help us send the right vehicle.",
          ),
          const SizedBox(height: 12),

//           ItemCard(
//             label: "Plastic",
//             value: plasticKg,
//             imageUrl: "assets/images/background.png",
//             onAdd: () => {
              
//                if (plasticKg > 400) {
//                confirmAction(context)
 
//     } else{
//       setState(() => plasticKg += 10)
//  //setState(() => _checkWeight(plasticKg))
//     }
//              },
//             onRemove: () => setState(() {
//               if (plasticKg > 0) plasticKg -= 10;
//             }),
//           ),
//           ItemCard(
//             label: "Glass",
//             value: glassKg,
//             imageUrl: "assets/icon/Cyklze_ikn.png",
//             onAdd: () => {
              
//                if (glassKg > 400) {
//                confirmAction(context)
 
//     }else{setState(() => glassKg += 10)}},
//             onRemove: () => setState(() {
//               if (glassKg > 0) glassKg -= 10;
//             }),
//           ),
//           ItemCard(
//             label: "Paper",
//             value: paperKg,
//             imageUrl: "assets/icon/Cyklze_ikn.png",
//             onAdd: () => {
              
//               if (paperKg > 400) {
//                confirmAction(context)
 
//     } else{setState(() => paperKg += 10)}},
//             onRemove: () => setState(() {
//               if (paperKg > 0) paperKg -= 10;
//             }),
//           ),
//           ItemCard(
//             label: "Metal",
//             value: metalKg,
//             imageUrl: "assets/icon/Cyklze_ikn.png",
//             onAdd: () => {
              
              
//                if (metalKg > 400) {
//                confirmAction(context)
 
//     } else{ setState(() => metalKg += 10)}},
//             onRemove: () => setState(() {
//               if (metalKg > 0) metalKg -= 10;
//             }),
//           ),
//           ItemCard(
//             label: "E-Waste",
//             value: ewasteKg,
//             imageUrl: "assets/icon/Cyklze_ikn.png",
//             onAdd: () => {
              
//               if (ewasteKg > 400) {
//                confirmAction(context)
 
//     }else { setState(() => ewasteKg += 10)}},
//             onRemove: () => setState(() {
//               if (ewasteKg > 0) ewasteKg -= 10;
//             }),
//           ),
//           ItemCard(
//             label: "Cardboard",
//             value: cardKg,
//             imageUrl: "assets/icon/Cyklze_ikn.png",
//             onAdd: () => {
              
//              if (cardKg > 400) {
//                confirmAction(context)
 
//     }  
//               else{setState(() => cardKg += 10)}},
//             onRemove: () => setState(() {
//               if (cardKg > 0) cardKg -= 10;
//             }),
//           ),

// GridView.count(
//   crossAxisCount: 2, // 👈 2 cards per row
//   shrinkWrap: true,  // 👈 allows it to be inside a scrollable parent
//   physics: const NeverScrollableScrollPhysics(), // avoid nested scroll
//   mainAxisSpacing: 10,
//   crossAxisSpacing: 10,
//   childAspectRatio: 0.8, // adjust card height/width ratio
//   padding: const EdgeInsets.all(8),
//   children: [
//     ItemCard(
//       label: "Plastic",
//       value: plasticKg,
//       imageUrl: "assets/images/background.png",
//       onAdd: () {
//         if (plasticKg > 400) {
//           confirmAction(context);
//         } else {
//           setState(() => plasticKg += 10);
//         }
//       },
//       onRemove: () => setState(() {
//         if (plasticKg > 0) plasticKg -= 10;
//       }),
//     ),
//     ItemCard(
//       label: "Glass",
//       value: glassKg,
//       imageUrl: "assets/icon/Cyklze_ikn.png",
//       onAdd: () {
//         if (glassKg > 400) {
//           confirmAction(context);
//         } else {
//           setState(() => glassKg += 10);
//         }
//       },
//       onRemove: () => setState(() {
//         if (glassKg > 0) glassKg -= 10;
//       }),
//     ),
//     ItemCard(
//       label: "Paper",
//       value: paperKg,
//       imageUrl: "assets/icon/Cyklze_ikn.png",
//       onAdd: () {
//         if (paperKg > 400) {
//           confirmAction(context);
//         } else {
//           setState(() => paperKg += 10);
//         }
//       },
//       onRemove: () => setState(() {
//         if (paperKg > 0) paperKg -= 10;
//       }),
//     ),
//     ItemCard(
//       label: "Metal",
//       value: metalKg,
//       imageUrl: "assets/icon/Cyklze_ikn.png",
//       onAdd: () {
//         if (metalKg > 400) {
//           confirmAction(context);
//         } else {
//           setState(() => metalKg += 10);
//         }
//       },
//       onRemove: () => setState(() {
//         if (metalKg > 0) metalKg -= 10;
//       }),
//     ),
//     ItemCard(
//       label: "E-Waste",
//       value: ewasteKg,
//       imageUrl: "assets/icon/Cyklze_ikn.png",
//       onAdd: () {
//         if (ewasteKg > 400) {
//           confirmAction(context);
//         } else {
//           setState(() => ewasteKg += 10);
//         }
//       },
//       onRemove: () => setState(() {
//         if (ewasteKg > 0) ewasteKg -= 10;
//       }),
//     ),
//     ItemCard(
//       label: "Cardboard",
//       value: cardKg,
//       imageUrl: "assets/icon/Cyklze_ikn.png",
//       onAdd: () {
//         if (cardKg > 400) {
//           confirmAction(context);
//         } else {
//           setState(() => cardKg += 10);
//         }
//       },
//       onRemove: () => setState(() {
//         if (cardKg > 0) cardKg -= 10;
//       }),
//     ),
//   ],
// )
// ,
    
      _buildSectionTitle(
            "General Recycables",
          ),
    GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(), // avoids nested scrolls
  padding: const EdgeInsets.all(8),
  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 140, // 👈 each item tries to be up to 250px wide
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    mainAxisExtent: 140, 
    childAspectRatio: 0.8, // keep your card proportions
  ),
  itemCount: 6,
  itemBuilder: (context, index) {
    // You can store your items in a list for cleaner code
    final items = [
      {
        'label': 'Plastic',
        'value': plasticKg,
        'url':"assets/images/plastic.jpg",
      'des': "We buy plastic products, including plastic bottles, plastic chairs, plastic containers, plastic buckets, plastic crates, plastic toys, plastic pipes, plastic jugs, plastic tubs, and plastic household items.",

        'onAdd': () {
          if (plasticKg > 4000) {
            confirmAction(context);
          } else {
            setState(() => plasticKg += 100);
          }
        },
        'onRemove': () => setState(() {
          if (plasticKg > 0) plasticKg -= 100;
        }),
      },
      {
        'label': 'Glass',
        'value': glassKg,
         'url':"assets/images/glass.jpg",
         'des': "We buy glass bottle products, including beer bottles, wine bottles, whisky bottles, soda bottles, juice bottles, sauce bottles, milk bottles, and other reusable glass containers.",

        'onAdd': () {
          if (glassKg > 4000) {
            confirmAction(context);
          } else {
            setState(() => glassKg += 100);
          }
        },
        'onRemove': () => setState(() {
          if (glassKg > 0) glassKg -= 100;
        }),
      },
      {
        'label': 'Paper',
        'value': paperKg,
         'url':"assets/images/news.jpg",
        'des': "We buy newspaper products, including old and used newspapers.",

        'onAdd': () {
          if (paperKg > 4000) {
            confirmAction(context);
          } else {
            setState(() => paperKg += 100);
          }
        },
        'onRemove': () => setState(() {
          if (paperKg > 0) paperKg -= 100;
        }),
      },
      {
        'label': 'Books',
        'value': bookskg,
         'url':"assets/images/books.jpg",
          'des': "We buy paper products, including books, shredded paper, pamphlets, magazines, notebooks, office paper, envelopes, and other paper materials, excluding newspapers.",

        'onAdd': () {
          
          if (bookskg > 4000) {
            confirmAction(context);
          } else {
            setState(() => bookskg += 100);
          }
        },
        'onRemove': () => setState(() {
          if (bookskg > 0) bookskg -= 100;
        }),
      },
      {
        'label': 'E-Waste',
        'value': ewasteKg,
         'url':"assets/images/ewaste.jpg",
        'des': "We buy electronic waste, including gas stoves, iron boxes, table fans, ceiling fans, refrigerators, washing machines, microwaves, computers, printers, and other household and office electronic appliances.",

        'onAdd': () {
          if (ewasteKg > 4000) {
            confirmAction(context);
          } else {
            setState(() => ewasteKg += 100);
          }
        },
        'onRemove': () => setState(() {
          if (ewasteKg > 0) ewasteKg -= 100;
        }),
      },
      {
        'label': 'Cardboard',
        'value': cardKg,
         'url':"assets/images/cardboard.jpg",
         'des':"We buy cardboard products, including book covers, food boxes, cosmetic boxes, shipping boxes, moving boxes, protective packaging, grocery bags, and envelopes.",
        'onAdd': () {
          if (cardKg > 4000) {
            confirmAction(context);
          } else {
            setState(() => cardKg += 100);
          }
        },
        'onRemove': () => setState(() {
          if (cardKg > 0) cardKg -= 100;
        }),
      },
    ];

    final item = items[index];

    return ItemCard(
      label: item['label'] as String,
      value: item['value'] as int,
      imageUrl: item['url'] as String,
      onAdd: item['onAdd'] as VoidCallback,
      onRemove: item['onRemove'] as VoidCallback,
       onTap:  () {
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return MaterialSlider(
        label: item['label'] as String,
        value: item['value'] as int,
        url: item['url'] as String,
          description: item['des'] as String,
        onAdd:item['onAdd'] as VoidCallback,
        onRemove: item['onRemove'] as VoidCallback
      );
    },
  );


            },
    );
  },
),
 
 
 _buildSectionTitle(
            "Metal Recycables",
          ),

              GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(), // avoids nested scrolls
  padding: const EdgeInsets.all(8),
  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 140, // 👈 each item tries to be up to 250px wide
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    mainAxisExtent: 140, 
    childAspectRatio: 0.8, // keep your card proportions
  ),
  itemCount: 5,
  itemBuilder: (context, index) {
    // You can store your items in a list for cleaner code
    final items = [
      {
        'label': 'Iron',
        'value': metalKg,
        'url':"assets/images/iron.jpg",
        'des': "We buy iron products, including iron rods, iron pipes, iron sheets, iron tins, gates, grills, frames, and all other iron and steel materials.",

        'onAdd': () {
          if (metalKg > 4000) {
            confirmAction(context);
          } else {
            setState(() => metalKg += 100);
          }
        },
        'onRemove': () => setState(() {
          if (metalKg > 0) metalKg -= 100;
        }),
      },
      {
        'label': 'Copper Wire',
        'value': cwirekg,
         'url':"assets/images/wcopper.jpg",
         'des': "We buy copper wire, including electrical copper wires, insulated copper wires, bare copper wires, and all other types of copper wiring.", 
        'onAdd': () {
          if (cwirekg > 4000) {
            confirmAction(context);
          } else {
            setState(() => cwirekg += 100);
          }
        },
        'onRemove': () => setState(() {
          if (cwirekg > 0) cwirekg -= 100;
        }),
      },
      {
        'label': 'Copper',
        'value': wirekg,
         'url':"assets/images/copper.jpg",
        'des': "We buy pure copper extracted from wires, including copper obtained by burning, stripping, or carving wires, and other refined copper materials.",

        'onAdd': () {
          if (wirekg > 400) {
            confirmAction(context);
          } else {
            setState(() => wirekg += 10);
          }
        },
        'onRemove': () => setState(() {
          if (wirekg > 0) wirekg -= 10;
        }),
      },
      {
        'label': 'Silver',
        'value': silverkg,
         'url':"assets/images/silver.jpg",
         'des': "We buy silver items, including silver plates, bowls, cups, jewelry, coins, utensils, ornaments, and all other silver products.",

        'onAdd': () {
          if (silverkg > 4000) {
            confirmAction(context);
          } else {
            setState(() => silverkg += 100);
          }
        },
        'onRemove': () => setState(() {
          if (silverkg > 0) silverkg -= 100;
        }),
      },
      {
        'label': 'Brass',
        'value': brasskg,
         'url':"assets/images/brass.jpg",
         'des': "We buy brass items, including brass vessels, taps, valves, fittings, decorative pieces, utensils, and all other brass products.",

        'onAdd': () {
          if (brasskg > 400) {
            confirmAction(context);
          } else {
            setState(() => brasskg += 10);
          }
        },
        'onRemove': () => setState(() {
          if (brasskg > 0) brasskg -= 10;
        }),
      },
     
    ];

    final item = items[index];

    return ItemCard(
      label: item['label'] as String,
      value: item['value'] as int,
      imageUrl: item['url'] as String,
      onAdd: item['onAdd'] as VoidCallback,
      onRemove: item['onRemove'] as VoidCallback,
      onTap:  () {
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return MaterialSlider(
        label: item['label'] as String,
        value: item['value'] as int,
        url: item['url'] as String,
         description: item['des'] as String,
        onAdd:item['onAdd'] as VoidCallback,
        onRemove: item['onRemove'] as VoidCallback
      );
    },
  );


            },
    );
  },
),
  
  
  _buildSectionTitle("E-waste"),
              GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(), // avoids nested scrolls
  padding: const EdgeInsets.all(8),
  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 151, // 👈 each item tries to be up to 250px wide
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    mainAxisExtent: 151, 
    childAspectRatio: 0.8, // keep your card proportions
  ),
  itemCount: 3,
  itemBuilder: (context, index) {
    // You can store your items in a list for cleaner code
    final items = [
      {
        'label': 'Fridge',
        'value': fridgekg,
        'url':"assets/images/fridge.jpg",
        'des': "We buy all types of fridges, including single-door and double-door models, as long as they have a compressor.",

        'onAdd': () {
          if (fridgekg > 400) {
            confirmAction(context);
          } else {
            setState(() => fridgekg += 1);
          }
        },
        'onRemove': () => setState(() {
          if (fridgekg > 0) fridgekg -= 1;
        }),
      },
      {
        'label': 'Ac',
        'value': ackg,
         'url':"assets/images/ac.jpg",
        'des': "We buy complete AC units, including window and split ACs, as long as they have all their parts intact.",

        'onAdd': () {
          if (ackg > 400) {
            confirmAction(context);
          } else {
            setState(() => ackg += 1);
          }
        },
        'onRemove': () => setState(() {
          if (ackg > 0) ackg -= 1;
        }),
      },
      {
        'label': 'Mixed',
        'value': mixedkg,
         'url':"assets/images/ewaste.jpg",
       'des': "We buy e-waste, including non-commercial wires, hair dryers, printers, CPUs, ovens, mixers, TVs, keyboards, and other household electronic appliances.",

        'onAdd': () {
          if (mixedkg > 4000) {
            confirmAction(context);
          } else {
            setState(() => mixedkg += 100);
          }
        },
        'onRemove': () => setState(() {
          if (mixedkg > 0) mixedkg -= 100;
        }),
      },
   
    ];

    final item = items[index];

    return ItemCard(
      label: item['label'] as String,
      value: item['value'] as int,
      imageUrl: item['url'] as String,
      onAdd: item['onAdd'] as VoidCallback,
      onRemove: item['onRemove'] as VoidCallback,
       onTap:  () {
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return MaterialSlider(
        label: item['label'] as String,
        value: item['value'] as int,
      
         description: item['des'] as String,
        url: item['url'] as String,
        onAdd:item['onAdd'] as VoidCallback,
        onRemove: item['onRemove'] as VoidCallback
      );
    },
  );


            },
    );
  },
),
   const SizedBox(height: 40),
  
          const SizedBox(height: 128),

//           _buildSectionTitle("Select a Pickup Date"),
      
//           Text(
//             "Select an appropriate date that suits you best.",
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: Colors.grey[600],
//                   height: 1.3,
//                 ),
//           ),
//           const SizedBox(height: 10),

//           Semantics(
//             label: 'Select pickup date',
//             child: InkWell(
//               onTap: () async{
//                await _pickDate();
//               },
//               child: Card(
//                 elevation: 3,
//                 color: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Container(  decoration: BoxDecoration(
//                   border: Border.all(color: Colors.black),
//                    borderRadius: BorderRadius.circular(12),
//                 ),
//                   child: ListTile(
//                     leading: const CircleAvatar(
//                       backgroundColor: Color(0xFF1D4D61),
//                       child: Icon(Icons.calendar_today, color: Colors.white),
//                     ),
//                     title: Text(
//                       selectedDate == null
//                           ? "Choose a date"
//                           : "$selectedDate",
//                       style: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.w500),
//                     ),
//                     trailing:const Icon(Icons.chevron_right_rounded)
//                     // ElevatedButton(
//                     //   style: ElevatedButton.styleFrom(
//                     //     backgroundColor: Color(0xFF1D4D61),
//                     //     foregroundColor: Colors.white,
//                     //     shape: RoundedRectangleBorder(
//                     //         borderRadius: BorderRadius.circular(8)),
//                     //   ),
//                     //   onPressed: _pickDate,
//                     //   child: const Text("Select"),
//                     // ),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 28),

//           _buildSectionTitle("Select Time Slot"),
        
//           Text(
//             "Select your preferred time slot.",
//             style: TextStyle(
//                   color: Colors.grey[600],
//                   height: 1.3,
//                 ),
//           ),
//           const SizedBox(height: 10),

//           // Wrap(
//           //   spacing: 12,
//           //   runSpacing: 12,
//           //   children: [
//           //     TimeChip(
//           //       label: "8 AM - 11 AM",
//           //       selectedTimeRange: selectedTimeRange,
//           //       onSelected: (value) =>
//           //           setState(() => selectedTimeRange = value),
//           //     ),
//           //     TimeChip(
//           //       label: "11 AM - 1 PM",
//           //       selectedTimeRange: selectedTimeRange,
//           //       onSelected: (value) =>
//           //           setState(() => selectedTimeRange = value),
//           //     ),
//           //     TimeChip(
//           //       label: "1 PM - 3 PM",
//           //       selectedTimeRange: selectedTimeRange,
//           //       onSelected: (value) =>
//           //           setState(() => selectedTimeRange = value),
//           //     ),
//           //     TimeChip(
//           //       label: "3 PM - 6 PM",
//           //       selectedTimeRange: selectedTimeRange,
//           //       onSelected: (value) =>
//           //           setState(() => selectedTimeRange = value),
//           //     ),
//           //   ],
//           // ),

       

//           Semantics(
//             button: true,
//             label: 'Continue to enter address with selected date and time',
//             child: Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                     colors: [Color(0xFF1D4D61), Color(0xFF163B4B)],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
  
//               ),
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.transparent,
//                   shadowColor: Colors.transparent,
//                   minimumSize: const Size(double.infinity, 52),
//                 ),
//                 onPressed: () async {
//                   if (selectedTimeRange == null) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                           content: Text("Please select a time slot")),
//                     );
//                     return;
//                   }

//  if (selectedDate == null) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                           content: Text("Please a pickup select date")),
//                     );
//                     return;
//                   }



//                   final date = selectedDate.toString();
//                   final time = selectedTimeRange.toString();

//                   final List<String> selectedItems = [];
//                   if (plasticKg > 0) selectedItems.add("Plastic: $plasticKg Kg");
//                   if (glassKg > 0) selectedItems.add("Glass: $glassKg Kg");
//                   if (paperKg > 0) selectedItems.add("Paper: $paperKg Kg");
//                   if (metalKg > 0) selectedItems.add("Metal: $metalKg Kg");
//                   if (ewasteKg > 0) selectedItems.add("E-Waste: $ewasteKg Kg");
//                   if (cardKg > 0) selectedItems.add("Cardboard: $cardKg Kg");
//                   if (bookskg > 0) selectedItems.add("Books: $bookskg Kg");
//                   if (cwirekg > 0) selectedItems.add("Copper : $cwirekg Kg");
//                   if (wirekg > 0) selectedItems.add("Copper wire: $wirekg Kg");
//                   if (silverkg > 0) selectedItems.add("Silver: $silverkg Kg");
//                   if (brasskg > 0) selectedItems.add("Silver: $brasskg Kg");
//                    if (fridgekg > 0) selectedItems.add("Fridge: $fridgekg Qty");
//                    if (ackg > 0) selectedItems.add("Ac: $ackg Qty");
//                    if (mixedkg > 0) selectedItems.add("mixed waste: $mixedkg Kg");
                   



//   // int bookskg = 0;
//   // int cwirekg = 0;
//   // int wirekg = 0;
//   // int silverkg = 0;
//   // int brasskg = 0;
//   // int fridgekg = 0;
//   // int ackg = 0;
//   // int mixedkg = 0;

//  if (selectedItems.isEmpty) {
//                      ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                           content: Text("Please enter the estimated weight of recycables.")),
//                     );
//                     return;
//                   }
//                   await Provider.of<PickupProvider>(context, listen: false)
//                       .setPickupDetails(
//                     date: date,
//                     time: time,
//                     type: "General",
//                     items: selectedItems,
//                   );

// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => CreativeAddressPage(
//       selectedTimeRange: selectedTimeRange.toString(),
//       selectedDate: selectedDate.toString(),
//       selectedType: "General", 
//       selectedItems: selectedItems, 
//     ),
//   ),
// );




//                 },
//                 child: const Text(
//                   "Continue to Address",
//                   style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.white),
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 20),
        ],
      ),
    ),
      if (showGoToAddressButton == true)
        Positioned(
          bottom: 20,
          right: 20,
          child: InkWell(
            onTap:(){
              
              
                  final List<String> selectedItems = [];
                if (plasticKg > 0) selectedItems.add("Plastic: $plasticKg Kg");
if (glassKg > 0) selectedItems.add("Glass: $glassKg Kg");
if (paperKg > 0) selectedItems.add("Paper: $paperKg Kg");
if (metalKg > 0) selectedItems.add("Metal: $metalKg Kg");
if (ewasteKg > 0) selectedItems.add("E-Waste: $ewasteKg Kg");
if (cardKg > 0) selectedItems.add("Cardboard: $cardKg Kg");
if (bookskg > 0) selectedItems.add("Books: $bookskg Kg");
if (cwirekg > 0) selectedItems.add("Copper: $cwirekg Kg");
if (wirekg > 0) selectedItems.add("Copper Wire: $wirekg Kg");
if (silverkg > 0) selectedItems.add("Silver: $silverkg Kg");
if (brasskg > 0) selectedItems.add("Brass: $brasskg Kg");
if (fridgekg > 0) selectedItems.add("Fridge: $fridgekg Qty");
if (ackg > 0) selectedItems.add("AC: $ackg Qty");
if (mixedkg > 0) selectedItems.add("Mixed Waste: $mixedkg Kg");

              
              _showWelcomeDialog(context,selectedItems);},
            //_scrollToBottom,
            child: Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1D4D61), // existing color
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.20),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    child: const Text(
      "Select a pickup date",
      style: TextStyle(
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
    )
    
  
  );
}

}



class MaterialSlider extends StatefulWidget {
  final String label;
  final int value;
  final String url;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final String description;

  const MaterialSlider({
    super.key,
    required this.label,
    required this.value,
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
    return Container(
      width: width, // full parent width
      height: MediaQuery.of(context).size.height * 0.5, // mid-screen height
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
            // Small drag handle
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            // Image (50% of parent width)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.url,
                height: imageSize,
                width: imageSize,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 12),

            // Label
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),
    Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                  onPressed: () {
                    widget.onRemove();
                    if (!mounted) return;
                    setState(() {
                       if (add100.contains(lbl)) {
    num = (num - 100).clamp(0, 9999);
  } else if (add10.contains(lbl)) {
    num = (num - 10).clamp(0, 9999);
  } else if (add1.contains(lbl)) {
    num = (num - 1).clamp(0, 9999);
  } else {
    num = (num - 10).clamp(0, 9999); // default
  }  });
                  },
                ),
                Text(
                  num.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                  onPressed: () {
                    widget.onAdd();
                    if (!mounted) return;
                    setState(() {
                      if (add100.contains(lbl)) {
  num += 100;
} else if (add10.contains(lbl)) {
  num += 10;
} else if (add1.contains(lbl)) {
  num += 1;
} else {
  num += 10; // default
}
                    });
                  },
                ),
              ],
            ),
        SizedBox(height: 10,),
            // Description Section,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Add/Remove controls
          ],
        ),
      ),
    );
  }
}
