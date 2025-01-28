import 'dart:convert';
import 'package:http/http.dart' as http;

import '../variables/variables.dart';

class ApiService {
  // final String baseUrl = 'http://127.0.0.1:5000';

  Future<List<Map<String, String>>> fetchItems() async {
    try {
      // final response = await http.get(Uri.parse('$baseUrl/items'));

      final response = await http.get(
        Uri.parse('http://${SERVER}/backend/get_data.php'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data
            .map<Map<String, String>>((item) => {
                  "مفتاح": item["id"],
                  "اسم المادة": item["material_name"],
                  "رقم المادة": item["number"],
                  "السيريال نمبر": item["serial_number"],
                  "الرقم العام": item["general_number"],
                  "لصالح من": item["for_who"],
                  "حالة المادة": item["status"],
                })
            .toList();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

// Function to insert data via PHP API
  Future<bool> insertDataViaAPI(Map<String, String> data) async {
    final url = Uri.parse(
        'http://${SERVER}/backend/insert_data.php'); // Replace with your PHP API URL

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      print('==============: ${response.body}');

      if (response.statusCode == 201) {
        // Data inserted successfully
        return true;
      } else {
        // Handle API errors
        print('API Error: ${response.body}');
        return false;
      }
    } catch (e) {
      // Handle network errors
      print('Network Error: $e');
      return false;
    }
  }
}
