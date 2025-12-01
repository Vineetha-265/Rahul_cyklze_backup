import 'dart:async';
import 'dart:convert';
import 'package:cyklze/Provider/pickup_provider.dart';
import 'package:cyklze/SecureStorage/securestorage.dart';
import 'package:cyklze/Views/error.dart';
import 'package:cyklze/Views/loading.dart';
import 'package:cyklze/Views/loginrequird.dart';
import 'package:cyklze/Views/offline.dart';
import 'package:cyklze/screens/confirm_pickup.dart';
import 'package:cyklze/screens/verification.dart';
import 'package:cyklze/widgets/time_chip.dart';
import 'package:flutter/material.dart';
import 'package:cyklze/enums/page_state.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

const String _tokenUrl =
    "https://20pnz6cr8e.execute-api.ap-south-1.amazonaws.com/cyklzee/cyklzee/handletoken";

class CreativeAddressPage extends StatefulWidget {
  final String selectedTimeRange;
  final String selectedDate;
  final String selectedType;
  final List<String> selectedItems;

  const CreativeAddressPage({
    super.key,
    required this.selectedTimeRange,
    required this.selectedDate,
    required this.selectedType,
    required this.selectedItems,
  });

  @override
  State<CreativeAddressPage> createState() => _CreativeAddressPageState();
}

class _CreativeAddressPageState extends State<CreativeAddressPage>
    with SingleTickerProviderStateMixin {

  final _streetController = TextEditingController();
  final _areaController = TextEditingController();
  final _postalController = TextEditingController();
Pagestate _state = Pagestate.loading;
  String _selectedCity = 'Hyderabad';
  String? _savedAddress;
  bool _verifyingPostal = false;
  String? _postalCheckResult;
final int _runCount = 0;
//version control
  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
    _checkTokenExpiration();
  }

  @override
  void dispose() {
    _streetController.dispose();
    _areaController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  String? selectedDate;
  bool isTomorrow = false; 
  String? selectedTimeRange;
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

Future<void> _pickDate() async {
  final now = DateTime.now();

  // Determine if the current time is after 2 PM
  final isAfter2PM = now.hour >= 14;

  // Define today and tomorrow
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  // If after 2 PM, only allow tomorrow and onward; otherwise, today and onward
  final firstDate = isAfter2PM ? tomorrow : today;

  // Set a maximum date (e.g., 7 days from tomorrow)
  final maxDate = tomorrow;

  final picked = await showDatePicker(
    context: context,
    firstDate: firstDate,
    lastDate: maxDate,
    initialDate: firstDate,
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
              foregroundColor: Color(0xFF1D4D61),
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
final now = DateTime.now();
final today = DateTime(now.year, now.month, now.day);
    setState(() {
      selectedDate = formatted;

      if(picked.isAfter(today)){
 isTomorrow = true;
      }else{
        isTomorrow = false;
      }
    });
  }
}



// Future<void> _pickDate() async {
//   final now = DateTime.now();
//   final tomorrow = DateTime(now.year, now.month, now.day + 1);
//     final maxDate = tomorrow.add(const Duration(days: 7));

//   final picked = await showDatePicker(
//     context: context,
//     firstDate: tomorrow,
//     lastDate: tomorrow.add(const Duration(days: 7)),
//     initialDate: tomorrow,
//     builder: (context, child) {
//       return Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFF1D4D61),
//             onPrimary: Colors.white,
//             onSurface: Colors.black,
//           ),
//           textButtonTheme: TextButtonThemeData(
//             style: TextButton.styleFrom(
//               foregroundColor: const Color(0xFF1D4D61),
//             ),
//           ),
//         ),
//         child: child!,
//       );
//     },
//   );

//   if (picked != null) {
//     final dateOnly = DateTime(picked.year, picked.month, picked.day);
//     final formatted = DateFormat('dd MMM yyyy').format(dateOnly);

//     setState(() {
//       selectedDate = formatted;
//     });
//   }
// }





  Future<void> _loadSavedAddress() async {
    final a = await SecureStorage.getAddress();
    setState(() => _savedAddress = a);
  }

  
Future<void> _checkTokenExpiration() async {
  final accessToken = await SecureStorage.getAccessToken();
  if (accessToken == null) {
    setState(() => _state = Pagestate.notLogged);
    return;
  }

final   provider = Provider.of<PickupProvider>(context, listen: false);
  if (!await provider.hasInternetConnection()) {
    setState(() => _state = Pagestate.offline);
    return;
  }

  setState(() => _state = Pagestate.loading);
  try {
    final resp = await http.post(
      Uri.parse(_tokenUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'accessToken': accessToken}),
    );

    if (resp.statusCode == 200) {
      setState(() => _state = Pagestate.loggedIn);
      return;
    }  else {
        if (_runCount >= 2){
setState(() => _state = Pagestate.error);
        }else{
          
final   provider = Provider.of<PickupProvider>(context, listen: false);
  Pagestate result = await provider.refreshAccessToken(_checkTokenExpiration,"no");
             setState(() => _state = result);
        }
     
    }
  } catch (e) {
    setState(() => _state = Pagestate.error);
  }
}

 Future<void> _verifyPostal() async {
  final postal = _postalController.text.trim();

  if (postal.isEmpty) {
    _showSnack('Enter postal code first');
    return;
  }

  if (postal.length != 6 || int.tryParse(postal) == null) {
    _showSnack('Postal code should be 6 digits');
    return;
  }

  setState(() {
    _verifyingPostal = true;
    _postalCheckResult = null;
  });

  await Future.delayed(const Duration(milliseconds: 500));

  final pin = int.parse(postal);
  final isHyderabad = postal.startsWith('500') && pin >= 500001 && pin <= 500099;

  if (isHyderabad) {
    setState(() {
      _postalCheckResult = 'Hyderabad / Secunderabad — Serviceable';
    });
  } else {
    setState(() {
      _postalCheckResult = 'Not Serviceable';
    });
  }

  setState(() {
    _verifyingPostal = false;
  });
}

  Future<void> _submitAddress() async {
    final street = _streetController.text.trim();
    final area = _areaController.text.trim();
    final postal = _postalController.text.trim();
  final validAddressRegex = RegExp(r"^[a-zA-Z0-9\s\-,./]{3,50}$");
    // if (street.isEmpty || area.isEmpty) {
    //   _showSnack('Please enter complete address');
    //   return;
    // }


  if (!validAddressRegex.hasMatch(street)) {
    _showSnack('Invalid street address.');
    return;
  }

  if (!validAddressRegex.hasMatch(area)) {
    _showSnack('Invalid area name.');
    return;
  }
      if (postal.length != 6 || int.tryParse(postal) == null) {
      _showSnack('Postal code should be 6 digits');
      return;
    }
   
      await _verifyPostal();
    

    if ((_postalCheckResult ?? '').contains('Not Serviceable')) {
      _showSnack('We don\'t serve this postal code');
      return;
    }

    final full = '$street, $area, $_selectedCity, $postal';
    await SecureStorage.saveAddress(full);

    if (!mounted) return;
//final pickupProvider = Provider.of<PickupProvider>(context, listen: false);

Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => ModernConfirmPickupPage(
      address: full,
    ),
  ),
);
  }

  void _useSavedAddress() {
    if (_savedAddress == null) return;
    // final pickupProvider = Provider.of<PickupProvider>(context);
  Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => ModernConfirmPickupPage(
      // selectedTimeRange: pickupProvider.getSelectedTimeRange ?? "",
      // selectedDate: pickupProvider.getSelectedDate ?? "",
      // selectedType: pickupProvider.getSelectedType ?? "",
      // selectedItems: pickupProvider.getSelectedItems ?? [],
      address: _savedAddress ?? "",
    ),
  ),
);

  }

  void _showSnack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
        title: const Text("Address",
            style: TextStyle(color: Colors.white,   fontSize: 16,
                        fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _buildByState(),
        ),
      ),
    );
  }

  Widget _buildByState() {
    switch (_state) {
      case Pagestate.loading:
        return const ElegantLoadingOverlay();
        
      //  const Center(child: CircularProgressIndicator());
      case Pagestate.notLogged:
        return LoginRequired(
        message: "Please log in to proceed further",
        onLogin: () async{
         final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PhoneVerificationPage()),
          );
          if (result == true) {
            await _checkTokenExpiration();
          }else{
            setState(() {
              _state = Pagestate.notLogged;
            });
          }
        },
      );
      case Pagestate.offline:
        return OfflineRetry(
      onRetry: _checkTokenExpiration,
    );
      case Pagestate.error:
        return  ErrorRetry(
              message: "Something went wrong",
              onRetry: _checkTokenExpiration,
            );
      case Pagestate.loggedIn:
        return  _mainContent();
    }
  }




Future<void> showPickupDetailsPopup({
  required BuildContext context,
  required String selectedType,
  required String selectedDate,
  required String selectedTimeRange,
  required List<String> selectedItems,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Semantics(
          label: 'Pickup details card',
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Semantics(
                      header: true,
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black54),
                          const SizedBox(width: 8),
                          const Text(
                            'Pickup details',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          // const Spacer(),
                          // Tooltip(
                          //   message: 'Edit pickup details',
                          //   child: TextButton.icon(
                          //     onPressed: () => Navigator.pop(context),
                          //     icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                          //     label: const Text('Edit', style: TextStyle(color: Colors.white)),
                          //     style: TextButton.styleFrom(
                          //       backgroundColor: const Color(0xFF1D4D61),
                          //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          //     ),
                          //   ),
                          // ),
                    
                    ],
                      ),
                    ),
                    const Divider(height: 14),
              
                    // Pickup Type
                    Semantics(
                      label: 'Pickup type details',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const SizedBox(
                                width: 100,
                                child: Text('Type', style: TextStyle(color: Colors.black54))),
                            Expanded(
                                child: Text(selectedType.isNotEmpty ? selectedType : '—')),
                          ],
                        ),
                      ),
                    ),
              
                    // Pickup Date
                    Semantics(
                      label: 'Pickup date details',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const SizedBox(
                                width: 100,
                                child: Text('Date', style: TextStyle(color: Colors.black54))),
                            Expanded(
                                child: Text(selectedDate.isNotEmpty ? selectedDate : '—')),
                          ],
                        ),
                      ),
                    ),
              
                    // Pickup Time
                    Semantics(
                      label: 'Pickup time range details',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const SizedBox(
                                width: 100,
                                child: Text('Time', style: TextStyle(color: Colors.black54))),
                            Expanded(
                                child: Text(
                                    selectedTimeRange.isNotEmpty ? selectedTimeRange : '—')),
                          ],
                        ),
                      ),
                    ),
              
                    const SizedBox(height: 8),
                    const Text('Items', style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 6),
              
                    // Items Chips
                    Semantics(
                      label: 'Items selected for pickup',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: (selectedItems.isNotEmpty
                                ? selectedItems
                                : ['—'])
                            .map((it) => Chip(
                                  label: Text(it),
                                  backgroundColor: Colors.grey.shade100,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}



Widget _mainContent() {
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === Pickup Details Button ===
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 18),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Show Pickup Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4D61),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.2),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            onPressed: () {
              showPickupDetailsPopup(
                context: context,
                selectedType: widget.selectedType,
                selectedDate: widget.selectedDate,
                selectedTimeRange: widget.selectedTimeRange,
                selectedItems: widget.selectedItems,
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // === Address Title Section ===
        if (_savedAddress != null)
          Semantics(
            label: 'Choose or Enter Your Pickup Address',
            child: _buildSectionTitle('Choose or Enter Your Pickup Address'),
          )
        else
          const Text(
            'Enter Your Pickup Address',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
          ),

        if (_savedAddress != null) ...[
          const SizedBox(height: 6),
          Text(
            'Continue with the saved address',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _useSavedAddress,
            child: Card(
              margin: EdgeInsets.zero,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade300, width: 0.8),
              ),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.home, color: Colors.green, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _savedAddress!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 10),

        // === Enter New Address Section ===
        _buildSectionTitle('Enter New Address'),
        Text(
          'Enter a new address for the current pickup',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
            fontSize: 12.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),

        // === Address Fields ===
        _field(_streetController, label: 'Street / Plot no.', icon: Icons.location_on),
        const SizedBox(height: 6),
        _field(_areaController, label: 'Colony / Area', icon: Icons.apartment),
        const SizedBox(height: 6),

        // === Postal & Verify Row ===
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _field(
                _postalController,
                label: 'Postal Code',
                icon: Icons.markunread_mailbox,
                keyboard: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _verifyingPostal ? null : _verifyPostal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4D61),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: _verifyingPostal
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // === City Dropdown ===
        const Text(
          'Select City',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400, width: 0.8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCity,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              items: const [
                DropdownMenuItem(
                  value: 'Hyderabad',
                  child: Text('Hyderabad'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCity = value!;
                });
              },
            ),
          ),
        ),

        if (_postalCheckResult != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _postalCheckResult!.contains('Not Serviceable')
                    ? Icons.close
                    : Icons.check_circle,
                color: _postalCheckResult!.contains('Not Serviceable')
                    ? Colors.red
                    : Colors.green,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _postalCheckResult!,
                  style: const TextStyle(fontSize: 12.5),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 16),

        // === Confirm Address Button ===
        SizedBox(
          width: double.infinity,
          height: 50,
          child: InkWell(
            onTap: _submitAddress,
            borderRadius: BorderRadius.circular(10),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D4D61), Color(0xFF163B4B)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Confirm Address',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 28),
      ],
    ),
  );
}





// Widget _mainContent() {

//   return SingleChildScrollView(
//     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 5),
//        SizedBox(
//   width: double.infinity, // full width of parent
//   child: ElevatedButton.icon(
//     icon: const Icon(Icons.local_shipping_outlined, color: Colors.white),
//     label: const Padding(
//       padding: EdgeInsets.symmetric(vertical: 14),
//       child: Text(
//         'Show Pickup Details',
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: Colors.white,
//         ),
//       ),
//     ),
//     style: ElevatedButton.styleFrom(
//       backgroundColor: const Color(0xFF1D4D61), // deep teal-blue tone
//       foregroundColor: Colors.white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       elevation: 3,
//       shadowColor: Colors.black.withOpacity(0.2),
//       alignment: Alignment.centerLeft, // icon stays left
//     ),
//     onPressed: () {
//       showPickupDetailsPopup(
//         context: context,
//         selectedType: widget.selectedType,
//         selectedDate: widget.selectedDate,
//         selectedTimeRange: widget.selectedTimeRange,
//         selectedItems: widget.selectedItems,
//       );
//     },
//   ),
// ),


//          const SizedBox(height: 10),
//           if (_savedAddress != null) ...[
//  Semantics(
//             label: 'Choose or Enter Your Pickup Address',
//             child: _buildSectionTitle('Choose or Enter Your Pickup Address'),
//           )]else ...[
//          Semantics(
//             label: 'Enter Your Pickup Address',
//             child:const Text('Enter Your Pickup Address', style: TextStyle(fontWeight: FontWeight.w600)),
//           )
//         ],
       
//         if (_savedAddress != null) ...[
         
//           Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//             children: [const SizedBox(height: 7),
//           //      Semantics(
//           //   label: 'Saved address section',
//           //   child: const Text('Saved Address', style: TextStyle(fontWeight: FontWeight.w600)),
//           // ),
//           const SizedBox(height: 2),
//           Semantics(
//             label: 'Continue with saved address text',
//             child: Text(
//               'Continue with the saved address',
//               style: TextStyle(
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.w400,
//                     height: 1.3,
//                   ),
//             ),
//           ),
//               InkWell(
//                 borderRadius: BorderRadius.circular(12),
//                 onTap: _useSavedAddress,
//                 child: Semantics(
//                   label: 'Tap to use saved address',
//                   child: Card(
//                     color: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.home, color: Colors.green),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Text(
//                               _savedAddress!,
//                               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//                             ),
//                           ),
//                           const Icon(Icons.chevron_right, color: Colors.grey),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],

//         const SizedBox(height: 6),

//         Semantics(
//           label: 'Enter new address section',
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildSectionTitle('Enter New Address'),
//               Semantics(
//                 label: 'Enter new address details text',
//                 child: Text(
//                   'Enter a new address for the current pickup',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.w400,
//                     height: 1.3,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//             ],
//           ),
//         ),

//         _field(_streetController, label: 'Street / Plot no.', icon: Icons.location_on),
//         _field(_areaController, label: 'Colony / Area', icon: Icons.apartment),
//         Row(
//           children: [
//             Expanded(
//               flex: 3,
//               child: _field(_postalController, label: 'Postal Code', icon: Icons.markunread_mailbox, keyboard: TextInputType.number),
//             ),
//             const SizedBox(width: 12),
//           Expanded(
//   flex: 2,
//   child: SizedBox(
//     height: 58,
//     child: Semantics(
//       label: 'Verify postal code button',
//       child: ElevatedButton(
//         onPressed: _verifyingPostal ? null : _verifyPostal,
//         style: ElevatedButton.styleFrom(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           backgroundColor: const Color(0xFF1D4D61), // Set the button color
//           textStyle: const TextStyle(color: Colors.white), // Set the text color to white
//         ),
//         child: _verifyingPostal
//             ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//               )
//             : const Text('Verify Postal code',style: TextStyle(color: Colors.white),),
//       ),
//     ),
//   ),
// )

//           ],
//         ),
// const Text("select city"),
     
//         Padding(
//           padding: const EdgeInsets.only(bottom: 12),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey), 
//             ),
//             child: DropdownButtonHideUnderline(
//               child: Semantics(
//                 label: 'City selection dropdown',
//                 child: DropdownButton<String>(
//                   value: _selectedCity,
//                   isExpanded: true,
//                   icon: const Icon(Icons.arrow_drop_down),
//                   items: const [
//                     DropdownMenuItem(
//                       value: 'Hyderabad',
//                       child: Text('Hyderabad'),
//                     ),
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCity = value!;
//                     });
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ),
//         if (_postalCheckResult != null) ...[
//           const SizedBox(height: 8),
//           Semantics(
//             label: 'Postal check result',
//             child: Row(
//               children: [
//                 Icon(_postalCheckResult!.contains('Not Serviceable') ? Icons.close : Icons.check_circle,
//                     color: _postalCheckResult!.contains('Not Serviceable') ? Colors.red : Colors.green),
//                 const SizedBox(width: 8),
//                 Expanded(child: Text(_postalCheckResult!)),
//               ],
//             ),
//           ),
//         ],

//         const SizedBox(height: 22),

//         Semantics(
//           label: 'Submit address button',
//           child: SizedBox(
//             width: double.infinity,
//             child: InkWell(
//               onTap: _submitAddress,
//               borderRadius: BorderRadius.circular(14),
//               child: Ink(
//                 height: 56,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient( colors: [Color(0xFF1D4D61), Color(0xFF163B4B)]),
//                   borderRadius: BorderRadius.circular(14),
//                   boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))],
//                 ),
//                 child: const Center(
//                   child: Text('Confirm Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 45),

//       ],
//     ),
//   );
// }
Widget _buildPickupSlotSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 28),
      _buildSectionTitle("Select a Pickup slot"),
      Text(
        "Select your preferred time slot.",
        style: TextStyle(
          color: Colors.grey[600],
          height: 1.3,
        ),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          TimeChip(
            label: "8 AM - 11 AM",
            selectedTimeRange: selectedTimeRange,
            onSelected: (value) =>
                setState(() => selectedTimeRange = value),
          ),
          TimeChip(
            label: "11 AM - 1 PM",
            selectedTimeRange: selectedTimeRange,
            onSelected: (value) =>
                setState(() => selectedTimeRange = value),
          ),
          TimeChip(
            label: "1 PM - 3 PM",
            selectedTimeRange: selectedTimeRange,
            onSelected: (value) =>
                setState(() => selectedTimeRange = value),
          ),
          TimeChip(
            label: "3 PM - 6 PM",
            selectedTimeRange: selectedTimeRange,
            onSelected: (value) =>
                setState(() => selectedTimeRange = value),
          ),
        ],
      ),
    ],
  );
}



Widget _field(
  TextEditingController c, {
  required String label,
  required IconData icon,
  TextInputType keyboard = TextInputType.text,
  String? hintText,
  String? errorText,
}) {

  final isPostal = label.toLowerCase().contains('postal');

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: c,
      keyboardType: isPostal ? TextInputType.number : keyboard,
      inputFormatters: isPostal
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ]
          : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
}