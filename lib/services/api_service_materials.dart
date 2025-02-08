import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    // ✅ Use ffi-safe path for Windows
    databaseFactory = databaseFactoryFfi;

    String path = join(await getDatabasesPath(), 'materials.db');
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE materials (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              material_name TEXT,
              number TEXT,
              serial_number TEXT,
              general_number TEXT,
              for_who TEXT,
              status TEXT,
              created_at TEXT,
              updated_at_transfert TEXT,
              updated_at_exit TEXT
            )
          ''');
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchItems() async {
    final db = await database;
    return await db.query('materials');
  }

  // إدخال عنصر جديد
  Future<bool> insertItem(Map<String, dynamic> item) async {
    item['created_at'] = DateTime.now().toString();
    print(item);

    final db = await database;
    print('==========');
    try {
      await db.insert('materials', item);
    } catch (e) {
      print('Insert Error: $e');
      return false; // Indicate failure
    }
    return true;
  }

  // تحديث عنصر
  Future<bool> updateItem(String id, Map<String, dynamic> item) async {
    final db = await database;

    if (item['status'] == 'تم التحويل') {
      item['updated_at_transfert'] = DateTime.now().toString();
    }
    if (item['status'] == 'تم الانتهاء منها') {
      item['updated_at_exit'] = DateTime.now().toString();
    }

    await db.update('materials', item, where: 'id = ?', whereArgs: [id]);
    return true;
  }

  // حذف عنصر
  Future<int> deleteItem(String id) async {
    final db = await database;
    return await db.delete('materials', where: 'id = ?', whereArgs: [id]);
  }
}
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import '../variables/variables.dart';

// class ApiService {
//   // final String baseUrl = 'http://127.0.0.1:5000';

//   Future<List<Map<String, String>>> fetchItems() async {
//     try {
//       // final response = await http.get(Uri.parse('$baseUrl/items'));

//       final response = await http.get(
//         Uri.parse('http://${SERVER}/backend/get_data.php'),
//       );

//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);
//         return data
//             .map<Map<String, String>>((item) => {
//                   "id": item["id"],
//                   "اسم المادة": item["material_name"],
//                   "رقم المادة": item["number"],
//                   "السيريال نمبر": item["serial_number"],
//                   "الرقم العام": item["general_number"],
//                   "لصالح من": item["for_who"],
//                   "حالة المادة": item["status"],
//                   "تاريخ الدخول": item["created_at"],
//                   "تاريخ التحويل": item["updated_at_transfert"],
//                   "تاريخ الخروج": item["updated_at_exit"],
//                 })
//             .toList();
//       } else {
//         throw Exception('Failed to load data: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching data: $e');
//     }
//   }

// // Function to insert data via PHP API
//   Future<bool> insertDataViaAPI(Map<String, String> data) async {
//     final url = Uri.parse(
//         'http://${SERVER}/backend/insert_data.php'); // Replace with your PHP API URL

//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(data),
//       );

//       print('==============: ${response.body}');

//       if (response.statusCode == 201) {
//         // Data inserted successfully
//         return true;
//       } else {
//         // Handle API errors
//         print('API Error: ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       // Handle network errors
//       print('Network Error: $e');
//       return false;
//     }
//   }

//   Future<bool> updateDataViaAPI(String id, Map<String, String> data) async {
//     final url = Uri.parse('http://${SERVER}/backend/update_data.php');

//     try {
//       // Include the ID in the data to be updated
//       data['id'] = id;

//       // Debug: Print the data being sent
//       print('Data being sent to API: $data');

//       final response = await http.put(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(data),
//       );

//       print('API Response: ${response.body}');

//       if (response.statusCode == 200) {
//         // Data updated successfully
//         return true;
//       } else {
//         // Handle API errors
//         print('API Error: ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       // Handle network errors
//       print('Network Error: $e');
//       return false;
//     }
//   }

//   // Function to delete data via PHP API
//   Future<bool> deleteDataViaAPI(String id) async {
//     final url = Uri.parse(
//         'http://${SERVER}/backend/delete_data.php'); // Replace with your PHP API URL

//     try {
//       final response = await http.delete(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'id': id}),
//       );

//       print('==============: ${response.body}');

//       if (response.statusCode == 200) {
//         // Data deleted successfully
//         return true;
//       } else {
//         // Handle API errors
//         print('API Error: ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       // Handle network errors
//       print('Network Error: $e');
//       return false;
//     }
//   }
// }
