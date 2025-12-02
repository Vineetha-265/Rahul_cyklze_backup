import 'dart:async';
import 'dart:convert';
import 'package:cyklze/Provider/pickup_provider.dart';
import 'package:cyklze/SecureStorage/securestorage.dart';
import 'package:cyklze/Views/error.dart';
import 'package:cyklze/Views/loading.dart';
import 'package:cyklze/Views/loginrequird.dart';
import 'package:cyklze/Views/offline.dart';
import 'package:cyklze/screens/help_page.dart';
import 'package:cyklze/enums/page_state.dart';
import 'package:cyklze/screens/home_page.dart';
import 'package:cyklze/screens/pickup_history.dart';
import 'package:cyklze/screens/price_page.dart';
import 'package:cyklze/screens/profile_management.dart';
import 'package:cyklze/screens/verification.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  late final provider;
  bool loggedOut = false;
  String? phoneNumber;

  Pagestate _state = Pagestate.loading;
  static const profileUrl =
      "https://20pnz6cr8e.execute-api.ap-south-1.amazonaws.com/cyklzee/cyklzee/profile";
  static const logoutUrl =
      "https://20pnz6cr8e.execute-api.ap-south-1.amazonaws.com/cyklzee/cyklzee/logoutordelete";
  static const refreshUrl =
      "https://20pnz6cr8e.execute-api.ap-south-1.amazonaws.com/cyklzee/cyklzee/handletoken";

@override
void initState() {
  super.initState();

  provider = Provider.of<PickupProvider>(context, listen: false);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    fetchProfile();
  });
}



  Future<bool> _hasConnection() async {
    final status = await Connectivity().checkConnectivity();
    return status != ConnectivityResult.none;
  }

Future<void> fetchProfile() async {
  final   provider = Provider.of<PickupProvider>(context, listen: false);
  if (!await provider.hasInternetConnection()) {
    setState(() => _state = Pagestate.offline);
    return;
  }

  if (mounted) {
  setState(() => _state = Pagestate.loading);
  }

  final connected = await _hasConnection();
  if (!connected) {
     setState(() => _state = Pagestate.offline);
    return;
  }

  final token = await SecureStorage.getAccessToken();
  if (token == null) {
    setState(() => _state = Pagestate.notLogged);
    return;
  }

  try {
    final response = await http
        .get(Uri.parse(profileUrl), headers: {
          "Authorization": token.toString(),
        })
        .timeout(const Duration(seconds: 10)); 

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
    
        setState(() 
       {phoneNumber = data["phone_number"]?.toString(); 
        _state = Pagestate.loggedIn;
       });
    } else if (response.statusCode == 401) {
      final provider = Provider.of<PickupProvider>(context, listen: false);
          Pagestate result = await provider.refreshAccessToken(fetchProfile,"exe");
             setState(() => _state = result);
    } else {
       setState(() => _state = Pagestate.notLogged);
    }
  } on TimeoutException {
    setState(() => _state = Pagestate.offline);
  } catch (e) {
     setState(() => _state = Pagestate.error);
  }
}


  Future<void> logOut() async {
    final   provider = Provider.of<PickupProvider>(context, listen: false);
  if (!await provider.hasInternetConnection()) {
    setState(() => _state = Pagestate.offline);
    return;
  }

    final connected = await _hasConnection();
    if (!connected) {
      if (!mounted) return;
     setState(() => _state = Pagestate.offline);
      return;
    }

    final token = await SecureStorage.getAccessToken();
    if (token == null) {
      if (!mounted) return;
     setState(() => _state = Pagestate.notLogged);
      return;
    }

    setState(() => _state = Pagestate.loading);

    try {
      final refresh = await SecureStorage.getRefreshToken();
      final res = await http.post(Uri.parse(logoutUrl),
          headers: {
            "Authorization": token.toString(),
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            "accessToken": token.toString(),
            "refreshToken": refresh.toString()
          }));

      if (res.statusCode == 200) {
        await SecureStorage.clearAll();
          ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Successfully logged out.'),
    
      duration: Duration(seconds: 2),
    
    ),
  );

  await Future.delayed(const Duration(milliseconds: 500));

 Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (context) =>const  HomePage()),
  (Route<dynamic> route) => false,
);
        if (!mounted) return;
      setState(() => _state = Pagestate.notLogged);
      } else {
       
final   provider = Provider.of<PickupProvider>(context, listen: false);
  Pagestate result = await provider.refreshAccessToken(logOut,"exe");
             setState(() => _state = result);
      }
    } catch (e) {
      if (!mounted) return;
       setState(() => _state = Pagestate.error);
    }
  }

void confirmLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFFF5F5F5),
      title: Semantics(
        label: 'Logout confirmation title',
        child: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1D4D61),
          ),
        ),
      ),
      content: Semantics(
        label: 'Logout confirmation message',
        child: const Text(
          "You'll need to login again to continue using the app.",
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
       Semantics(
  label: 'Cancel logout action',
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
          label: 'Confirm logout action',
          button: true,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              logOut();  
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4D61),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Log Out"),
          ),
        ),
      ],
    ),
  );
}

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[100],
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
      title: Semantics(
        label: 'Profile screen title',
        child: const Text(
          "Profile",
          style: TextStyle(color: Colors.white,  fontSize: 16,
                        fontWeight: FontWeight.w800,)
        ),
      ),
      leading: Semantics(
        label: 'Back button',
        button: true,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      elevation: 0,
      actions: const [
      
      ],
    ),
    body: _buildByState(),
  );
}



  Widget _buildByState() {
    switch (_state) {
      case Pagestate.loading:
        return const ElegantLoadingOverlay();
      case Pagestate.notLogged:
        return LoginRequired(
        message: "Please log in to see your profile",
        onLogin: () async{
         final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PhoneVerificationPage()),
          );
          if (result == true) {
            await fetchProfile();
          }else{
            setState(() {
              _state = Pagestate.notLogged;
            });
          }
        },
      );
      case Pagestate.offline:
        return OfflineRetry(
      onRetry: fetchProfile, 
    );
      case Pagestate.error:
        return  ErrorRetry(
              message: "Something went wrong",
              onRetry: fetchProfile,
            );
      case Pagestate.loggedIn:
        return _mainProfileView();
    }
  }

Widget _mainProfileView() {
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
    child: Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
               
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Color(0xFF1D4D61),
                            size: 26,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                label: 'Profile Name',
                                child: const Text(
                                  "Your Profile",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Semantics(
                                label: 'Phone number',
                                child: Text(
                                  phoneNumber ?? "",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),

        _buildMenuButton(
          title: "Current Prices",
          icon: Icons.currency_rupee,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PricePage()),
            );
          },
        ),
        _buildMenuButton(
          title: "Pickups",
          icon: Icons.shopping_bag_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RequestsPage()),
            );
          },
        ),
        _buildMenuButton(
          title: "Help & Support",
          icon: Icons.help_outline,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpPage()),
            );
          },
        ),
        _buildMenuButton(
          title: "Edit Profile",
          icon: Icons.edit_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountManagementPage()),
            );
          },
        ),
        _buildMenuButton(
          title: "Logout",
          icon: Icons.logout,
          onTap: () {
            confirmLogout(context);
          },
          isLogout: true,
        ),
      ],
    ),
  );
}

Widget _buildMenuButton({
  required String title,
  required IconData icon,
  required VoidCallback onTap,
  bool isLogout = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10), // slightly larger gap
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // more padding
        decoration: BoxDecoration(
          color: isLogout ? Colors.red.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22, // slightly bigger
              color: isLogout ? Colors.red : const Color(0xFF1D4D61),
            ),
            const SizedBox(width: 12), // slightly more spacing
            Expanded(
              child: Semantics(
                label: 'Menu Item: $title',
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15, // slightly bigger font
                    fontWeight: FontWeight.w600,
                    color: isLogout ? Colors.red : Colors.black87,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isLogout ? Colors.red : Colors.grey,
            ),
          ],
        ),
      ),
    ),
  );
}

}



