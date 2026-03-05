import 'dart:convert';
import 'dart:io';
import 'package:cyklze/SecureStorage/securestorage.dart';
import 'package:cyklze/Views/loading.dart';
import 'package:cyklze/screens/confirmed.dart';
import 'package:cyklze/screens/verification.dart';
import 'package:flutter/material.dart';
import 'package:cyklze/Provider/pickup_provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
    'https://api.cyklze.com/cyklzee/order';
const String TOKEN_URL =
    'https://api.cyklze.com/cyklzee/handletoken';

class ModernConfirmPickupPage extends StatefulWidget {
  final String address;
final File? image;
  const ModernConfirmPickupPage({
    super.key,
    required this.address,
    required this.image,
  });


  @override
  State<ModernConfirmPickupPage> createState() => _ModernConfirmPickupPageState();
}

class _ModernConfirmPickupPageState extends State<ModernConfirmPickupPage>
    with TickerProviderStateMixin {
  Pagestate _state = Pagestate.loggedIn;
  final pickupProvider = PickupProvider();

 int _runCount = 0;
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
        child:  Text(
          "Note",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1D4D61),
          ),
        ),
      ),
      content: Semantics(
  label: 'confirmation message',
  child: Text(
    "Your recent pickup is still pending. A new pickup cannot be scheduled. Instead, provide current and pending pickup details to the agent.",
    style: GoogleFonts.poppins(
      fontSize: 14,
      color: Colors.black,
      height: 1.3, // tighter spacing
    ),
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

final   provider = Provider.of<PickupProvider>(context, listen: false);
  if (!await provider.hasInternetConnection()) {
    setState(() => _state = Pagestate.offline);
    return;
  }

  // if (!await hasInternetConnection()) {

  //   if (mounted) {
  //     setState(() => _state = Pagestate.offline);
  //   }
  //   return;
  // }

  final token = await SecureStorage.getAccessToken();
  if (token == null || token.isEmpty) {
    if (mounted) {
      setState(() => _state = Pagestate.notLogged);
    }
    return;
  }
    setState(() => _state = Pagestate.loading);
String yesimage = 'no';
   if (widget.image != null) {
  try {
    final bytes = await widget.image!.readAsBytes();
    yesimage = base64Encode(bytes);
  } catch (e) {
    yesimage = 'no';
  }
}
  

  try {

    final pickupProvider = Provider.of<PickupProvider>(context, listen: false);

    final orderPayload = jsonEncode({
      'time': pickupProvider.selectedTimeRange,
      'date': pickupProvider.selectedDate,
      'type': pickupProvider.selectedType,
      'items': pickupProvider.selectedItems,
      'address': widget.address,
      'image': yesimage
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
        .timeout(const Duration(seconds: 40));

 
    if (mounted) {
      if (response.statusCode == 200) {
   
      Map<String, dynamic> responseBody = {};

try {
  responseBody = jsonDecode(response.body);
} catch (e) {
  setState(() => _state = Pagestate.error);
  return;
}
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
    
   
      } else{
         if (_runCount >= 2){
           setState(() => _state = Pagestate.error);
         }
         else{
          _runCount++;
     final provider = Provider.of<PickupProvider>(context, listen: false);
        Pagestate result =
            await provider.refreshAccessToken(fetchProfile, "exe");
        setState(() => _state = result);
         }
     
  
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
              child:  Text(
  'Confirm Pickup',
  style: GoogleFonts.poppins(
    fontSize: 16,                 // adjust size as needed
    fontWeight: FontWeight.w600,   // semi-bold for button
    color: Colors.black,           // typical button text color
  ),
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
                        child:  Text('close',style: GoogleFonts.poppins(color: Colors.black),),
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
              style: GoogleFonts.poppins(color: Colors.grey.shade700),
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
                style:  GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300, width: 0.8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === Header ===
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children:  [
                  Icon(Icons.assignment_outlined,
                      size: 16, color: Color(0xFF1D4D61)),
                  SizedBox(width: 6),
                  Text(
                    'Pickup Summary',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D4D61),
                    ),
                  ),
                ],
              ),
              Tooltip(
                message: 'Preview the pickup details',
                child: TextButton.icon(
                  onPressed: () => _showOrderPreview(),
                  icon: const Icon(Icons.remove_red_eye_outlined,
                      color: Colors.white, size: 14),
                  label:  Text(
                    'Preview',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4D61),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          const Divider(height: 12, thickness: 0.8, color: Color(0xFFE0E0E0)),

          // === Items Section ===
           Text(
            'Items',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: pickupProvider.selectedItems.isNotEmpty
                ? pickupProvider.selectedItems.map((e) {
                    return Chip(
                      backgroundColor: const Color(0xFFF5F7FA),
                      labelPadding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                      label: Text(
                        e,
                        style:  GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 12.5,
                        ),
                      ),
                    );
                  }).toList()
                : [
                     Chip(
                      label: Text(
                        'No items selected',
                        style:
                            GoogleFonts.poppins(color: Colors.black54, fontSize: 12.5),
                      ),
                      backgroundColor: Color(0xFFF5F7FA),
                    ),
                  ],
          ),

          const SizedBox(height: 8),
          const Divider(height: 10, thickness: 0.8, color: Color(0xFFE0E0E0)),

          // === Pickup Details ===
           Text(
            'Pickup Details',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 15, color: Colors.black54),
              const SizedBox(width: 6),
              Text(
                pickupProvider.selectedDate ?? '—',
                style:  GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(Icons.access_time_outlined,
                  size: 15, color: Colors.black54),
              const SizedBox(width: 6),
              Text(
                pickupProvider.selectedTimeRange ?? '—',
                style:  GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ],
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
                style:  GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
      backgroundColor: Colors.white,
      //Colors.grey.shade50,
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
        title:  Text("Confirm Pickup",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body:
       _buildBody(),
    );
  }

Widget _readyView() {
  return 
 Stack(
    children: [

SingleChildScrollView(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // === PICKUP SUMMARY CARD ===
      Semantics(
        label: 'Pickup summary section',
        child: _pickupSummaryCard(),
      ),

      const SizedBox(height: 10),

      // === PICKUP ADDRESS HEADER ===
   Text(
  'Pickup Address',
  style: GoogleFonts.poppins(
    textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: const Color(0xFF1D4D61),
        ),
  ),
),
      const SizedBox(height: 3),
    Text(
  'This is the address selected for the pickup.',
  style: GoogleFonts.poppins(
    textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[700],
          height: 1.2,
          fontSize: 12.5,
        ),
  ),
),

      const SizedBox(height: 8),

      // === ADDRESS CARD ===
      Semantics(
        label: 'Pickup address details',
        child: _addressCard(),
      ),

      const SizedBox(height: 14),

      // === CONFIRM BUTTON SECTION ===
      Semantics(
        container: true,
        label: 'Confirm pickup section',
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Ready to confirm your pickup?',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: const Color(0xFF1D4D61),
                    ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.white, size: 18),
                  label:  Text(
                    'Confirm Pickup',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4D61),
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  onPressed: () async {
                    await fetchProfile();
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 18),

      // === BOTTOM ILLUSTRATION ===
      Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/thumbsup.jpg',
              width: 120,
              height: 90,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 4),
           Text(
  'Everything looks great!',
  style: GoogleFonts.poppins(
    textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
          fontSize: 12.5,
        ),
  ),
),
          ],
        ),
      ),
    ],
  ),
)

   
    ],
  );

}


}
