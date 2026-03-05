// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class ImageUploadPage extends StatefulWidget {
//   const ImageUploadPage({Key? key}) : super(key: key);

//   @override
//   State<ImageUploadPage> createState() => _ImageUploadPageState();
// }

// class _ImageUploadPageState extends State<ImageUploadPage> {
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImage(ImageSource source) async {
//     final pickedFile = await _picker.pickImage(
//       source: source,
//       imageQuality: 85,
//     );

//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//   }

//   void _saveImage() {
//     if (_selectedImage == null) return;

//     // TODO: Upload to backend here
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Image ready to upload!")),
//     );
//   }

//   void _removeImage() {
//     setState(() {
//       _selectedImage = null;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text("Upload Image"),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),

//             /// Image Preview Card
//             Container(
//               height: 300,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: Colors.grey.shade300),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.shade200,
//                     blurRadius: 10,
//                     spreadRadius: 2,
//                   )
//                 ],
//               ),
//               child: _selectedImage == null
//                   ? Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Icon(Icons.image_outlined,
//                             size: 80, color: Colors.grey),
//                         SizedBox(height: 10),
//                         Text(
//                           "No image selected",
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       ],
//                     )
//                   : ClipRRect(
//                       borderRadius: BorderRadius.circular(20),
//                       child: Image.file(
//                         _selectedImage!,
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                       ),
//                     ),
//             ),

//             const SizedBox(height: 30),

//             /// Pick Buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () => _pickImage(ImageSource.gallery),
//                   icon: const Icon(Icons.photo),
//                   label: const Text("Gallery"),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () => _pickImage(ImageSource.camera),
//                   icon: const Icon(Icons.camera_alt),
//                   label: const Text("Camera"),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                   ),
//                 ),
//               ],
//             ),

//             const Spacer(),

//             /// Action Buttons
//             if (_selectedImage != null)
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: _removeImage,
//                       child: const Text("Remove"),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: _saveImage,
//                       child: const Text("Save"),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({Key? key}) : super(key: key);

  @override
  State<ImageUploadPage> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  /// Handle picking image with permission check
  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final permissionStatus = await _handleCameraPermission();
      if (!permissionStatus) return;
    }

    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// Camera permission logic
  Future<bool> _handleCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog();
      return false;
    }

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission is required.")),
      );
      return false;
    }

    return true;
  }

  /// Show dialog if permanently denied
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Camera Permission Required"),
        content: const Text(
          "Camera access is permanently denied.\n\n"
          "Please enable it from App Settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

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
          "userId": "user123",
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
            style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
return 

Scaffold(
  backgroundColor: Colors.grey[100],
  appBar: AppBar(
    title: const Text("Upload Image"),
    centerTitle: true,
    elevation: 0,
  ),
  body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Header
        Text(
          "Upload an Image",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Select an image from your gallery or take a new photo. "
          "This image will be used for your profile or post.",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),

        const SizedBox(height: 20),

        /// Image picker buttons (always visible)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNeumorphicButton(Icons.camera_alt, "Camera", () => _pickImage(ImageSource.camera)),
            const SizedBox(width: 16),
            _buildNeumorphicButton(Icons.photo, "Gallery", () => _pickImage(ImageSource.gallery)),
          ],
        ),

        const SizedBox(height: 20),

        /// Image display only if an image is selected
        if (_selectedImage != null)
          Center(
            child: Stack(
              children: [
                Container(
                  height: 180, // smaller image display
                  width: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                /// Remove button on top-right
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _removeImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  ),
);



// Scaffold(
//   backgroundColor: Colors.grey[100],
//   appBar: AppBar(
//     title: const Text("Upload Image"),
//     centerTitle: true,
//     elevation: 0,
//   ),
//   body: Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//     child: Column(
//       children: [
//         /// Image Preview with Floating Buttons
//         Stack(
//           children: [
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               height: 220,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: Colors.grey.shade300),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.shade300,
//                     blurRadius: 12,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(20),
//                 child: _selectedImage != null
//                     ? Stack(
//                         fit: StackFit.expand,
//                         children: [
//                           Image.file(
//                             _selectedImage!,
//                             fit: BoxFit.cover,
//                           ),
//                           if (_isUploading)
//                             Container(
//                               color: Colors.black38,
//                               child: const Center(
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       )
//                     : InkWell(
//                         onTap: () => _pickImage(ImageSource.gallery),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: const [
//                             Icon(Icons.image_outlined,
//                                 size: 60, color: Colors.grey),
//                             SizedBox(height: 8),
//                             Text(
//                               "Tap to select image",
//                               style: TextStyle(color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                       ),
//               ),
//             ),

//             /// Neumorphic Floating Buttons
//             Positioned(
//               bottom: 12,
//               right: 12,
//               child: Column(
//                 children: [
//                   _buildNeumorphicFab(Icons.camera_alt, () => _pickImage(ImageSource.camera)),
//                   const SizedBox(height: 10),
//                   _buildNeumorphicFab(Icons.photo, () => _pickImage(ImageSource.gallery)),
//                 ],
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: 16),

//         /// Compact Action Buttons
//         if (_selectedImage != null)
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   style: OutlinedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                   ),
//                   onPressed: _removeImage,
//                   child: const Text("Remove"),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                   ),
//                   onPressed: _isUploading ? null : _uploadImage,
//                   child: _isUploading
//                       ? const SizedBox(
//                           height: 18,
//                           width: 18,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Text("Save"),
//                 ),
//               ),
//             ],
//           ),
//       ],
//     ),
//   ),
// );








// Scaffold(
//   backgroundColor: Colors.grey[100],
//   appBar: AppBar(
//     title: const Text("Upload Image"),
//     centerTitle: true,
//     elevation: 0,
//   ),
//   body: Padding(
//     padding: const EdgeInsets.all(16),
//     child: Column(
//       children: [
//         /// Image Preview with Floating Buttons
//         Stack(
//           children: [
//             Container(
//               height: 250,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: Colors.grey.shade300),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.shade200,
//                     blurRadius: 10,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(20),
//                 child: _selectedImage != null
//                     ? Image.file(
//                         _selectedImage!,
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                       )
//                     : Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           Icon(Icons.image_outlined,
//                               size: 60, color: Colors.grey),
//                           SizedBox(height: 8),
//                           Text(
//                             "No image selected",
//                             style: TextStyle(color: Colors.grey),
//                           ),
//                         ],
//                       ),
//               ),
//             ),

//             /// Floating Pick Buttons
//             Positioned(
//               bottom: 10,
//               right: 10,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   FloatingActionButton(
//                     heroTag: "camera",
//                     mini: true,
//                     onPressed: () => _pickImage(ImageSource.camera),
//                     child: const Icon(Icons.camera_alt),
//                   ),
//                   const SizedBox(height: 10),
//                   FloatingActionButton(
//                     heroTag: "gallery",
//                     mini: true,
//                     onPressed: () => _pickImage(ImageSource.gallery),
//                     child: const Icon(Icons.photo),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: 20),

//         /// Action Buttons at bottom
//         if (_selectedImage != null)
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: _removeImage,
//                   child: const Text("Remove"),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: _isUploading ? null : _uploadImage,
//                   child: _isUploading
//                       ? const SizedBox(
//                           height: 18,
//                           width: 18,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Text("Save"),
//                 ),
//               ),
//             ],
//           ),
//       ],
//     ),
//   ),
// );
 }
}
