// requests_page.dart
import 'dart:convert';
import 'dart:io';
import 'package:cyklze/Provider/pickup_provider.dart';
import 'package:cyklze/SecureStorage/securestorage.dart';
import 'package:cyklze/Views/error.dart';
import 'package:cyklze/Views/loading.dart';
import 'package:cyklze/Views/loginrequird.dart';
import 'package:cyklze/Views/offline.dart';
import 'package:cyklze/enums/page_state.dart';
import 'package:cyklze/screens/verification.dart';
import 'package:cyklze/widgets/invoice.dart';
import 'package:cyklze/widgets/statusbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';

const String ORDERS_URL =
    "https://20pnz6cr8e.execute-api.ap-south-1.amazonaws.com/cyklzee/cyklzee/order";
const String TOKEN_URL =
    "https://20pnz6cr8e.execute-api.ap-south-1.amazonaws.com/cyklzee/cyklzee/handletoken";

class RequestItem {
  final String pickupType;
  final String time;
  final String status;
  final String details;
  final String code;

  RequestItem({
    required this.pickupType,
    required this.code,
    required this.time,
    required this.status,
    required this.details,
  });

  factory RequestItem.fromJson(Map<String, dynamic> j) {
    return RequestItem(
      pickupType: j['Pickuptype']?.toString() ?? '',
      time: j['time']?.toString() ?? '',
      status: j['Status']?.toString() ?? '',
      code: j['Status_Code']?.toString() ?? '',

      details:  "Materials: ${j['Selected_items']}\nCash Received: ${j['Cash_received']}\nPlaced On: ${j['time']}\nStatus: ${j['Status']}\nAddress: ${j['Address']}\nSet Date: ${j['Set_date']}\nUpdates: ${j['Status_comments']}"
  
    );
  }
}



class NetworkUtils {
  static Future<bool> isNetworkAvailable() async {
    final c = await Connectivity().checkConnectivity();
    return c != ConnectivityResult.none;
  }
}
class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}



class _RequestsPageState extends State<RequestsPage> {
  Pagestate _state = Pagestate.loading;
  final List<RequestItem> _items = [];
  var showno = false;
  int _refreshAttempts = 0;
  static const int _maxRefreshAttempts = 1; 
  final _scaffoldKey = GlobalKey<ScaffoldState>();

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkNetworkAndProceed();
  });
}

  Future<void> _checkNetworkAndProceed() async {
    final online = await NetworkUtils.isNetworkAvailable();
    if (!mounted) return;
    if (!online) {
      setState(() => _state = Pagestate.offline);
      return;
    }
    setState(() => _state = Pagestate.loading);
    await _getOrders();
  }

  Future<void> _getOrders() async {
    setState(() {
      _state = Pagestate.loading;
      _items.clear();
    });
final   provider = Provider.of<PickupProvider>(context, listen: false);
  if (!await provider.hasInternetConnection()) {
    setState(() => _state = Pagestate.offline);
    return;
  }
    final accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) {
      setState(() {
      
        _state = Pagestate.notLogged;
      });
      return;
    }

    try {
      final resp = await http.get(
        Uri.parse(ORDERS_URL),
        headers: {
          'Authorization': accessToken,
          'Content-Type': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final data = body['data'];
        if (data == null || (data is List && data.isEmpty)) {
          setState(() {
         showno = true;
            _state = Pagestate.loggedIn;
          });
          return;
        }

        final list = <RequestItem>[];
        if (data is List) {
          for (var e in data) {
            try {
              if (e is Map<String, dynamic>) {
                list.add(RequestItem.fromJson(e));
              } else if (e is Map) {
                list.add(RequestItem.fromJson(Map<String, dynamic>.from(e)));
              } else {
                list.add(RequestItem(
                    pickupType: 'Order',
                    time: '',
                    status: '',
                    code:"",
                    details: e.toString()));
              }
            } catch (_) {
           
            }
          }
        }else{
showno = true;
        }

        setState(() {
          _items.addAll(list);
       
          _state = Pagestate.loggedIn;
        });
        return;
      }

      final raw = resp.body;
      String errMsg = '';
      try {
        final parsed = jsonDecode(raw);
        if (parsed is Map && parsed.containsKey('error')) {
          errMsg = parsed['error'].toString();
        } else if (parsed is Map && parsed.containsKey('message')) {
          errMsg = parsed['message'].toString();
        }
      } catch (_) {
        errMsg = raw ?? 'Unknown error';
      }

      if ((resp.statusCode == 401 ||
              errMsg.toLowerCase().contains('invalid token') ||
              errMsg.toLowerCase().contains('token has expired')) &&
          _refreshAttempts < _maxRefreshAttempts) {
        _refreshAttempts++;
        await _refreshAccessToken("order");
        return;
      }

      setState(() {
      
        _state = Pagestate.notLogged;
      });
    } on SocketException {
      setState(() {
      _state = Pagestate.error;
      });
    } catch (e) {
      setState(() {
 
        _state = Pagestate.error;
      });
    }
  }

  Future<void> _refreshAccessToken(String type) async {
    setState(() {
      _state = Pagestate.loading;
    });

    final refresh = await SecureStorage.getRefreshToken();
    if (refresh == null) {
      setState(() {
      
        _state = Pagestate.notLogged;
      });
      return;
    }

    try {
      final resp = await http.put(Uri.parse(TOKEN_URL),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refresh}));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final newAccess = body['accessToken']?.toString();
        final newRefresh = body['refreshToken']?.toString();
        if (newAccess != null) await SecureStorage.saveAccessToken(newAccess);
        if (newRefresh != null) await SecureStorage.saveRefreshToken(newRefresh);

        await _getOrders();
        return;
      } else {
        setState(() {
       
          _state = Pagestate.notLogged;
        });
      }
    } on SocketException {
      setState(() {
     
        _state = Pagestate.offline;
      });
    } catch (e) {
      setState(() {
    
        _state = Pagestate.error;
      });
    }
  }


  Future<void> _refreshAccessToken1(RequestItem type) async {
    setState(() {
      _state = Pagestate.loading;
    });

    final refresh = await SecureStorage.getRefreshToken();
    if (refresh == null) {
      setState(() {
      
        _state = Pagestate.notLogged;
      });
      return;
    }

    try {
      final resp = await http.put(Uri.parse(TOKEN_URL),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refresh}));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final newAccess = body['accessToken']?.toString();
        final newRefresh = body['refreshToken']?.toString();
        if (newAccess != null) await SecureStorage.saveAccessToken(newAccess);
        if (newRefresh != null) await SecureStorage.saveRefreshToken(newRefresh);

        await _cancelOrder(type);
        return;
      } else {
        setState(() {
       
          _state = Pagestate.notLogged;
        });
      }
    } on SocketException {
      setState(() {
     
        _state = Pagestate.offline;
      });
    } catch (e) {
      setState(() {
    
        _state = Pagestate.error;
      });
    }
  }


void _showOrderDetails(RequestItem item) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 500, // prevents dialog from growing too large
        ),
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: 'Order Details for ${item.pickupType}',
                  child: Text(
                    '${item.pickupType} • ${item.time}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 10.0),

                Semantics(
                  label: 'Order details: ${item.details}',
                  child: Text(
                    item.details,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),
                  ),
                ),

                const SizedBox(height: 20.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Semantics(
                      button: true,
                      label: 'Close the order details dialog',
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF1D4D61),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      flexibleSpace: Semantics(
        label: 'AppBar background gradient',
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
             colors: [Color(0xFF1D4D61), Color(0xFF163B4B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      title: Semantics(
        label: 'Pickups screen title',
        child: const Text(
          "Pickups",
          style: TextStyle(color: Colors.white,   fontSize: 16,
                        fontWeight: FontWeight.w800),
        ),
      ),
      leading: Semantics(
        button: true,
        label: 'Back button',
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      elevation: 0,
    ),
    body: Semantics(
      label: 'Main body of the Pickups screen',
      child: Container(
       color: Colors.grey[100],

        child: _buildBodyByState(),
      ),
    ),
  );
}

  Widget _buildBodyByState() {
    switch (_state) {
      case Pagestate.loading:
        return const ElegantLoadingOverlay();
        
      case Pagestate.offline:
        return OfflineRetry(
      onRetry: _getOrders, 
    ); 
      case Pagestate.notLogged:
        return LoginRequired(
        message: "Please log in to see your pickups",
        onLogin: () async{
         final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PhoneVerificationPage()),
          );
          if (result == true) {
            await _getOrders();
          }else{
            setState(() {
              _state = Pagestate.notLogged;
            });
          }
        },
      );
      case Pagestate.error:
        return  ErrorRetry(
              message: "Something went wrong",
              onRetry: _getOrders,
            ); 
      case Pagestate.loggedIn:
        return Column(
          children: [
           if(showno) Center(
             child: Text(
               "No pickups placed",
               style: TextStyle(
                 fontSize: 18,
                 fontWeight: FontWeight.w500,
                 color: Colors.grey.shade600,
               ),
               textAlign: TextAlign.center,
             ),
           )
,
            Expanded(child: _listView()),
          ],
        );
    }
  }



Future<void> _cancelOrder(RequestItem it) async{
final   provider = Provider.of<PickupProvider>(context, listen: false);
  if (!await provider.hasInternetConnection()) {
    setState(() => _state = Pagestate.offline);
    return;
  }
  setState(() {
           _state = Pagestate.loading;
          
        });
  final accessToken = await SecureStorage.getAccessToken();
  final refreshToken = await SecureStorage.getRefreshToken();

  if (accessToken == null) {
   setState(() {
        
          _state = Pagestate.notLogged;
        });
    return;
  }





  try {
  final resp = await http.put(
  Uri.parse("https://20pnz6cr8e.execute-api.ap-south-1.amazonaws.com/cyklzee/cyklzee/order"),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'accessToken': accessToken,
    'message': 'Cancel order: ${it.time}',
    'time': it.time, 
  }),
);


    if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Successfully Cancelled'),
      duration: Duration(seconds: 2), 
    ),
  );
    await _getOrders();
      return;
    }

     else {
     await _refreshAccessToken1(it);

    }
  } catch (e) {
  setState(() {
   
          _state = Pagestate.error;
        });
  }
}

void confirmCancel(BuildContext context, RequestItem it) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFFF5F5F5),
      title: Semantics(
        label: 'Cancel pickup confirmation title',
        child: const Text(
          "Are you sure you want to cancel your current pickup?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1D4D61),
          ),
        ),
      ),
      content: Semantics(
        label: 'Cancel pickup confirmation message',
        child: const Text(
          "This action cannot be undone.",
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        Semantics(
          label: 'Do not cancel action',
          button: true,
          child: TextButton(
  onPressed: () => Navigator.pop(ctx),
  style: TextButton.styleFrom(
    backgroundColor: const Color(0xFF1D4D61), 
    foregroundColor: Colors.white, 
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: const Text("No"),
),

        ),
        Semantics(
          label: 'Confirm cancel action',
          button: true,
          child: ElevatedButton(
            onPressed: () async{
              Navigator.pop(ctx);
             await _cancelOrder(it); 
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4D61),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Cancel Pickup"),
          ),
        ),
      ],
    ),
  );
}


Widget _listView() {

// Helper function to get status color



  return ListView.separated(
   padding: const EdgeInsets.symmetric(vertical: 12),

    itemCount: _items.length,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (context, i) {
      final it = _items[i];
      final isDelivered = it.status.toLowerCase().contains('deliv');
      final isCancelled = it.status.toLowerCase() == 'pending';

  return Semantics(
  label: 'Order details for ${it.pickupType} scheduled on ${it.time}',
  child: Container(
    color: Colors.white,
    padding: const EdgeInsets.all(12), // reduced from 14
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Semantics(
                  label: 'Pickup icon',
                  child: CircleAvatar(
                    radius: 22, // slightly smaller
                    backgroundColor: Colors.teal.shade50,
                    child: const Icon(
                      Icons.local_shipping,
                      color: Colors.teal,
                      size: 20, // smaller icon
                    ),
                  ),
                ), 
                if(it.status == "Completed"|| it.status == "completed"|| it.status == "done"|| it.status == "Done")
                TextButton.icon(
                onPressed: () =>{
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => InvoicePage(item: it,)),
    )
  },
               
                label: const Text("Payout", style: TextStyle(fontSize: 13.5)),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4D61),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),

              ],
            ),
            const SizedBox(width: 10), // reduced spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: 'Pickup status: ${it.status}',
                    child: Text(
                      "Pickup status: ${it.status}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 15, // smaller
                        letterSpacing: 0.3,
                        height: 1.3, // tighter line height
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Semantics(
                    label: 'Pickup type: ${it.pickupType}',
                    child: Text(
                      "Pickup type - ${it.pickupType}",
                      style: const TextStyle(fontSize: 13.5, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Semantics(
                    label: 'Scheduled on: ${it.time}',
                    child: Text(
                      "Scheduled on: ${it.time}",
                      style: const TextStyle(fontSize: 13.5, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Semantics(
                    label: 'Order details: ${it.details}',
                    child: Text(
                      it.details,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13.5, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),

        const SizedBox(height: 8), // reduced spacing before progress bar
       if (it.status.toLowerCase() != 'cancel' &&
    it.status.toLowerCase() != 'cancelled')
  StatusProgressBar(status: it.code),


        const SizedBox(height: 8), // reduced spacing before buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
if (it.status.toLowerCase() != 'cancel' &&
    it.status.toLowerCase() != 'cancelled' &&
    it.status.toLowerCase() != 'completed' &&
    it.status.toLowerCase() != 'done')
 ...[
              Semantics(
                button: true,
                label: 'Cancel order',
                child: TextButton.icon(
                  onPressed: () async {
                    confirmCancel(context, it);
                  },
                  icon: const Icon(Icons.cancel, size: 16),
                  label: const Text("Cancel", style: TextStyle(fontSize: 13.5)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Semantics(
              button: true,
              label: 'View order details',
              child: TextButton.icon(
                onPressed: () => _showOrderDetails(it),
                icon: const Icon(Icons.more_horiz, size: 16),
                label: const Text("Details", style: TextStyle(fontSize: 13.5)),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4D61),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        if(it.status != 'cancel') // spacing before image
        Image.asset(
          'assets/images/history.jpg',
          width: 140, // reduced size
          height: 90, // reduced height
          fit: BoxFit.cover,
        ),
      ],
    ),
  ),
);
 },
  );
}


}
