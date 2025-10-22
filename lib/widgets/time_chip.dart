import 'package:flutter/material.dart';

class TimeChip extends StatelessWidget {
  final String label;
  final String? selectedTimeRange;
  final ValueChanged<String> onSelected;

  const TimeChip({
    super.key,
    required this.label,
    required this.selectedTimeRange,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedTimeRange == label;
    return GestureDetector(
      onTap: () => onSelected(label),
      child: Material(
        color: isSelected ? const Color(0xFF1D4D61) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
