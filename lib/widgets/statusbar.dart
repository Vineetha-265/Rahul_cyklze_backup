import 'package:flutter/material.dart';

class StatusProgressBar extends StatelessWidget {
  final String status; // now takes a string like "1", "2", etc.

  const StatusProgressBar({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Convert string to int safely; default to 0 if invalid
    final int parsedStatus = int.tryParse(status) ?? 0;

    final steps = [
      'Pending',
      'Assigned',
      'On the Way',
      'At the Location',
      'Completed',
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- Top Labels (alternate ones) ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            return Expanded(
              child: index.isEven
                  ? Text(
                      steps[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          }),
        ),
        const SizedBox(height: 6),

        // --- Dots and Connecting Lines ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(steps.length * 2 - 1, (i) {
            if (i.isEven) {
              final stepIndex = i ~/ 2;
              final isActive = stepIndex < parsedStatus;
              return Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isActive ? Colors.green : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? Colors.green : Colors.grey,
                    width: 2,
                  ),
                ),
                child: isActive
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              );
            } else {
              final lineIndex = (i - 1) ~/ 2;
              final isLineActive = lineIndex + 1 < parsedStatus;
              return Expanded(
                child: Container(
                  height: 3,
                  color: isLineActive ? Colors.green : Colors.grey.shade300,
                ),
              );
            }
          }),
        ),
        const SizedBox(height: 6),

        // --- Bottom Labels (opposite alternates) ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            return Expanded(
              child: index.isOdd
                  ? Text(
                      steps[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          }),
        ),
      ],
    );
  }
}
