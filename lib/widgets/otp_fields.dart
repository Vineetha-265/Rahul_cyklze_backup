


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SingleOtpField extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String) onCompleted;
  final void Function(String) onChanged;

  const SingleOtpField({
    required this.controller,
    required this.onCompleted,
    required this.onChanged,
    super.key,
  });

  @override
  State<SingleOtpField> createState() => _SingleOtpFieldState();
}

class _SingleOtpFieldState extends State<SingleOtpField> {
  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      final text = widget.controller.text;
      widget.onChanged(text);

      // Call onCompleted when 6 digits entered (but don’t unfocus here)
      if (text.length == 6) {
        widget.onCompleted(text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 6,
      style: const TextStyle(
        fontSize: 20,
        letterSpacing: 32,
        fontWeight: FontWeight.w600,
      ),
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.done, // Shows "done" or "submit"
      onSubmitted: (value) {
        if (value.length == 6) {
          widget.onCompleted(value);
          FocusScope.of(context).unfocus(); // Only unfocus on submission
        }
      },
      decoration: InputDecoration(
        counterText: "",
        hintText: "------",
        hintStyle: const TextStyle(
          letterSpacing: 32,
          color: Colors.grey,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            color: Colors.grey.shade400,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            color: Colors.grey.shade400,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
      ),
    );
  }
}
