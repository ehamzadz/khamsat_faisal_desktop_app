import 'package:flutter/material.dart';

Widget buildTextFieldEditData(
  String field,
  Map<String, String> updatedData, {
  required String initialValue, // Non-nullable String
}) {
  return TextFormField(
    initialValue: initialValue,
    decoration: InputDecoration(
      labelText: field,
      border: OutlineInputBorder(),
    ),
    onChanged: (value) {
      updatedData[field] = value; // Update the map with the new value
    },
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'يرجى ملء هذا الحقل';
      }
      return null;
    },
  );
}
