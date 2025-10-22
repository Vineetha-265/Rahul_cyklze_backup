import 'dart:convert';
import 'package:cyklze/Views/error.dart';
import 'package:cyklze/Views/loading.dart';
import 'package:cyklze/Views/loginrequird.dart';
import 'package:cyklze/Views/offline.dart';
import 'package:cyklze/screens/verification.dart';
import 'package:flutter/material.dart';

import 'package:cyklze/enums/page_state.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cyklze/SecureStorage/securestorage.dart'; 

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  static const String companyEmail = 'support@cyklze.com';

  bool isLoading = false;
  bool isOffline = false;
  bool isError = false;
  bool isLoggedIn = false;
  int refreshAttempts = 0;
  final int maxRefreshAttempts = 2;
  Pagestate _state = Pagestate.loggedIn;
  @override
  void initState() {
    super.initState();
    _initialView();
  }

  Future<void> _initialView() async {
    setState(() {
      isLoading = true;
      isError = false;
      isOffline = false;
    });

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      setState(() {
        isOffline = true;
        isLoading = false;
      });
      return;
    }

    final accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      setState(() {
        isLoggedIn = false;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoggedIn = true;
        isLoading = false;
      });
    }
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
          "You have recently registered a call back, you cannot register one more.",   style: TextStyle(fontSize: 14, color: Colors.black),
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



  Future<void> _requestCallback() async {

    final accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) {
      setState(() {
  _state = Pagestate.notLogged;
      });
      return;
    }

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      setState(() {
              _state = Pagestate.offline;
            });
      return;
    }
 setState(() {
              _state = Pagestate.loading;
            });
    final url = Uri.parse(
        "https://20pnz6cr8e.execute-api.ap-south-1.amazonaws.com/cyklzee/cyklzee/help");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
        body: jsonEncode({
          "accessToken": accessToken,
          "comment": "call back request",
        }),
      );

      if (response.statusCode == 200) {
       
       setState(() {
              _state = Pagestate.loggedIn;
            });
      if (!mounted) return;
         final Map<String, dynamic> responseBody = jsonDecode(response.body);
    final message = responseBody['message'];
    if(message.toString().toLowerCase().contains("pending")){
      confirmLogout(context);
     setState(() => _state = Pagestate.loggedIn);

    }else{
 ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully Done, We will call you as soon as possible.")),
        );
    }
        
       
      } else {
        final body = jsonDecode(response.body);
        final errorMessage = body["error"] ?? "Something went wrong";

        if (errorMessage == "Invalid token" &&
            refreshAttempts < maxRefreshAttempts) {
          refreshAttempts++;
          final refreshToken = await SecureStorage.getRefreshToken();
          if (refreshToken != null) {
            await _refreshAccessToken(refreshToken);
          } else {
             final refreshToken = await SecureStorage.getRefreshToken();
           await _refreshAccessToken(refreshToken!);
          }
        } else {
         setState(() {
              _state = Pagestate.error;
            });
        }
      }
    } catch (e) {
      setState(() {
              _state = Pagestate.error;
            });
    }
  }

  Future<void> _refreshAccessToken(String refreshToken) async {
    final url = Uri.parse(
        "https://20pnz6cr8e.execute-api.ap-south-1.amazonaws.com/cyklzee/cyklzee/handletoken");
   setState(() {
              _state = Pagestate.loading;
            });
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data["accessToken"];
        final newRefreshToken = data["refreshToken"];

        await SecureStorage.saveAccessToken(newAccessToken);
        await SecureStorage.saveRefreshToken(newRefreshToken);

        await _requestCallback();
      } else {
     setState(() {
              _state = Pagestate.notLogged;
            });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Session expired. Please log in again.")),
        );
      }
    } catch (e) {
     setState(() {
              _state = Pagestate.error;
            });
    }
  }

  void _copyEmail() {
    Clipboard.setData(const ClipboardData(text: companyEmail));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email copied to clipboard')),
    );
  }


 Widget _buildByState() {
    switch (_state) {
      case Pagestate.loading:
        return const ElegantLoadingOverlay();
        
       
      case Pagestate.notLogged:
        return LoginRequired(
        message: "Please log in to get a callback",
        onLogin: () async{
         final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PhoneVerificationPage()),
          );
          if (result == true) {
          
            setState(() {
              _state = Pagestate.loggedIn;
            });
          }else{
            setState(() {
              _state = Pagestate.notLogged;
            });
          }
        },
      );
      case Pagestate.offline:
        return OfflineRetry(
      onRetry: () =>{  setState(() {
              _state = Pagestate.loggedIn;
            })}, 
    );
      case Pagestate.error:
        return  ErrorRetry(
              message: "Something went wrong",
              onRetry:  () =>{  setState(() {
              _state = Pagestate.loggedIn;
            })},
            );
      case Pagestate.loggedIn:
        return _maincon();
    }
  }



Widget _maincon() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
     Semantics(
          label: 'Support availability hours information',
          readOnly: true,
          child: Container( decoration: BoxDecoration(
      color: Colors.transparent, // or any background color
  borderRadius: BorderRadius.circular(12),
   ),
            child: const Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 18,
              ),
              child: Text(
                '📬 Feel free to drop us an email or ask for a callback anytime.\n\n'
                '🕒 We’re around daily from 7:00 AM to 10:00 PM — got you covered!',
                style: TextStyle(
                      color: const Color(0xFF4A4A4A),
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                      fontSize: 15.5,
                    ),
              ),
            ),
          ),
        ),
    const SizedBox(height: 4,),
        Semantics(
          label: 'Contact support via email',
          child: _buildSupportCard(
            icon: Icons.email_outlined,
            iconColor: const Color(0xFF6C63FF),
            title: 'Email us',
            subtitle: companyEmail,
            trailing: Tooltip(
              message: 'Copy email to clipboard',
              child: IconButton(
                icon: const Icon(Icons.copy_rounded, color: Colors.grey),
                onPressed: _copyEmail,
              ),
            ),
            onTap: () {}, 
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          label: 'Request a phone callback from support',
          child: _buildSupportCard(
            icon: Icons.phone_callback_outlined,
            iconColor: const Color(0xFF00BFA6),
            title: 'Request a callback',
            subtitle: 'Prefer to talk? We’ll call you.',
            trailing: Tooltip(
              message: 'Request a callback',
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4D61),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  textStyle:const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                onPressed: _requestCallback,
                child: const Text("Get a callback"),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

     ],
    ),
  );
}


Widget _mainView() => Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
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
        title: const Text("Help & Support",
            style: TextStyle(color: Colors.white,   fontSize: 16,
                        fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Semantics(
        container: true,
        label: 'Help and support content area',
        child: _buildByState(),
      ),
    );



Widget _buildSupportCard({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  Widget? trailing,
  VoidCallback? onTap,
}) {
  return Semantics(
    label: 'Support card: $title',
    child: Container(
      decoration: BoxDecoration(
      color: Colors.white, // or any background color
  borderRadius: BorderRadius.circular(12),
   ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.grey.withOpacity(0.1), 
        highlightColor: Colors.grey.withOpacity(0.1), 
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.15),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(
            title,
            style: const TextStyle( fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1C1C1E), ),
          ),
          subtitle: Text(
            subtitle,
           style: const TextStyle(color: Colors.black54),
          ),
          trailing: trailing,
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return _mainView();
  }
}

