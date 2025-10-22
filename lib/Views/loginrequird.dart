import 'package:flutter/material.dart';

class LoginRequired extends StatelessWidget {
  final VoidCallback onLogin;
  final String? message;

  const LoginRequired({
    super.key,
    required this.onLogin,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern circular icon background
            const Icon(
              Icons.lock_outline_rounded,
              size: 64,
              color:  Color(0xFF1D4D61),
            ),
            const SizedBox(height: 20),

            // Title / Message
            Text(
              message ?? "Login Required",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: const Color(0xFF1D4D61),
                  ),
            ),
            const SizedBox(height: 10),

            Text(
              "You are not logged in, You need to log in to see this page.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // Modern Login button with gradient
       SizedBox(
  width: 160,
  height: 48, // Optional: define consistent height
  child: ElevatedButton(
    onPressed: onLogin,
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.zero, // Remove default padding
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 4,
      backgroundColor: Colors.transparent, // Transparent so gradient shows
      shadowColor: Colors.black26,
    ).copyWith(
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
    ),
    child: Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4D61), Color(0xFF163B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: double.infinity,
        child: const Text(
          "Login",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
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
  }
}
