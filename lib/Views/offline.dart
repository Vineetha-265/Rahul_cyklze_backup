import 'package:flutter/material.dart';

class OfflineRetry extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;

  const OfflineRetry({
    super.key,
    required this.onRetry,
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
            // Modern circular background for icon
            const Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: Color(0xFF1D4D61)
            ),
            const SizedBox(height: 20),

            // Customizable message
            Text(
              message ?? "You are offline",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              "Check your internet connection\nand try again.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // Modern retry button with gradient
            SizedBox(
                width: 160,
               height: 48,
              child: ElevatedButton(
                onPressed: onRetry,
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
                  width: 160,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [      Color(0xFF1D4D61), Color(0xFF163B4B)
                    ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "Retry",
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
