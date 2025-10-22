







import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cyklze/Views/error.dart';
import 'package:cyklze/Views/offline.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum PageState {  loggedIn, offline, error }
class PricePage extends StatefulWidget {
  const PricePage({super.key});

  @override
  State<PricePage> createState() => _PricePageState();
}

class _PricePageState extends State<PricePage> {
  List<Map<String, dynamic>> products = [];
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
     print("************************before");
 if (!await hasInternetConnection()) {
  print("************* offline (no real internet)");
      setState(() => _state = PageState.offline);
  return;
}

     print("************************after");

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
          products = jsonData
              .map((e) => {
                    "name": e['product'] ?? e['name'] ?? '',
                    "price": e['pricePerKg'] ?? e['price'] ?? -1,
                  })
              .where((p) => p["name"].toString().isNotEmpty && p["price"] >= 0)
              .toList();
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
                : _buildContent(),
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



Widget _buildContent() {
  return ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    itemCount: products.length + 1, 
    separatorBuilder: (_, __) => const SizedBox(height: 6),
    itemBuilder: (context, index) {
      if (index == 0) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "These are the prices we’re offering per kg for each type of scrap material you sell to us.",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400, 
              color: Colors.black54,
            ),
            textAlign: TextAlign.left,
          ),
        );

      }

      final product = products[index - 1]; 
      return _buildProductCard(product["name"], product["price"]);
    },
  );
}




Widget _buildProductCard(String name, int price) {
  return Container(decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: Colors.transparent),
),

    child: Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
     
        Expanded(
          child: Text(
            name,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
    
        const SizedBox(width: 8),
    
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "₹ $price /kg",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 2),
            const Text(
              "Per kilogram",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ],
    ),
    ),
  );
}




}
