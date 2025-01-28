// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/home_page.dart';
import '../services/api_service_materials.dart';
import 'build_action_button.dart';
import 'snackbar.dart';

class ShowDeleteConfirmationDialog extends StatelessWidget {
  // Add a parameter for the item
  final Map<String, String> item;

  const ShowDeleteConfirmationDialog({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: Icons.delete_rounded,
      label: 'حذف',
      color: Colors.red.shade50,
      iconColor: Colors.red.shade600,
      // Pass the item to the _handleDelete function
      onPressed: () => _handleDelete(context, item),
    );
  }

  void _handleDelete(BuildContext context, Map<String, String> item) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('حذف المادة'),
          content: Text('هل أنت متأكد من حذف هذه المادة؟'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      // DashboardProvider().DeleteData(context, item);
      try {
        // Attempt to delete the data via the API

        // Update the selectedStatusFilter from the DashboardProvider

        // Provider.of<DashboardProvider>(context, listen: false)
        //     .selectedStatusFilter = "جميع";
        // Provider.of<DashboardProvider>(context, listen: false).fetchData();
        // Provider.of<DashboardProvider>(context, listen: false).filterTable();
        // Provider.of<DashboardProvider>(context, listen: true);
        // Provider.of<DashboardProvider>(context, listen: false).filterTable();

        await ApiService().deleteDataViaAPI(item['مفتاح']!);

        Provider.of<DashboardProvider>(context, listen: false).deleteData(item);
        // If successful, show a success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم الحذف بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        print('Deleting item: ${item['مفتاح']}');
      } catch (error) {
        showErrorSnackbar(
            context, 'حدث خطأ أثناء محاولة الحذف: $error', Colors.red.shade400);
      }
    }
  }
}
