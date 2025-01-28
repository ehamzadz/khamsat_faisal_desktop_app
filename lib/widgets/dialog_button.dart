import 'package:flutter/material.dart';

class DialogButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Color color;
  final Color textColor;

  DialogButton({
    required this.onPressed,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Text(label,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }
}
