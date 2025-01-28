import 'package:flutter/material.dart';

Widget buildDropdownFieldEditData(
  String field,
  Map<String, String> updatedData,
  String validationMessage,
  List<String> options, {
  required String initialValue, // Non-nullable String
}) {
  return DropdownButtonFormField<String>(
    value: initialValue,
    decoration: InputDecoration(
      labelText: field,
      border: OutlineInputBorder(),
    ),
    items: options.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
    onChanged: (value) {
      updatedData[field] = value!; // Update the map with the new value
    },
    validator: (value) {
      if (value == null || value.isEmpty) {
        return validationMessage;
      }
      return null;
    },
  );
}
