import 'dart:convert';
import 'dart:io';
import 'package:cyklze/SecureStorage/securestorage.dart';
import 'package:cyklze/Views/loading.dart';
import 'package:cyklze/screens/confirmed.dart';
import 'package:cyklze/screens/verification.dart';
import 'package:flutter/material.dart';
import 'package:cyklze/Provider/pickup_provider.dart';
import 'package:http/http.dart' as http;
import 'package:cyklze/enums/page_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cyklze/Views/error.dart';
import 'package:cyklze/Views/loginrequird.dart';
import 'package:cyklze/Views/offline.dart';
import 'dart:async';
import 'package:provider/provider.dart';

const String ORDER_URL =
    'https://20pnz6cr8e.execute-api.ap-south-1.amazonaws.com/cyklzee/cyklzee/order';
const String TOKEN_URL =
    'https://20pnz6cr8e.execute-api.ap-south-1.amazonaws.com/cyklzee/cyklzee/handletoken';

class ModernConfirmPickupPage extends StatefulWidget {
  final String address;

  const ModernConfirmPickupPage({
    super.key,
    required this.address,
  });


  @override
  State<ModernConfirmPickupPage> createState() => _ModernConfirmPickupPageState();
}

class _ModernConfirmPickupPageState extends State<ModernConfirmPickupPage>
    with TickerProviderStateMixin {
  Pagestate _state = Pagestate.loggedIn;
  final pickupProvider = PickupProvider();

final int _runCount = 0;
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _checkNetworkAndToken();
  }

  Future<void> _checkNetworkAndToken() async {
      if (!await hasInternetConnection()) {
    if (mounted) {
      setState(() => _state = Pagestate.offline);
    }
    return;
  }
    setState(() => _state = Pagestate.loggedIn);
  }

void confirmLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFFF5F5F5),
      title: Semantics(
        label: 'Note',
        child: const Text(
          "Note",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1D4D61),
          ),
        ),
      ),
      content: Semantics(
        label: ' confirmation message',
        child: const Text(
          "Your Recent pickup scheduled is still pending, so a new one can't be scheduled yet. Please provide the pickup agent with complete and accurate details of all materials including this and  the existing pickup to ensure a smooth collection.",   style: TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
       
        Semantics(
          label: 'Confirm',
          button: true,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Call your logout function here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4D61),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Ok"),
          ),
        ),
      ],
    ),
  );
}


Future<void> fetchProfile() async {



  if (!await hasInternetConnection()) {

    if (mounted) {
      setState(() => _state = Pagestate.offline);
    }
    return;
  }

  final token = await SecureStorage.getAccessToken();
  if (token == null || token.isEmpty) {
    if (mounted) {
      setState(() => _state = Pagestate.notLogged);
    }
    return;
  }
    setState(() => _state = Pagestate.loading);

  try {

    final pickupProvider = Provider.of<PickupProvider>(context, listen: false);

    final orderPayload = jsonEncode({
      'time': pickupProvider.selectedTimeRange,
      'date': pickupProvider.selectedDate,
      'type': pickupProvider.selectedType,
      'items': pickupProvider.selectedItems,
      'address': widget.address,
    });

    final response = await http
        .post(
          Uri.parse(ORDER_URL),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token,
          },
          body: orderPayload,
        )
        .timeout(const Duration(seconds: 10));

 
    if (mounted) {
      if (response.statusCode == 200) {
   
         final Map<String, dynamic> responseBody = jsonDecode(response.body);
    final message = responseBody['message'];
    if(message.toString().toLowerCase().contains("pending")){
      confirmLogout(context);
     setState(() => _state = Pagestate.loggedIn);
    }else{

     setState(() => _state = Pagestate.loggedIn);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PickupConfirmedPage()),
        );
    }
    
   
      } else if (response.statusCode == 401) {
         if (_runCount >= 2){
           setState(() => _state = Pagestate.error);
         }
         else{
      final provider = PickupProvider();
        Pagestate result =
            await provider.refreshAccessToken(fetchProfile, "exe");
        setState(() => _state = result);
         }
     
  
      } else {
    
        setState(() => _state = Pagestate.error);
      }
    }
  } on TimeoutException {

    if (mounted) {
      setState(() => _state = Pagestate.offline);
    }
  } catch (e) {

    if (mounted) {
      setState(() => _state = Pagestate.error);
    }
  }
}


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
    } catch (_) {
      return false;
    }
  }

  Widget _buildBody() {
    switch (_state) {
      case Pagestate.loading:
        return const ElegantLoadingOverlay();
     
      case Pagestate.offline:
        return OfflineRetry(
          onRetry: () {
            _checkNetworkAndToken();
          },
        );
      case Pagestate.notLogged:
        return LoginRequired(
          message: "Please log in to confirm pickup",
          onLogin: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PhoneVerificationPage()),
            );
            if (result == true) {
              await _checkNetworkAndToken();
            }
          },
        );
      case Pagestate.error:
        return ErrorRetry(
          message: "Something went wrong",
          onRetry: () {
            _checkNetworkAndToken();
          },
        );
      case Pagestate.loggedIn:
      default:
        return _readyView();
    }
  }

 void _showOrderPreview() {
  final pickupProvider = Provider.of<PickupProvider>(context, listen: false);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
      backgroundColor: Colors.white, 
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, controller) => SingleChildScrollView(
        
        controller: controller,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
   
            Semantics(
              label: 'Draggable handle for modal',
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              label: 'Confirm Pickup Heading',
              child: const Text(
                'Confirm Pickup',
               
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Items summary tile',
              child: _summaryTile('Items', pickupProvider.selectedItems.join(', ')),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: 'Address summary tile',
              child: _summaryTile('Address', widget.address),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: 'Date summary tile',
              child: _summaryTile('Date', pickupProvider.selectedDate!),
            ),
             const SizedBox(height: 8),
            Semantics(
              label: 'Type summary tile',
              child: _summaryTile('Pickup type', pickupProvider.selectedType!),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: 'Time summary tile',
              child: _summaryTile('Time', pickupProvider.selectedTimeRange!),
            ),
            const SizedBox(height: 14),

            const SizedBox(height: 18),
            Semantics(
              label: 'close button row',
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Semantics(
                        label: 'close the pickup confirmation',
                        child: const Text('close',style: TextStyle(color: Colors.black),),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );

}

Widget _summaryTile(String label, String value) {
  return Semantics(
    label: '$label: $value', 
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
   
        SizedBox(
          width: 84,
          child: Semantics(
            label: 'Label: $label',
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            label: 'Value: $value',
            child: Tooltip(
              message: value,
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _pickupSummaryCard() {
  final pickupProvider = Provider.of<PickupProvider>(context, listen: false);

  return Container(
    
   decoration: BoxDecoration(
      color: Colors.white,
  borderRadius: BorderRadius.circular(12),
   ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    
          Semantics(
            label: 'Pickup Summary',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pickup Summary',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                Tooltip(
      message: 'Preview the pickup details',
      child: TextButton(
    onPressed: () => _showOrderPreview(),
    style: TextButton.styleFrom(
      backgroundColor: const Color(0xFF1D4D61),     
      foregroundColor: Colors.white,    
    ),
    child: const Text('Preview'),
      ),
    ),
    
              ],
            ),
          ),
          const SizedBox(height: 3),
          Semantics(
            label: 'Items',
            child: const Text('Items', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
      
          Semantics(
            label: 'Selected items',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pickupProvider.selectedItems
                  .map(
                    (e) => Chip(backgroundColor: Colors.white,
                      label: Semantics(
                        label: 'Item: $e',
                        child: Text(e,style: const TextStyle(color: Colors.black),),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
       
          const SizedBox(height: 3),
          Semantics(
            label: 'Pickup Details',
            child: Column(
              children: [
               
                Semantics(
                  label: 'Pickup Date: ${pickupProvider.selectedDate}',
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined,
                          size: 18, color: Colors.black54),
                      const SizedBox(width: 8),
                      Text(pickupProvider.selectedDate!,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
    
                Semantics(
                  label: 'Pickup Time: ${pickupProvider.selectedTimeRange}',
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_outlined,
                          size: 18, color: Colors.black54),
                      const SizedBox(width: 8),
                      Text(pickupProvider.selectedTimeRange!),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _addressCard() {
  return Container(

   decoration: BoxDecoration(
      color: Colors.white, 
  borderRadius: BorderRadius.circular(12),
   ),
  
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: 'Home Icon',
            child: const Icon(Icons.home_outlined, color: Colors.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              label: 'Address: ${widget.address}',
              child: Text(
                widget.address,
                style: const TextStyle(fontWeight: FontWeight.w600),
                softWrap: true, 
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration:const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1D4D61), Color(0xFF163B4B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("Confirm Pickup",
            style: TextStyle(color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBody(),
      ),
    );
  }

Widget _readyView() {
  return SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Semantics(
            label: 'Pickup summary',
            child: _pickupSummaryCard(),
          ),

          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Pickup Address',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'This is the address selected for the pickup.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Semantics(
            label: 'Pickup address details',
            child: _addressCard(),
          ),

          const SizedBox(height: 8),
Padding(
  padding: const EdgeInsets.all(8.0),
  child: Semantics(
    container: true,
    label: 'Confirm pickup section',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Semantics(
          button: true,
          label: 'Tap to confirm pickup',
          child: SizedBox(
            width: double.infinity, 
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4D61),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async{
                await fetchProfile();
              },
              child: const Text(
                'Confirm Pickup',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),

          const SizedBox(height: 24),

        ],
      ),
    ),
  );
}
}
