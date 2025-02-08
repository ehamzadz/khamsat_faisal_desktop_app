import 'dart:convert';
import 'package:http/http.dart' as http;

import '../variables/variables.dart';

class MaterialModel {
  final int id;
  final String name;
  final String serialNumber;
  final String generalNumber;
  final String beneficiary;
  final int status;

  MaterialModel({
    required this.id,
    required this.name,
    required this.serialNumber,
    required this.generalNumber,
    required this.beneficiary,
    required this.status,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'],
      name: json['Name'],
      serialNumber: json['SerialNumber'],
      generalNumber: json['GeneralNumber'],
      beneficiary: json['Beneficiary'],
      status: json['Status'],
    );
  }
}

class DatabaseService {
  static final String _baseUrl = 'http://$SERVER:3000';

  // Fetch all materials
  static Future<List<MaterialModel>> getMaterials() async {
    final response = await http.get(Uri.parse('$_baseUrl/materials'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MaterialModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load materials');
    }
  }

  // Add a new material
  static Future<void> addMaterial(MaterialModel material) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/materials'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': material.id,
        'name': material.name,
        'serialNumber': material.serialNumber,
        'generalNumber': material.generalNumber,
        'beneficiary': material.beneficiary,
        'status': material.status,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add material');
    }
  }

  // Update material status
  static Future<void> updateMaterialStatus(int id, int status) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/materials/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update material');
    }
  }

  // Delete a material
  static Future<void> deleteMaterial(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/materials/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete material');
    }
  }
}
