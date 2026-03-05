import 'dart:convert';

import 'package:cyklze/Provider/pickup_provider.dart';
import 'package:cyklze/SecureStorage/securestorage.dart';
import 'package:cyklze/Views/error.dart';
import 'package:cyklze/Views/loading.dart';
import 'package:cyklze/Views/offline.dart';
import 'package:cyklze/screens/price_page.dart';
import 'package:cyklze/widgets/date_time.dart';
import 'package:cyklze/widgets/searchaddress.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

enum PageState {  loggedIn, offline, error ,loading }
class EditAddressPage extends StatefulWidget {
  const EditAddressPage({super.key});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _streetController = TextEditingController();
  final _areaController = TextEditingController();
  final _postalController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? message;
String? regx;
String selectedCty = "";
String selectedLocality = '';
List<String> areas = [];
List<String> cities = [];
 List<PostalCodeRange> postalRanges = [
];
List<Map<String, dynamic>> postalCodeRanges = [];

  PageState _state = PageState.loggedIn;

  bool _verifyingPostal = false;
  String? _postalCheckResult;
String? _selectedCity = 'Hyderabad';


  void _showSnack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  }
    @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
  fetchProducts();
});
  }
Future<void> fetchProducts() async {
  setState(() {
    _state = PageState.loading;
  });

  final provider = Provider.of<PickupProvider>(context, listen: false);

  if (!await provider.hasInternetConnection()) {
    setState(() => _state = PageState.offline);
    return;
  }

  try {
    final res = await http.get(
      Uri.parse("https://api.cyklze.com/cyklzee/address"),
    );

    if (res.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(res.body);

      setState(() {
        message = data["message"];

        areas = List<String>.from(data["areas"] ?? []);
        cities = List<String>.from(data["cities"] ?? []);

        postalCodeRanges = List<Map<String, dynamic>>.from(
          data["postalCodeRanges"] ?? [],
        );

        regx = data["regx"];

        _state = PageState.loggedIn;
      });

    } else {
      setState(() => _state = PageState.error);
    }

  } catch (e) {
    setState(() => _state = PageState.error);
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
  // final isHyderabad = postal.startsWith('500') && pin >= 500001 && pin <= 500099;
   final isHyderabad = postalCodeRanges.any((range) {
  return pin >= range['min'] && pin <= range['max'];
});

print('Is Hyderabad: $isHyderabad');

  if (isHyderabad) {
    setState(() {
      _postalCheckResult = 'Serviceable';
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



  // Future<void> _verifyPostal() async {
  //   final postal = _postalController.text.trim();

  //   if (postal.isEmpty) {
  //     _showSnack('Enter postal code first');
  //     return;
  //   }

  //   if (postal.length != 6 || int.tryParse(postal) == null) {
  //     _showSnack('Postal code should be 6 digits');
  //     return;
  //   }

  //   setState(() {
  //     _verifyingPostal = true;
  //     _postalCheckResult = null;
  //   });

  //   await Future.delayed(const Duration(milliseconds: 500));
  //   final pin = int.parse(postal);
  //   final isHyderabad = postal.startsWith('500') && pin >= 500001 && pin <= 500099;

  //   setState(() {
  //     _postalCheckResult = isHyderabad
  //         ? 'Hyderabad / Secunderabad — Serviceable'
  //         : 'This location is not servicable';
  //     _verifyingPostal = false;
  //   });
  // }

  Future<void> _submitAddress() async {
    final street = _streetController.text.trim();
    final area = _areaController.text.trim();
    final postal = _postalController.text.trim();

    final validAddressRegex = RegExp(regx!);


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

    if (selectedCty == null || selectedCty.isEmpty) {
      _showSnack('Please confirm the city');
      return;
    }
     if (selectedLocality == null || selectedLocality.isEmpty) {
      _showSnack('Please confirm the Locality');
      return;
    }

  
      await _verifyPostal();
   

    if ((_postalCheckResult ?? '').toLowerCase().contains('not')) {
      _showSnack('We don\'t serve this postal code');
      return;
    }

    final full = '$street, $area,$selectedLocality, $selectedCty, $postal';
await SecureStorage.saveAddress(full);

    Navigator.pop(context); 
    _showSnack("Address Changed successfully");
  }

  
Widget _field(
  TextEditingController controller, {
  required String label,
  required IconData icon,
  TextInputType? keyboard,
}) {
  bool isPostalCode = label.toLowerCase().contains('postal');

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboard ?? TextInputType.text,
      inputFormatters: isPostalCode
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ]
          : [],
          style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

void _openSearchPopup(
  BuildContext context,
  List<String> list,
  Function(String) onSelected,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true, // ⭐ THIS IS CRITICAL
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children:  [
                Text(
                  "Search",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // Content
          Expanded(
            child: SearchPopupContent(
              list: list,
              onSelected: onSelected,
            ),
          ),
        ],
      );
    },
  );
}

Widget _popupDropdown(
  BuildContext context,
  List<String> list,
  String? selectedValue,
  String? name,

  Function(String) onSelected,
) {
  return InkWell(
    onTap: () => _openSearchPopup(context, list, onSelected),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: "Select $name",
        labelStyle:  GoogleFonts.poppins(fontSize: 17, color: Colors.black,fontWeight: FontWeight.bold),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            selectedValue ?? "Select Locality",
            style: GoogleFonts.poppins(
              fontSize: 15,
              color:
                  selectedValue == null ? Colors.grey : Colors.black87,
            ),
          ),
          const Icon(Icons.arrow_drop_down,color: Colors.black,),
        ],
      ),
    ),
  );
}

Widget _mainContent() {
  return SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16).copyWith(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter New Address',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            _field(
              _streetController,
              label: 'Street / Plot no.',
              icon: Icons.location_on,
            ),

            const SizedBox(height: 12),

            _field(
              _areaController,
              label: 'Colony / Area',
              icon: Icons.apartment,
            ),

            const SizedBox(height: 12),

            // 🔹 Dropdown for Area (no Expanded)
               _popupDropdown(
              context,
              areas,
              selectedLocality,
                "Locality",
              (value) {
                setState(() {
                  selectedLocality = value;
                });
              },
            ),
               const SizedBox(height: 12),
        
    _popupDropdown(
              context,
              cities,
              selectedCty,
              "City",
              (value) {
                setState(() {
                  selectedCty = value;
                });
              },
            ),
            const SizedBox(height: 12),

            /// 🔹 ROW: Postal + Verify Button
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

                const SizedBox(width: 12),

                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _verifyingPostal ? null : _verifyPostal,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFF1D4D61),
                      ),
                      child: _verifyingPostal
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          :  Text(
                              'Verify',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ],
            ),

            // const SizedBox(height: 16),

            // const Text("Select City"),
            // const SizedBox(height: 8),

            // _popupDropdown(
            //   context,
            //   cities,
            //   _selectedCity,
            //   (value) {
            //     setState(() {
            //       _selectedCity = value;
            //     });
            //   },
            // ),

            if (_postalCheckResult != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _postalCheckResult! == 'Not Serviceable'
                        ? Icons.close
                        : Icons.check_circle,
                    color: _postalCheckResult! == 'Not Serviceable'
                        ? Colors.red
                        : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_postalCheckResult!),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: _submitAddress,
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1D4D61),
                        Color(0xFF163B4B),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Confirm Address',
                      style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildByState() {
    switch (_state) {
     
   
      case PageState.loggedIn:
        return _mainContent();
         case PageState.loading:
        return ElegantLoadingOverlay();
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
        title:  Text("Edit Address",
            style: GoogleFonts.poppins(color: Colors.white,   fontSize: 16,
                        fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F9FB),
      body: _buildByState());

  }
}
