import 'package:cyklze/SecureStorage/securestorage.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/services.dart';

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

  bool _verifyingPostal = false;
  String? _postalCheckResult;
String? _selectedCity = 'Hyderabad';


  void _showSnack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

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

    setState(() {
      _postalCheckResult = isHyderabad
          ? 'Hyderabad / Secunderabad — Serviceable'
          : 'This location is not servicable';
      _verifyingPostal = false;
    });
  }

  Future<void> _submitAddress() async {
    final street = _streetController.text.trim();
    final area = _areaController.text.trim();
    final postal = _postalController.text.trim();

    final validAddressRegex = RegExp(r"^[a-zA-Z0-9\s\-,./]{3,50}$");


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

    if (_selectedCity == null) {
      _showSnack('Please confirm the city');
      return;
    }

  
      await _verifyPostal();
   

    if ((_postalCheckResult ?? '').contains('not servicable')) {
      _showSnack('We don\'t serve this postal code');
      return;
    }

    final full = '$street, $area, $_selectedCity, $postal';
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
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
        title: const Text("Edit Number",
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16).copyWith(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter New Address',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

                _field(_streetController,
                    label: 'Street / Plot no.', icon: Icons.location_on),
                _field(_areaController,
                    label: 'Colony / Area', icon: Icons.apartment),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _field(_postalController,
                          label: 'Postal Code',
                          icon: Icons.markunread_mailbox,
                          keyboard: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _verifyingPostal ? null : _verifyPostal,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            backgroundColor: const Color(0xFF1D4D61),
                          ),
                          child: _verifyingPostal
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ))
                              : const Text('Verify',
                                  style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Text("Select City"),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: DropdownButtonHideUnderline(
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

                if (_postalCheckResult != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _postalCheckResult!.contains('not servicable')
                            ? Icons.close
                            : Icons.check_circle,
                        color: _postalCheckResult!.contains('not servicable')
                            ? Colors.red
                            : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_postalCheckResult!)),
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
                        gradient: const LinearGradient(colors: [
                          Color(0xFF1D4D61),
                          Color(0xFF163B4B),
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
      ),
    );
  }
}
