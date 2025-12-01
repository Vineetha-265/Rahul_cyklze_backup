import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cyklze/Provider/pickup_provider.dart';
import 'package:cyklze/SecureStorage/securestorage.dart';
import 'package:cyklze/Views/error.dart';
import 'package:cyklze/Views/loginrequird.dart';
import 'package:cyklze/screens/webpageview.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cyklze/enums/page_state.dart';
import 'package:cyklze/Views/offline.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../widgets/otp_fields.dart';

const String kEndpoint =
    "https://20pnz6cr8e.execute-api.ap-south-1.amazonaws.com/cyklzee/cyklzee/handleotp";


class PhoneVerificationPage extends StatefulWidget {
  const PhoneVerificationPage({super.key});

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage>
    with SingleTickerProviderStateMixin {

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpControllers =
       TextEditingController();

  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool otpSent = false;
  bool isSending = false;
  bool isVerifying = false;
  String errorMessage = "";
  int remainingSeconds = 0;
  Timer? _timer;

  Pagestate _state = Pagestate.loggedIn;
  // StreamSubscription<List<ConnectivityResult>>? _connSub;


  @override
  void initState() {
    super.initState();

    // _animController =
    //     AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    // _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
    //   CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    // );

    // _initConnectivity();

    // _connSub = Connectivity().onConnectivityChanged.listen((results) {
    //   final hasNet = results.isNotEmpty && results.first != ConnectivityResult.none;
    //   if (!mounted) return;
    //   setState(() {
    //     _state = hasNet ? Pagestate.loggedIn : Pagestate.offline;
    //   });
    // });
  }

  Future<void> _initConnectivity() async {
  //  _connSub = Connectivity().onConnectivityChanged.listen((results) {
  //     final hasNet = results.isNotEmpty && results.first != ConnectivityResult.none;
      if (!mounted) return;
      setState(() {
        _state =  Pagestate.loggedIn;
      });
    // });
  }

  @override
  void dispose() {
    _timer?.cancel();
  
    // _connSub?.cancel();
    phoneController.dispose();
   
      otpControllers.dispose();
  
    for (var f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> sendOtp() async {
   final   provider = Provider.of<PickupProvider>(context, listen: false);
  if (!await provider.hasInternetConnection()) {
    setState(() => _state = Pagestate.offline);
    return;
  }

    final phone = phoneController.text.trim();
    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      setState(() => errorMessage = "Please enter a valid 10-digit phone number.");
      return;
    }

    setState(() {
      isSending = true;
      errorMessage = "";
    });

    try {
      final response = await http.put(
        Uri.parse(kEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phoneNumber": phone}),
      );

      if (response.statusCode == 200) {
        setState(() => otpSent = true);
        startOtpCooldown();
        showSnack("OTP sent successfully");
        Future.delayed(const Duration(milliseconds: 300), () {
          if (otpFocusNodes.isNotEmpty) otpFocusNodes[0].requestFocus();
        });
      } else {
        setState(() => errorMessage = "Failed to send OTP. Please check the number and Try again.");
      }
    } catch (e) {
      setState(() => errorMessage = "Network error while sending OTP.");
    } finally {
      if (mounted) setState(() => isSending = false);
    }
  }

  Future<void> verifyOtp() async {
final   provider = Provider.of<PickupProvider>(context, listen: false);
  if (!await provider.hasInternetConnection()) {
    setState(() => _state = Pagestate.offline);
    return;
  }

    final phone = phoneController.text.trim();
    final otp = otpControllers.text.trim();

    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      setState(() => errorMessage = "Invalid phone number");
      return;
    }
    if (!RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      setState(() => errorMessage = "OTP must be 6 digits");
      return;
    }

    setState(() {
      isVerifying = true;
      errorMessage = "";
    });

    try {
      final response = await http.post(
        Uri.parse(kEndpoint),
        headers: {
          "Content-Type": "application/json",
          
        },
        body: jsonEncode({"phoneNumber": phone, "otp": otp}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final accessToken = json["accessToken"];
        final refreshToken = json["refreshToken"];

        if (accessToken != null && refreshToken != null) {
          await SecureStorage.saveAccessToken(accessToken);
          await SecureStorage.saveRefreshToken(refreshToken);
          await SecureStorage.firstTime();
          Navigator.pop(context, true);
        } else {
          setState(() => errorMessage = "Invalid server response");
        }
      } else {
        setState(() => errorMessage = "Invalid OTP, please enter a valid one");
      }
    } catch (e) {
      setState(() => errorMessage = "Network error while verifying OTP");
    } finally {
      if (mounted) setState(() => isVerifying = false);
    }
  }

  Future<bool> _hasConnection() async {
    final status = await Connectivity().checkConnectivity();
    return status != ConnectivityResult.none;
  }

  void startOtpCooldown() {
    _timer?.cancel();
    setState(() => remainingSeconds = 120);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 0) {
        timer.cancel();
        setState(() {
             otpSent = false;
   isSending = false;
   isVerifying = false;
   errorMessage = "";
   remainingSeconds = 0;
        });
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  Widget _buildByState() {
    switch (_state) {

      case Pagestate.notLogged:
        return LoginRequired(
          message: "Please log in to see your profile",
          onLogin: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PhoneVerificationPage()),
            );
            if (result == true) await _initConnectivity();
          },
        );
      case Pagestate.offline:
        return OfflineRetry(onRetry: _initConnectivity);
          case Pagestate.loading:
        return const Center(child: CircularProgressIndicator());
      case Pagestate.error:
        return ErrorRetry(
          message: "Something went wrong",
          onRetry: _initConnectivity,
        );
      case Pagestate.loggedIn:
        return _mainContent();
    }
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: _buildByState(),
    );
  }
  
Widget _mainContent() {
  final size = MediaQuery.of(context).size;

  return SafeArea(
    child: Container(
      constraints: const BoxConstraints(maxWidth: 1000),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
               //_TopBar(),
                        const SizedBox(height: 14),
            _buildLeftCard(size, false),
            const SizedBox(height: 14),
            _buildRightCard(size, false),
              const SizedBox(height: 12),
             const TermsText(),
                    
          ],
        ),
      ),
    ),
  );
}

  Widget _buildLeftCard(Size size, bool isLarge) {
    double illustrationHeight = size.height * 0.18;
    if (illustrationHeight < 110) illustrationHeight = 110;
    if (illustrationHeight > 260) illustrationHeight = 260;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
       
          Text(
            otpSent ? "Enter the OTP" : "Verify your phone",
            style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            otpSent
                ? "Enter the 6-digit code sent to your phone."
                : "We'll send a one-time code to verify your account.",
            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
          ),

       
        ],
      ),
    );
  }

  Widget _buildRightCard(Size size, bool isLarge) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PhoneInputRow(
            controller: phoneController,
            enabled: !otpSent,
            onChanged: (v) => setState(() {}),
          ),
          const SizedBox(height: 14),
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child:
                  Text(errorMessage, style: const TextStyle(color: Colors.redAccent)),
            ),
          if (otpSent) ...[
              const Text("Enter Otp", style: TextStyle(color: Colors.black )),
            const SizedBox(height: 6),
            SingleOtpField(
              controller: otpControllers,
              onCompleted: (_) {},
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed:
                    remainingSeconds == 0 && !isSending ? () => sendOtp() : null,
                child: Text(
                  remainingSeconds == 0
                      ? "Resend OTP"
                      : "Resend in ${remainingSeconds}s",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: remainingSeconds == 0
                        ? Colors.teal.shade700
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
       SizedBox(
  height: 56,
  child: ElevatedButton(
    onPressed: (isSending || isVerifying)
        ? null
        : () async {
            if (!otpSent) {
              await sendOtp();
            } else {
              await verifyOtp();
            }
          },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1D4D61),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: isSending || isVerifying
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: Colors.white,
            ),
          )
        : Text(
            !otpSent ? "Send OTP" : "Verify OTP",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
  ),
)
,  const SizedBox(height: 12),
         
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1D4D61), Color(0xFF163B4B)]),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.verified_user, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Text("CYKLZE",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const Spacer(),
       
      ],
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const GlassCard({required this.child, this.padding, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: child,
    );
  }
}


class _PhoneInputRow extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final void Function(String) onChanged;
  const _PhoneInputRow(
      {required this.controller,
      required this.enabled,
      required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Mobile Number",
          style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200)),
        child: Row(children: [
          const Text("+91",
              style: TextStyle(
                  color: Color(0xFF1D4D61), fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              enabled: enabled,
              controller: controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [LengthLimitingTextInputFormatter(10)],
              style: const TextStyle(letterSpacing: 1.2),
              decoration: const InputDecoration(
                  hintText: "Enter mobile number", border: InputBorder.none),
              onChanged: onChanged,
            ),
          )
        ]),
      )
    ]);
  }
}

class TermsText extends StatelessWidget {
  const TermsText({super.key});

  void _launchURL(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewPage(url: url, bartitle: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("By continuing you agree to our", textAlign: TextAlign.center),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => _launchURL(context, 'https://www.cyklze.com/Terms_of_Service.html', "Terms of Service"),
              child: const Text('Terms of Service', style: TextStyle(decoration: TextDecoration.underline)),
            ),
            const Text(' and '),
            TextButton(
              onPressed: () => _launchURL(context, 'https://www.cyklze.com/Privacy_policy.html', "Privacy Policy"),
              child: const Text('Privacy Policy', style: TextStyle(decoration: TextDecoration.underline)),
            ),
          ],
        )
      ],
    );
  }
}
