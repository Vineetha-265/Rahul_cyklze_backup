import 'package:flutter/material.dart';

class ErrorRetry extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;

  const ErrorRetry({
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
            // Circular background for error icon
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color:  Color(0xFF1D4D61),
            ),
            const SizedBox(height: 20),

            // Error message
            Text(
              message ?? "Something went wrong",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: const Color(0xFF1D4D61),
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              "Please try again.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // Retry button with red gradient
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
                  decoration:const BoxDecoration(
                    gradient:  LinearGradient(
                      colors: [Color(0xFF1D4D61), Color(0xFF163B4B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(14)),
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
