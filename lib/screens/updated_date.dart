import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cyklze/Provider/pickup_provider.dart';
import 'package:cyklze/SecureStorage/securestorage.dart';
import 'package:cyklze/Views/error.dart';
import 'package:cyklze/Views/loading.dart';
import 'package:cyklze/Views/loginrequird.dart';
import 'package:cyklze/Views/offline.dart';
import 'package:cyklze/enums/page_state.dart';
import 'package:cyklze/screens/address.dart';
import 'package:cyklze/screens/upload.dart';
import 'package:cyklze/screens/verification.dart';
import 'package:cyklze/widgets/date_time.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// class PostalCodeRange {
//   final int min;
//   final int max;

//   PostalCodeRange({required this.min, required this.max});

//   factory PostalCodeRange.fromJson(Map<String, dynamic> json) {
//     return PostalCodeRange(
//       min: json['min'],
//       max: json['max'],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'min': min,
//         'max': max,
//       };

//   bool contains(int postalCode) =>
//       postalCode >= min && postalCode <= max;
// }

class AvailableDatesResponse {
  final String message;
  final List<String> dates;
  final List<String> areas;
  final List<String> cities;
  final List<String> slots;
  final List<PostalCodeRange> postalCodeRanges;
  final String regx;
  final String popup_heading;
  final String allowcamera;
  final String popup_content;
  final String popup_btn;
  final String popup;

  AvailableDatesResponse({
    required this.message,
    required this.dates,
    required this.areas,
    required this.cities,
      required this.allowcamera,
     required this.popup,
      required this.popup_btn,
       required this.popup_content,
        required this.popup_heading,
    required this.slots,
    required this.postalCodeRanges,
    required this.regx,
  });

  factory AvailableDatesResponse.fromJson(Map<String, dynamic> json) {
    return AvailableDatesResponse(
      message: json['message'] ?? '',
      regx: json['regx'] ?? '',
        allowcamera: json['allowcamera'] ?? '',
       popup: json['popup'] ?? '',
        popup_btn: json['popup_btn'] ?? '',
         popup_content: json['popup_content'] ?? '',
          popup_heading: json['popup_heading'] ?? '',
      dates: List<String>.from(json['dates'] ?? []),
      areas: List<String>.from(json['areas'] ?? []),
      cities: List<String>.from(json['cities'] ?? []),
      slots: List<String>.from(json['slots'] ?? []),
      postalCodeRanges: (json['postalCodeRanges'] ?? [])
          .map<PostalCodeRange>((e) => PostalCodeRange.fromJson(e))
          .toList(),
    );
  }
}
class PickupDateTimeSelector extends StatefulWidget {
  final List<String> names;
  final String pickuptype;

  const PickupDateTimeSelector({Key? key, required this.names,required this.pickuptype})
      : super(key: key);

  @override
  State<PickupDateTimeSelector> createState() =>
      _PickupDateTimeSelectorState();
}

class _PickupDateTimeSelectorState
    extends State<PickupDateTimeSelector> {
  Pagestate _state = Pagestate.loading;

  String selectedDate = '';
  String? selectedTimeRange;
  int? selectedDateIndex;
  String popup_heading ='';
    String popup_content = '';
      String popup_btn = '';
        String popup ='';
  int? selectedSlotIndex;
String allowcamera ="no";
  List<String> availableDates = [];
  List<String> slots = [];
  String apiMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }


  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
 
  /// Handle picking image with permission check
Future<void> _pickImage(ImageSource source) async {
  if (source == ImageSource.camera) {
    final permissionStatus = await _handleCameraPermission();
    if (!permissionStatus) return;
  }

try {
  final pickedFile = await _picker.pickImage(
    source: source,
    imageQuality: 15,
  );

  if (pickedFile != null && mounted) {
    setState(() {
      _selectedImage = File(pickedFile.path);
    });
  }
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to pick image.")),
    );
  }
}
}

// Future<bool> _handleCameraPermission() async {
// final status = await Permission.camera.request();

// ScaffoldMessenger.of(context).showSnackBar(
//   SnackBar(
//     content: Text("Camera permission status: $status"),
//     duration: const Duration(seconds: 3),
//   ),
// );
//   // ✅ Granted
//   if (status.isGranted) {
//     return true;
//   }

//   // ❌ Permanently denied / restricted (iOS + Android "Don't ask again")
//   if (status.isPermanentlyDenied || status.isRestricted) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Camera permission is permanently denied. Please enable it from Settings."),
//           duration: Duration(seconds: 3),
//         ),
//       );

//       await Future.delayed(const Duration(milliseconds: 500));
//       _showPermissionDialog(); // your dialog with "Open Settings"
//     }
//     return false;
//   }

//   // ❌ Denied (first time or normal deny)
//   if (status.isDenied) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Camera permission denied. Please allow it to continue."),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//     return false;
//   }

//   // ❌ Fallback (rare cases)
//   if (mounted) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text("Unable to access camera. Please try again."),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   return false;
// }






Future<bool> _handleCameraPermission() async {
  // Always request first (important for iOS)
  final status = await Permission.camera.request();

  // ✅ Permission granted
  if (status.isGranted) {
    return true;
  }

  // ❌ User denied permanently OR iOS restricted
  if (status.isPermanentlyDenied || status.isRestricted) {
    if (mounted) {
      _showPermissionDialog();
    }
    return false;
  }

  // ❌ Just denied (first time or temporary)
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Camera permission is required.")),
    );
  }

  return false;
}
  
  
  /// Camera permission logic
// Future<bool> _handleCameraPermission() async {
//   var status = await Permission.camera.status;

//   if (status.isDenied) {
//     status = await Permission.camera.request();
//   }

//   if (status.isPermanentlyDenied || status.isRestricted) {
//     _showPermissionDialog();
//     return false;
//   }

//   if (!status.isGranted) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Camera permission is required.")),
//       );
//     }
//     return false;
//   }

//   return true;
// }

  /// Show dialog if permanently denied
  void _showPermissionDialog() {
showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        "Camera Permission Required",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
      content: Text(
        "Camera access is permanently denied.\n\nPlease enable it from App Settings.",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.normal,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.blue,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            openAppSettings();
            Navigator.pop(context);
          },
          child: Text(
            "Open Settings",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    ),
  );}

  /// Upload Image to Backend
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final bytes = await _selectedImage!.readAsBytes();
      String base64Image = base64Encode(bytes);

      final response = await http.put(
        Uri.parse(
            "https://api.cyklze.com/cyklzee/upload"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
       
          "imageBase64": base64Image,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image uploaded successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Upload failed! Status: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() {
      _isUploading = false;
    });
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }
  
// Neumorphic Floating Button
Widget _buildNeumorphicFab(IconData icon, VoidCallback onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade500,
            offset: const Offset(4, 4),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.white,
            offset: const Offset(-4, -4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.grey[800]),
    ),
  );
}


/// Neumorphic button builder
Widget _buildNeumorphicButton(IconData icon, String label, VoidCallback onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade500,
            offset: const Offset(4, 4),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.white,
            offset: const Offset(-4, -4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[800]),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.grey[800], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );
}

  Future<void> _loadData() async {
    final provider =
        Provider.of<PickupProvider>(context, listen: false);

    if (!await provider.hasInternetConnection()) {
      setState(() => _state = Pagestate.offline);
      return;
    }

    setState(() => _state = Pagestate.loading);

    try {
      const apiUrl =
          'https://api.cyklze.com/cyklzee/dateandaddress';

      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        setState(() => _state = Pagestate.error);
        return;
      }

      final jsonMap = json.decode(response.body);
      final data = AvailableDatesResponse.fromJson(jsonMap);

      apiMessage = data.message;
      allowcamera = data.allowcamera;
      availableDates = data.dates;
      slots = data.slots;
      popup = data.popup;
        popup_btn = data.popup_btn;
          popup_content = data.popup_content;
            popup_heading = data.popup_heading;


      await SecureStorage.saveAreas(data.areas);
      await SecureStorage.saveCities(data.cities);
      await SecureStorage.saveRegx(data.regx);
      await SecureStorage.savePostalRange(
          data.postalCodeRanges);

      setState(() => _state = Pagestate.loggedIn);
        WidgetsBinding.instance.addPostFrameCallback((_) {
    if(popup.toLowerCase().contains("yes"))showMaxWeightDialog1(context);
  });
    } catch (_) {
      setState(() => _state = Pagestate.error);
    }
  }

  Widget _buildDateSection() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(
        availableDates.length,
        (index) {
          final isSelected =
              selectedDateIndex == index;

          return ChoiceChip(
            label: Text(
  availableDates[index],
  style: GoogleFonts.poppins(
    fontSize: 14,         // adjust as needed
    fontWeight: FontWeight.w500, // medium weight
    color: Colors.black87, // adjust as needed
  ),
),
            selected: isSelected,
            selectedColor:
                const Color(0xFF1D4D61),
            labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Colors.black,
            ),
            onSelected: (_) {
              setState(() {
                selectedDate =
                    availableDates[index];
                selectedDateIndex = index;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildSlotSection() {
    if (slots.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
         Text(
          "Select Time Slot",
          style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(
            slots.length,
            (index) {
              final isSelected =
                  selectedSlotIndex == index;

              return ChoiceChip(
                label: Text(slots[index]),
                selected: isSelected,
                selectedColor:
                    const Color(0xFF1D4D61),
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.black,
                ),
                onSelected: (_) {
                  setState(() {
                    selectedSlotIndex =
                        index;
                    selectedTimeRange =
                        slots[index];
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

void showMaxWeightDialog1(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        child: 
    Padding(
  padding: const EdgeInsets.all(20.0),
  child: SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Container(
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     shape: BoxShape.circle,
        //   ),
        //   padding: const EdgeInsets.all(16),
        //   child: const Icon(
        //     Icons.warning_amber_rounded,
        //     color: Color(0xFF1D4D61),
        //     size: 40,
        //   ),
        // ),
        const SizedBox(height: 20),
        Text(
          popup_heading ,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          popup_content,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1D4D61),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              popup_btn,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),  );
    },
  );
}
  
  void _continue() async {
    if (selectedDate.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(
              content:
                  Text("Select a date")));
      return;
    }

    // if (slots.isNotEmpty &&
    //     selectedTimeRange == null) {
    //   ScaffoldMessenger.of(context)
    //       .showSnackBar(const SnackBar(
    //           content:
    //               Text("Select a time slot")));
    //   return;
    // }

    // if (widget.names.isEmpty) {
    //   ScaffoldMessenger.of(context)
    //       .showSnackBar(const SnackBar(
    //           content: Text(
    //               "Add recyclable items")));
    //   return;
    // }

    await Provider.of<PickupProvider>(
            context,
            listen: false)
        .setPickupDetails(
      date: selectedDate,
      time: selectedDate ?? "today",
      type: widget.pickuptype,
      items: widget.names,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreativeAddressPage(
          selectedDate: selectedDate,
          selectedTimeRange:
              selectedDate ??
                  "today",
                  image: _selectedImage?? null,
          selectedType: widget.pickuptype,
          selectedItems:
              widget.names,
        ),
      ),
    );
  }

Widget _readyView() {
  return Scaffold(
    backgroundColor: Colors.grey.shade100,
    appBar: AppBar(
     flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1D4D61), Color(0xFF163B4B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title:  Text("Schedule",
            style: GoogleFonts.poppins(color: Colors.white,   fontSize: 16,
                        fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
    ),
    body: SafeArea(
      child: apiMessage.contains("surge")
          ? _buildCompactSurgeUI()
          : Column(
              children: [
                /// MAIN CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: SizedBox(
                      width:  double.infinity,
                      child: Column(
                        
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                      
                          /// DATE SECTION
                          _sectionTitle("Select Date"),
                           Text(
                          apiMessage,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                          
                            color: Colors.grey.shade800,
                          ),
                        ),
                          const SizedBox(height: 8),
                          _buildDateSection(),
                      
                          // if (slots.isNotEmpty) ...[
                          //   const SizedBox(height: 14),
                          //   _sectionTitle("Time"),
                          //   const SizedBox(height: 8),
                          //   _buildSlotSection(),
                          // ],
                      
                          const SizedBox(height: 18),
                      
                          /// IMAGE UPLOAD CARD (Compact + Advanced)
                      if(allowcamera.toLowerCase().contains("yes"))
                          _buildImageUploadCard(),
                        ],
                      ),
                    ),
                  ),
                ),

                /// STICKY BUTTON
                _buildBottomButton(),
              ],
            ),
    ),
  );
}

Widget _sectionTitle(String text) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade800,
    ),
  );
}
Widget _buildImageUploadCard() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.image_outlined,
                size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 6),
             Text(
              "Select Scrap Image",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
              "Please upload an image of the scrap so we can better assess the quantity you have.",
              style: GoogleFonts.poppins(
                fontSize: 12,
               
              ),
            ),

        const SizedBox(height: 10),

        /// Stack-based compact image layout
        SizedBox(
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [

              /// Background container
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.grey.shade300),
                  color: Colors.grey.shade50,
                ),
              ),

              /// If image selected
              if (_selectedImage != null)
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(14),
                  child: Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              /// Overlay buttons
              Positioned(
                bottom: 8,
                left: 8,
                child: Row(
                  children: [
                    _miniIconButton(
                      Icons.camera_alt,
                      () => _pickImage(ImageSource.camera),
                    ),
                    const SizedBox(width: 8),
                    _miniIconButton(
                      Icons.photo,
                      () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
              ),

              /// Remove button top right
              if (_selectedImage != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _removeImage,
                    child: Container(
                      padding:
                          const EdgeInsets.all(6),
                      decoration:
                          const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
Widget _miniIconButton(
    IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1D4D61),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 16,
        color: Colors.white,
      ),
    ),
  );
}Widget _buildBottomButton() {
 final bool isDisabled =
    (allowcamera.contains("yes") && _selectedImage == null) ||
    (selectedDate == null || selectedDate!.isEmpty);

  return Container(
    padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isDisabled
              ? Colors.grey.shade400   // Disabled color
              : const Color(0xFF1D4D61), // Active color
          minimumSize: const Size(double.infinity, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: isDisabled ? null : _continue,
        child:  Text(
          "Continue",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}

Widget _buildCompactSurgeUI() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_up_rounded,
            size: 52,
            color: Colors.deepPurple.shade400,
          ),
          const SizedBox(height: 16),

           Text(
            "High Traffic Detected",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "We're currently experiencing a surge in activity.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Please wait a moment and try again.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.4,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            "Thank you for your patience ❤️",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.deepPurple.shade300,
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case Pagestate.loading:
        return const Scaffold(
          body:
              ElegantLoadingOverlay(),
        );

      case Pagestate.offline:
        return Scaffold(
          body: OfflineRetry(
              onRetry: _loadData),
        );

      case Pagestate.error:
        return Scaffold(
          body: ErrorRetry(
              message:
                  "Something went wrong",
              onRetry: _loadData),
        );

      case Pagestate.notLogged:
        return Scaffold(
          body: LoginRequired(
            message:
                "Please log in to continue",
            onLogin: () async {
              final result =
                  await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PhoneVerificationPage(),
                ),
              );
              if (result == true) {
                _loadData();
              }
            },
          ),
        );

      case Pagestate.loggedIn:
      default:
        return _readyView();
    }
  }
}
