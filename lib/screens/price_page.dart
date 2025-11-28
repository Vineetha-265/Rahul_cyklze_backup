







import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cyklze/Provider/pickup_provider.dart';
import 'package:cyklze/Views/error.dart';
import 'package:cyklze/Views/offline.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

enum PageState {  loggedIn, offline, error }
class PricePage extends StatefulWidget {
  const PricePage({super.key});

  @override
  State<PricePage> createState() => _PricePageState();
}

class _PricePageState extends State<PricePage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> general = [];
  List<Map<String, dynamic>> metal = [];
  List<Map<String, dynamic>> ewaste = [];
  bool isLoading = true;
  bool hasError = false;

  static const String base =
      "https://20pnz6cr8e.execute-api.ap-south-1.amazonaws.com/cyklzee/cyklzee";
  static const String productUrl = "$base/product";

  PageState _state = PageState.loggedIn;
Future<bool> hasInternetConnection() async {
  final connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.none) {
    return false;
  }

  try {
    final result = await InternetAddress.lookup('example.com')
        .timeout(const Duration(seconds: 3));

    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true; 
    }
    return false;
  } on SocketException catch (_) {
    return false;
  } on Exception catch (_) {
    return false;
  }
}
  Future<void> fetchProducts() async {
      setState(() {
    _state = PageState.loggedIn;
    });
   
    setState(() {
      isLoading = true;
      hasError = false;
    });
final   provider = Provider.of<PickupProvider>(context, listen: false);
  if (!await provider.hasInternetConnection()) {
       setState(() => _state = PageState.offline);
    return;
  }
//  if (!await hasInternetConnection()) {
//   print("************* offline (no real internet)");
//       setState(() => _state = PageState.offline);
//   return;
// }


    try {
      final res = await http.get(Uri.parse(productUrl));
      if (res.statusCode == 200) {
            setState(() => _state = PageState.loggedIn);
        final body = res.body.trim();
        List<dynamic> jsonData;

        if (body.startsWith("[")) {
          jsonData = jsonDecode(body);
        } else {
          final obj = jsonDecode(body);
          jsonData = obj['items'] ?? obj['data'] ?? [];
        }

        setState(() {
          metal = jsonData
              .map((e) => {
                    "name": e['product'] ?? e['name'] ?? '',
                    "category": e['cat'] ?? e['category'] ?? '',
                    "price": e['pricePerKg'] ?? e['price'] ?? -1,
                  })
              .where((p) => p["category"].toString() == "metal")
              .toList();
                general = jsonData
              .map((e) => {
                    "name": e['product'] ?? e['name'] ?? '',
                    "category": e['cat'] ?? e['category'] ?? '',
                    "price": e['pricePerKg'] ?? e['price'] ?? -1,
                  })
              .where((p) => p["category"].toString() == "general")
              .toList();
               ewaste = jsonData
              .map((e) => {
                    "name": e['product'] ?? e['name'] ?? '',
                    "category": e['cat'] ?? e['category'] ?? '',
                    "price": e['pricePerKg'] ?? e['price'] ?? -1,
                  })
              .where((p) => p["category"].toString() == "ewaste")
              .toList();
//                general = products.where((p) => p['category'] == 'general').toList();
//  metal = products.where((p) => p['category'] == 'metal').toList();
//  ewaste = products.where((p) => p['category'] == 'ewaste').toList();

          isLoading = false;
        });
      } else {
         setState(() => _state = PageState.error);
      }
    } catch (e) {
   
      setState(() {
        _state = PageState.loggedIn;
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,

      // const Color(0xFFF7F9FB),
      appBar: 
      AppBar(
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
  "Today's Scrap Prices",
  style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 16, 
  ),
)
,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
    
      body: _buildByState(),
    );
  }

Widget _mainContent() {
  return RefreshIndicator(
        onRefresh: fetchProducts,
        child: isLoading
            ? _buildLoading()
            : hasError
                ? ErrorRetry(
              message: "Something went wrong",
              onRetry: fetchProducts,)
                : _buildContent(general,metal),
      );
}

    Widget _buildByState() {
    switch (_state) {
     
   
      case PageState.loggedIn:
        return _mainContent();
      case PageState.error:
        return  ErrorRetry(
              message: "Something went wrong",
              onRetry: fetchProducts,);
      case PageState.offline:
        return OfflineRetry(
      onRetry: fetchProducts, // your function
    );
     
    }
  }


  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 110,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }



// Widget _buildContent() {
//   return SingleChildScrollView(
//     child: Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("General",  style: TextStyle(
//                 color: Color(0xFF1D4D61),
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//               ),),
      
//           ListView.separated(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             itemCount: general.length + 1,
//             separatorBuilder: (_, __) => const SizedBox(height: 6),
//             shrinkWrap: true, // ✅ allows ListView to take only needed space
//             physics: const NeverScrollableScrollPhysics(), // ✅ disable inner scroll
//             itemBuilder: (context, index) {
//               if (index == 0) {
//                 return const SizedBox();
//                 //  Padding(
//                 //   padding: EdgeInsets.all(8.0),
//                 //   child: Text(
//                 //     "These are the prices we’re offering per kg for each type of scrap material you sell to us.",
//                 //     style: TextStyle(
//                 //       fontSize: 14,
//                 //       fontWeight: FontWeight.w400,
//                 //       color: Colors.black54,
//                 //     ),
//                 //     textAlign: TextAlign.left,
//                 //   ),
//                 // );
//               }
      
//               final product = general[index - 1];
//               return Container(
//                 child: _buildProductCard(
//                   product["name"],
//                   product["price"],
//                   product["category"],
//                 ),
//               );
//             },
//           ),
      
//           const SizedBox(height: 16),
//           const Text("Metal" , style: TextStyle(
//                 color: Color(0xFF1D4D61),
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//               ),),
      
//           ListView.separated(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             itemCount: metal.length + 1,
//             separatorBuilder: (_, __) => const SizedBox(height: 6),
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemBuilder: (context, index) {
//               if (index == 0) {
//                  return const SizedBox();
//               }
      
//               final product = metal[index - 1];
//               return Container(
//                 child: _buildProductCard(
//                   product["name"],
//                   product["price"],
//                   product["category"],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     ),
//   );
// }

// Widget _platform(String name, int price,String category) {
// return Container(
//   child: Column(children: [
//     if (category == "General")
//     _buildProductCard(name, price),
    
//   ],),
// );
// }



Widget _buildProductCard(String name, String price, String cat) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF8F9FA),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFE0E0E0)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.05),
          spreadRadius: 1,
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14, // slightly smaller
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1D1D),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2), // tighter spacing
                Text(
                  cat,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // Right: Price
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D4D61),
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    ),
  );
}

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6), // reduce vertical spacing
    child: Text(
      title,
      style: const TextStyle(
        color: Color(0xFF1D4D61),
        fontWeight: FontWeight.bold,
        fontSize: 18, // slightly smaller
      ),
    ),
  );
}

Widget _buildContent(List<Map<String, dynamic>> general, List<Map<String, dynamic>> metal) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(12), // reduce padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // General Section
          _buildSectionTitle("General"),
          Text(
            "Prices we offer per kilogram for general scrap materials:",
            style: TextStyle(color: Colors.grey[700], fontSize: 12), // smaller font
          ),
          const SizedBox(height: 6), // tighter spacing

          ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: general.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final product = general[index];
              return _buildProductCard(
                product["name"] ?? "",
                product["price"] ?? "",
                product["category"] ?? "",
              );
            },
          ),

          const SizedBox(height: 16), // smaller than before

          // Metal Section
          _buildSectionTitle("Metal"),
          Text(
            "Metal scrap prices offered per kilogram:",
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
          const SizedBox(height: 6),

          ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: metal.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final product = metal[index];
              return _buildProductCard(
                product["name"] ?? "",
                product["price"] ?? "",
                product["category"] ?? "",
              );
            },
          ),
        
        
           const SizedBox(height: 16), // smaller than before

          // Metal Section
          _buildSectionTitle("E-waste"),
          Text(
            "E-waste scrap prices",
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
          const SizedBox(height: 6),

          ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: ewaste.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final product = ewaste[index];
              return _buildProductCard(
                product["name"] ?? "",
                product["price"] ?? "",
                product["category"] ?? "",
              );
            },
          ),
        
        
        
        ],
      ),
    ),
  );
}




// Widget _buildProductCard(String name, String price , String cat) {
//   return  Container(decoration: BoxDecoration(
//   color: Colors.white,
//   borderRadius: BorderRadius.circular(12),
//   border: Border.all(color: Colors.transparent),
// ),

//     child: Padding(
//     padding: const EdgeInsets.all(12),
//     child: Row(
//      mainAxisAlignment: MainAxisAlignment.spaceBetween,
//      crossAxisAlignment: CrossAxisAlignment.start,
//      children: [
    
//        Expanded(
//          child: Text(
//            name,
//            textAlign: TextAlign.left,
//            style: const TextStyle(
//              fontSize: 16,
//              fontWeight: FontWeight.w600,
//              color: Colors.black,
//            ),
//            overflow: TextOverflow.ellipsis,
//          ),
//        ),
            
//        const SizedBox(width: 8),
      
//        Column(
//          crossAxisAlignment: CrossAxisAlignment.end,
//          children: [
//            Text(
//              price,
//              style: const TextStyle(
//                fontSize: 15,
//                fontWeight: FontWeight.w700,
//                color: Colors.black,
//              ),
//              textAlign: TextAlign.right,
//            ),
//           //  const SizedBox(height: 2),
//           //  const Text(
//           //    "Per kilogram",
//           //    style: TextStyle(
//           //      fontSize: 12,
//           //      color: Colors.black54,
//           //    ),
//           //    textAlign: TextAlign.right,
//           //  ),
//          ],
//        ),
//      ],
//             ),
//     ),
//   );
// }




}
