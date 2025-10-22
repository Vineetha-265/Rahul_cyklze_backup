import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cyklze/Provider/pickup_provider.dart';
import 'package:cyklze/SecureStorage/securestorage.dart';
import 'package:cyklze/Views/error.dart';
import 'package:cyklze/Views/loading.dart';
import 'package:cyklze/Views/loginrequird.dart';
import 'package:cyklze/Views/offline.dart';
import 'package:cyklze/enums/page_state.dart';
import 'package:cyklze/main.dart';
import 'package:cyklze/screens/edit_address.dart';
import 'package:cyklze/screens/home_page.dart';
import 'package:cyklze/screens/update_number.dart';
import 'package:cyklze/screens/verification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';


const String _tokenUrl =
     "https://20pnz6cr8e.execute-api.ap-south-1.amazonaws.com/cyklzee/cyklzee/handleuser";
class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({super.key});

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {

  String? _savedAddress;
  final bool _loading = false;
  String _selectedCity = 'Hyderabad';
  Pagestate _state = Pagestate.loggedIn;
  Color get _brand => const Color(0xFF2E7D32);
 Future<void> _loadSavedAddress() async {
    final a = await SecureStorage.getAddress();
    setState(() => _savedAddress = a);
  }
    @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
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
        title: const Text("Account Management",
            style: TextStyle(color: Colors.white,  fontSize: 16,
                        fontWeight: FontWeight.w800,)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
    
      body:_buildByState(),
      
      );
  }


  Widget _buildByState() {
    switch (_state) {
      case Pagestate.loading:
        return const ElegantLoadingOverlay();
        
      case Pagestate.notLogged:
        return LoginRequired(
        message: "Please log in to edit profile",
        onLogin: () async{
         final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PhoneVerificationPage()),
          );
          if (result == true) {
            await _checkTokenExpiration();
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
        return maincontent();
    }
  }




Future<void> _checkTokenExpiration() async {
  final accessToken = await SecureStorage.getAccessToken();
  final refreshToken = await SecureStorage.getRefreshToken();

  if (accessToken == null) {
    setState(() => _state = Pagestate.notLogged);
    return;
  }

  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    setState(() => _state = Pagestate.offline);
    return;
  }

  setState(() => _state = Pagestate.loading);

  try {
    final resp = await http.delete(
      Uri.parse(_tokenUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'accessToken': accessToken}),
    );

    if (resp.statusCode == 200) {
  setState(() => _state = Pagestate.notLogged);
await SecureStorage.clearAll();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Successfully deleted your account.'),
    
      duration: Duration(seconds: 2),
    
    ),
  );

 Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (context) => const HomePage()),
  (Route<dynamic> route) => false,
);

  return;
}

     else {
      
final   provider = Provider.of<PickupProvider>(context, listen: false);
       Pagestate result = await provider.refreshAccessToken(_checkTokenExpiration,"exe");
             setState(() => _state = result);
     
    }
  } catch (e) {
    setState(() => _state = Pagestate.error);
  }
}

 Widget maincontent() {

  void confirmDelete(BuildContext context) async{
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFFF5F5F5),
      title: Semantics(
        label: 'Delete confirmation title',
        child: const Text(
          "Are you sure you want to Delete your account?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1D4D61),
          ),
        ),
      ),
      content: Semantics(
        label: 'Delete confirmation message',
        child: const Text(
          "You'll need to create an account to continue using the app.",
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
       Semantics(
  label: 'Cancel Delete action',
  button: true,
  child: OutlinedButton(
    onPressed: () => Navigator.pop(ctx),
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: Colors.grey),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: const Text(
      "Cancel",
      style: TextStyle(color: Colors.grey),
    ),
  ),
),

        Semantics(
          label: 'Confirm Delete',
          button: true,
          child: ElevatedButton(
            onPressed: () async{
              Navigator.pop(ctx);
             await _checkTokenExpiration();  
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4D61),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Delete"),
          ),
        ),
      ],
    ),
  );
}

  return Container(
    color: Colors.grey[100],
    child: Stack(
      children: [
        CustomScrollView(
          slivers: [
           
            SliverToBoxAdapter(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  children: [
                    Semantics(
                      label: 'Phone Number Info Card',
                      child: _InfoCard(
                        title: "Edit Phone Number",
                        subtitle: "This number is used for login, updates, and pickups.",
                        icon: Icons.phone_rounded,
                        accent: _brand,
                        actionText: "Edit",
                        onTap: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => const EditMobileNumberPage())),
                      ),
                    ),
               
                    Semantics(
                      label: 'Address Info Card',
                      child: _InfoCard(
                        title: "Edit Address",
                        subtitle: "Default pickup address. You can change it anytime.",
                        value: _savedAddress,
                        icon: Icons.home_rounded,
                        accent: Colors.teal,
                        actionText: "Edit",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditAddressPage()))
,
                      ),
                    ),
                    const SizedBox(height: 5),
                  
                    Semantics(
                      label: 'Danger Zone Info Card',
                      child: _DangerZone(
                        onDelete: () async {
                       confirmDelete(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        if (_loading)
          Positioned.fill(
            child: Semantics(
              label: 'Loading overlay',
              child: Container(
                color: Colors.grey.withOpacity(0.6),
                child: const Center(
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}


Future<void> _openAddressSheet() async {
  final streetController = TextEditingController();
  final areaController = TextEditingController();
  final postalController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool verifyingPostal = false;
  String? postalCheckResult;

  void showSnack(String m) => Flushbar(
  message: m,
  margin: const EdgeInsets.all(8),
  padding: const EdgeInsets.all(16),
  borderRadius: BorderRadius.circular(8),
  flushbarPosition: FlushbarPosition.BOTTOM,
  isDismissible: true,
  duration: const Duration(seconds: 3),
)..show(context);


 Future<void> verifyPostal() async {
  final postal = postalController.text.trim();

  if (postal.isEmpty) {
    showSnack('Enter postal code first');
    return;
  }

  if (postal.length != 6 || int.tryParse(postal) == null) {
    showSnack('Postal code should be 6 digits');
    return;
  }

  setState(() {
    verifyingPostal = true;
    postalCheckResult = null;
  });

  await Future.delayed(const Duration(milliseconds: 500));

  final pin = int.parse(postal);
  final isHyderabad = postal.startsWith('500') && pin >= 500001 && pin <= 500099;

  if (isHyderabad) {
    setState(() {
      postalCheckResult = 'Hyderabad / Secunderabad — Serviceable';
    });
  } else {
    setState(() {
      postalCheckResult = 'not found';
    });
  }

  setState(() {
    verifyingPostal = false;
  });
}
  Future<void> submitAddress() async {
    final street = streetController.text.trim();
    final area = areaController.text.trim();
    final postal = postalController.text.trim();


  final validAddressRegex = RegExp(r"^[a-zA-Z0-9\s\-,./]{3,50}$");
    if (street.isEmpty || area.isEmpty) {
      showSnack('Please enter complete address');
      return;
    }

    if (postal.length != 6 || int.tryParse(postal) == null) {
      showSnack('Postal code should be 6 digits');
      return;
    }
  if (!validAddressRegex.hasMatch(street)) {
    showSnack('Invalid street address format.');
    return ;
  }

  if (!validAddressRegex.hasMatch(area)) {
    showSnack('Invalid area name format.');
    return ;
  }
    if (street.isEmpty || area.isEmpty) {
      showSnack('Please enter complete address');
      return;
    }

    if (postal.length != 6 || int.tryParse(postal) == null) {
      showSnack('Postal code should be 6 digits');
      return;
    }
    if (_selectedCity == null) {
      showSnack('Please confirm the city');
      return;
    }
    if (postalCheckResult == null) {
      await verifyPostal();
    }

    if ((postalCheckResult ?? '').contains('not found')) {
      showSnack('We don\'t serve this postal code');
      return;
    }

    final full = '$street, $area, $_selectedCity, ${postalCheckResult!}, $postal';
    await SecureStorage.saveAddress(full);
    Navigator.pop(context);
    showSnack("Address saved successfully");
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            StatefulBuilder(
              builder: (ctx, setState) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                    top: 8,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          label: 'Enter New Address',
                          child: Text(
                            'Enter New Address',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 12),
            
                        _field(streetController,
                            label: 'Street / Plot no.', icon: Icons.location_on),
                        _field(areaController,
                            label: 'Colony / Area', icon: Icons.apartment),
            
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _field(postalController,
                                  label: 'Postal Code',
                                  icon: Icons.markunread_mailbox,
                                  keyboard: TextInputType.number),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Semantics(
                                label: 'Verify postal code',
                                child: SizedBox(
                                  height: 58,
                                  child: ElevatedButton(
                                    onPressed: verifyingPostal ? null : verifyPostal,

                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      
                                      ),
                                      backgroundColor: const Color(0xFF1D4D61),
                                    ),
                                    child: verifyingPostal
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ))
                                        : const Text('Verify',style: TextStyle(color: Colors.white),),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
            const Text("Select city"),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey), 
                            ),
                            child: DropdownButtonHideUnderline(
                              child: Semantics(
                                label: 'Select City',
                                child: DropdownButton<String>(
                                  value: _selectedCity,
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down),
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
                          ),
                        ),
            
                        if (postalCheckResult != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                postalCheckResult!.contains('not found')
                                    ? Icons.close
                                    : Icons.check_circle,
                                color: postalCheckResult!.contains('not found')
                                    ? Colors.red
                                    : Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(postalCheckResult!)),
                            ],
                          ),
                        ],
            
                        const SizedBox(height: 22),
            
                        Semantics(
                          label: 'Confirm address and save',
                          child: SizedBox(
                            width: double.infinity,
                            child: InkWell(
                              onTap: submitAddress,
                              borderRadius: BorderRadius.circular(14),
                              child: Ink(
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [
                                 Color(0xFF1D4D61), Color(0xFF163B4B)
                                  ]),
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
                                    style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

Widget _field(
  TextEditingController controller, {
  required String label,
  required IconData icon,
  TextInputType keyboard = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Semantics(
      label: 'Enter $label',
      textField: true,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? "Please enter $label" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          contentPadding: const EdgeInsets.all(14),
        ),
        onChanged: (text) {
        },
      ),
    ),
  );
}




}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? value;
  final IconData icon;
  final Color accent;
  final String actionText;
  final VoidCallback onTap;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    this.value,
    required this.icon,
    required this.accent,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAccentRed = accent == Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isAccentRed ? Colors.red.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isAccentRed ? Colors.red : const Color(0xFF1D4D61),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Semantics(
                  label: 'Card Title: $title',
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isAccentRed ? Colors.red : Colors.black87,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isAccentRed ? Colors.red : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class _DangerZone extends StatelessWidget {
  final VoidCallback onDelete;

  const _DangerZone({required this.onDelete});

  @override
Widget build(BuildContext context) {
  return Material(
    color: Colors.red.shade50,
    elevation: 0,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: 'Danger Zone',
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  "Danger Zone",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w800,
                      fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: 'Description about account deletion',
            child: Text(
              "Deleting your account is permanent and cannot be undone.",
              style: TextStyle(color: Colors.red.shade700, height: 1.3),
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            label: 'Delete Account button',
            button: true, 
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onDelete,
              child: const Text("Delete Account"),
            ),
          ),
        ],
      ),
    ),
  );
}


}
