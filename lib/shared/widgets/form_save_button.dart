import 'package:flutter/material.dart';

class FormSaveButton extends StatelessWidget {
  const FormSaveButton({
    super.key,
    required this.label,
    required this.accentColor,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final Color accentColor;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: onPressed == null
              ? const Color(0xFFCBD5E1)
              : accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
