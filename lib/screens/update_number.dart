
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cyklze/Provider/pickup_provider.dart';
import 'package:cyklze/SecureStorage/securestorage.dart';
import 'package:cyklze/Views/error.dart';
import 'package:cyklze/Views/loginrequird.dart';
import 'package:cyklze/Views/offline.dart';
import 'package:cyklze/enums/page_state.dart';
import 'package:cyklze/screens/verification.dart';
import 'package:cyklze/screens/webpageview.dart';
import 'package:cyklze/widgets/otp_fields.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';



class NetworkUtils {
  static Future<bool> isNetworkAvailable() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}

enum _ViewState { content, loggedOut, offline, error }

class EditMobileNumberPage extends StatefulWidget {
  const EditMobileNumberPage({super.key});

  @override
  State<EditMobileNumberPage> createState() => _EditMobileNumberPageState();
}

class _EditMobileNumberPageState extends State<EditMobileNumberPage> {
  _ViewState _state = _ViewState.content;
  bool _showOtp = false; 

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _otp = TextEditingController();
  final FocusNode _otpFocus = FocusNode();

  bool _sendingOtp = false;
  bool _verifying = false;
  bool isEditable = true;
  static const int _otpWindowSeconds = 120;
  int _secondsLeft = 0;
  Timer? _timer;

  String _countryCode = '+91';

  static const String _sendOtpUrl =
      'https://20pnz6cr8e.execute-api.ap-south-1.amazonaws.com/cyklzee/cyklzee/handleotp';
  static const String _verifyOtpUrl =
      'https://20pnz6cr8e.execute-api.ap-south-1.amazonaws.com/cyklzee/cyklzee/handleuser';

  @override
  void initState() {
    super.initState();
    _checkNetworkAndProceed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phone.dispose();
    _otp.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  Future<void> _checkNetworkAndProceed() async {
    final online = await NetworkUtils.isNetworkAvailable();
    if (!mounted) return;
    if (!online) {
      setState(() {
        _state = _ViewState.offline;
      });
      return;
    }

    final accessToken = await SecureStorage.getAccessToken();
    if (!mounted) return;
    setState(() {
      _state = (accessToken == null || accessToken.isEmpty)
          ? _ViewState.loggedOut
          : _ViewState.content;
    });
  }

  void _showLoggedIn() {
    setState(() {
      _state = _ViewState.content;
    });
  }

  void _showLoggedOut() {
    setState(() {
      _state = _ViewState.loggedOut;
      _showOtp = false;
      _stopTimerReset();
    });
  }

  void _showError() {
    setState(() {
      _state = _ViewState.error;
    });
  }

  void _showOffline() {
    setState(() {
      _state = _ViewState.offline;
    });
  }

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  bool _validatePhone() {
    final digits = _digitsOnly(_phone.text);
    if (digits.length != 10) {
      _snack('Please enter a valid 10 digit mobile number');
      return false;
    }
    return true;
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _startOtpWindow() {
    setState(() {
      _showOtp = true;
       isEditable = false;
      _secondsLeft = _otpWindowSeconds;
    });
    _otpFocus.requestFocus();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _secondsLeft--;
      });
      if (_secondsLeft <= 0) {
        t.cancel();
        if (!mounted) return;
        setState(() {
          _showOtp = false;
          isEditable = true; 
        });
        _snack('OTP expired. Please try again.');
      }
    });
  }

  void _stopTimerReset() {
    _timer?.cancel();
    _secondsLeft = 0;
  }

  Future<void> _handleSendOtp() async {
    if (!_validatePhone()) return;

// final online = await NetworkUtils.isNetworkAvailable();
// if (!online) {
//   _showOffline(); 
//   return;
// }
final   provider = Provider.of<PickupProvider>(context, listen: false);
  if (!await provider.hasInternetConnection()) {
    _showOffline(); 
    return;
  }



    final accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      _showLoggedOut();
      return;
    }

    setState(() => _sendingOtp = true);

    try {
      final body = jsonEncode({
        'phoneNumber': _digitsOnly(_phone.text),
      });

      final resp = await http.put(
        Uri.parse(_sendOtpUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
        body: body,
      );

      if (!mounted) return;

      setState(() => _sendingOtp = false);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        _snack('OTP sent successfully');
        _startOtpWindow();
      } else {
        _snack('Invalid number, Please enter a valid one and try again.');
      }
    } catch (e) {
      setState(() => _sendingOtp = false);
      _showError();
    }
  }

  Future<void> _handleVerifyOtp() async {
final   provider = Provider.of<PickupProvider>(context, listen: false);
  if (!await provider.hasInternetConnection()) {
    _showOffline(); 
    return;
  }
    

    final accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      _showLoggedOut();
      return;
    }

    final code = _otp.text.trim();
    if (code.length != 6) {
      _snack('Please enter a 6-digit OTP.');
      return;
    }

    if (!_validatePhone()) return;

    setState(() => _verifying = true);

    try {
      final body = jsonEncode({
        'phoneNumber': _digitsOnly(_phone.text),
        'otp': code,
        'accesstoken': accessToken,
      });

      final resp = await http.put(
        Uri.parse(_verifyOtpUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
        body: body,
      );

      if (!mounted) return;

      setState(() => _verifying = false);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final newAccess = (data['accessToken'] ?? '').toString();
        final newRefresh = (data['refreshToken'] ?? '').toString();

        if (newAccess.isNotEmpty) await SecureStorage.saveAccessToken(newAccess);
        if (newRefresh.isNotEmpty) await SecureStorage.saveRefreshToken(newRefresh);

        _snack('Number Updated Successfully');
        _showLoggedIn();
        _stopTimerReset();
           Navigator.pop(context);
        setState(() {
          _showOtp = false;
        });
      } else {
        String message = 'Verification failed. Check the OTP and try again.';
        try {
          final raw = resp.body;
          if (raw.isNotEmpty) {
            final j = jsonDecode(raw);
            final err = j['error']?.toString() ?? '';
        

              final   provider = Provider.of<PickupProvider>(context, listen: false);
  Pagestate result = await provider.refreshAccessToken(_handleVerifyOtp,"exe");
      
            if (err.isNotEmpty) message = err;
             return;
          }
        } catch (_) {}
        _snack(message);
      }
    } catch (e) {
      setState(() => _verifying = false);
      _showError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
 return Semantics(
  container: true,
  label: 'Edit Mobile Number Page',
  child: Scaffold(
    backgroundColor: Colors.white,
    appBar:  AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1D4D61), Color(0xFF163B4B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("Edit Mobile Number",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
     
    body: SafeArea(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: switch (_state) {
          _ViewState.offline => Semantics(
            label: 'No internet connection',
            child: OfflineRetry(
              onRetry: _checkNetworkAndProceed,
            ),
          ),
          _ViewState.loggedOut => Semantics(
            label: 'Login required to access this section',
            child: LoginRequired(
              message: "Please log in to see your profile",
              onLogin: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PhoneVerificationPage()),
                );
                if (result == true) {
                  await _checkNetworkAndProceed();
                }
              },
            ),
          ),
          _ViewState.error => Semantics(
            label: 'An error occurred',
            child: ErrorRetry(
              message: "Something went wrong",
              onRetry: _showLoggedIn,
            ),
          ),
          _ => _ContentView(
            formKey: _formKey,
            theme: theme,
            isEditable: isEditable,
            countryCode: _countryCode,
            onCountryChange: (v) => setState(() => _countryCode = v),
            phone: _phone,
            sendingOtp: _sendingOtp,
            onSendOtp: _handleSendOtp,
            showOtp: _showOtp,
            otp: _otp,
            otpFocus: _otpFocus,
            secondsLeft: _secondsLeft,
            verifying: _verifying,
            onVerify: _handleVerifyOtp,
            onResend: _secondsLeft == 0 ? _handleSendOtp : null,
          ),
        },
      ),
    ),
  ),
);
  }

}

class _ContentView extends StatelessWidget {
  const _ContentView({
    required this.formKey,
    required this.theme,
    required this.countryCode,
    required this.onCountryChange,
    required this.phone,
    required this.sendingOtp,
    required this.onSendOtp,
    required this.showOtp,
    required this.otp,
    required this.otpFocus,
    required this.secondsLeft,
    required this.verifying,
    required this.onVerify,
    required this.isEditable,
    required this.onResend,
  });

  final GlobalKey<FormState> formKey;
  final ThemeData theme;
  final String countryCode;
  final ValueChanged<String> onCountryChange;
  final TextEditingController phone;
  final bool sendingOtp;
  final bool isEditable;
  final VoidCallback onSendOtp;
  final bool showOtp;
  final TextEditingController otp;
  final FocusNode otpFocus;
  final int secondsLeft;
  final bool verifying;
  final VoidCallback onVerify;
  final VoidCallback? onResend;

  String _digitsOnly(String input) => input.replaceAll(RegExp(r"[^0-9]"), '');

  @override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

   const SizedBox(height: 22),
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter new Mobile number', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
Row(
  children: [
 Expanded(
  flex: 1,
  child: Semantics(
    label: 'Phone number input',
    hint: 'Enter your mobile number',
    child: Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface.withOpacity(0.6),
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: TextFormField(
        controller: phone,
        enabled: isEditable,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: InputDecoration(
          prefixText: '+91 ',
          labelText: 'Phone number',
          hintText: 'Enter mobile number',
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.blueGrey,
          ),
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
          helperStyle: TextStyle(
            fontSize: 12,
            color: Colors.blueGrey[600],
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.black,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 2.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2.0,
            ),
          ),
        ),
        validator: (value) {
          final v = value ?? '';
          final digits = _digitsOnly(v);
          if (digits.isEmpty) return 'Please enter your mobile number';
          if (digits.length != 10) return 'Enter a valid 10-digit number';
          return null;
        },
      ),
    ),
  ),
),
 ],
),


            const SizedBox(height: 10),
             
  
              if (!showOtp) _SendOtpButton(sending: sendingOtp, onTap: onSendOtp),
  
              if (showOtp) ...[
                const SizedBox(height: 18),
                Text(
                  'Enter OTP',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
  SingleOtpField(
  controller: otp,
  onChanged: (value) {
    print("OTP changed: $value");
  },
  onCompleted: (value) {
    print("OTP completed: $value");
  },
),


                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ' Otp Sent to ${_mask('$countryCode ${phone.text}')} ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                    ),
                  
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      secondsLeft == 0 ? Icons.refresh : Icons.timer_outlined,
                      size: 18,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        secondsLeft == 0
                            ? 'Didn’t receive the code?'
                            : 'You can resend OTP in ${secondsLeft}s',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                    ),
                 
                  ],
                ),
                const SizedBox(height: 10),
  
               SizedBox(
  width: double.infinity,
  height: 52,
  child: ElevatedButton.icon(
    onPressed: verifying ? null : onVerify,
    icon: verifying
        ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white, 
            ),
          )
        : const Icon(
            Icons.verified_outlined,
            color: Colors.white, 
          ),
    label: Text(
      verifying ? 'Verifying...' : 'Verify OTP',
      style: const TextStyle(color: Colors.white), 
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1D4D61),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      foregroundColor: Colors.white, 
      disabledBackgroundColor: const Color(0xFF1D4D61), 
      disabledForegroundColor: Colors.white, 
    ),
  ),
),

              ],
            ],
          ),
        ),
         const SizedBox(height: 14),
       const TermsText(),
        const SizedBox(height: 40),
      ],
    ),
  );
}
  String _mask(String phone) {
    if (phone.trim().isEmpty) return '•••• •••••';
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) return phone;
    return '${digits.substring(0, 2)}••• ••${digits.substring(digits.length - 2)}';
  }
}

class TermsText extends StatefulWidget {
  const TermsText({super.key});

  @override
  State<TermsText> createState() => _TermsTextState();
}

class _TermsTextState extends State<TermsText> {
  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const WebViewPage(
      url: 'https://www.cyklze.com/Terms_of_Service.html',bartitle: "Terms of Service",
    ),
  ),
);

    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () =>  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const WebViewPage(
      url: 'https://www.cyklze.com/Privacy_policy.html',bartitle: "Privacy Policy",
    ),
  ),
);
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    if (url.trim().isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null) {
      debugPrint('Invalid URL: $url');
      return;
    }

    if (!await canLaunchUrl(uri)) {
      debugPrint('Cannot launch URL: $url');
      return;
    }

    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success) {
      debugPrint('Failed to launch URL: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(fontSize: 12, color: Colors.black),
        children: [
          const TextSpan(text: 'By continuing you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: _termsRecognizer,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: _privacyRecognizer,
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}

class _SendOtpButton extends StatelessWidget {
  const _SendOtpButton({
    required this.sending,
    required this.onTap,
  });

  final bool sending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        
        width: double.infinity, 
        height: 52,
        child: AnimatedSwitcher(
          
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: sending
              ?FilledButton.icon(
  key: const ValueKey('loading'),
  onPressed: null,
  icon: const SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      color: Colors.black,
    ),
  ),
  label: const Text(
    'Sending...',
    style: TextStyle(color: Colors.black),
  ),
  style: FilledButton.styleFrom(
    backgroundColor: Colors.white, 
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
)

              : Semantics(
                  button: true,
                  label: 'Send OTP',
                  hint: 'Sends a one-time password to your mobile number for verification',
                  child: FilledButton(
                    key: const ValueKey('send'),
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4D61),
                      foregroundColor: const Color(0xFF1D4D61),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: const Text(
                      'Send OTP',
                      style: TextStyle(
                        fontSize: 16,color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

