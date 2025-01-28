import 'package:flutter/material.dart';

Widget buildDropdownField(
  String label,
  Map<String, String> data,
  String validator,
  List<String> items,
) {
  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    items: items
        .map((value) => DropdownMenuItem(value: value, child: Text(value)))
        .toList(),
    validator: (value) => value == null ? validator : null,
    onChanged: (value) => data[label] = value ?? '',
  );
}
