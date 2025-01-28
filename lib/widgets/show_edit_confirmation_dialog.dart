// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../screens/home_page.dart';
import '../services/api_service_materials.dart';
import 'build_action_button.dart';
import 'build_dropdown_field_editdata.dart';
import 'build_textfield_editdata.dart';
import 'dialog_button.dart';
import 'snackbar.dart';

class ShowEditonfirmationDialog extends StatelessWidget {
  // Add a parameter for the item
  final Map<String, String> item;

  const ShowEditonfirmationDialog({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: Icons.edit_rounded,
      label: 'تعديل',
      color: Colors.blue.shade100,
      iconColor: Colors.blue.shade700,
      // Pass the item to the _handleDelete function
      onPressed: () => _showEditDataDialog(context, item),
    );
  }

// Function to show the Edit Data Dialog
  void _showEditDataDialog(
      BuildContext context, Map<String, String> selectedItem) {
    final _formKey = GlobalKey<FormState>();
    final Map<String, String> updatedData =
        Map.from(selectedItem); // Copy the selected item's data

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue.shade700),
                    SizedBox(width: 12),
                    Text(
                      "تعديل المادة",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                Divider(height: 32),
                Flexible(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          ...updatedData.keys.map((field) {
                            if (field == 'حالة المادة') {
                              return buildDropdownFieldEditData(
                                field,
                                updatedData,
                                'يرجى اختيار أحد الإختيارات',
                                [
                                  'تحت العمل',
                                  'تم التحويل',
                                  'شطبت',
                                  'تم الانتهاء منها'
                                ],
                                initialValue: updatedData[field] ??
                                    '', // Provide a default value
                              );
                            }
                            return buildTextFieldEditData(
                              field,
                              updatedData,
                              initialValue: updatedData[field] ??
                                  '', // Provide a default value
                            );
                          }).expand((widget) => [widget, SizedBox(height: 16)]),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DialogButton(
                      onPressed: () => Navigator.pop(context),
                      label: "إلغاء",
                      color: Colors.grey.shade200,
                      textColor: Colors.grey.shade700,
                    ),
                    SizedBox(width: 12),
                    DialogButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Debug: Print the updated data
                          print('Updated Data: $updatedData');

                          // Call the update function
                          bool isUpdated = await ApiService().updateDataViaAPI(
                            selectedItem[
                                'مفتاح']!, // Pass the ID of the selected item
                            updatedData,
                          );

                          if (isUpdated) {
                            Provider.of<DashboardProvider>(context,
                                    listen: false)
                                .fetchData();
                            Provider.of<DashboardProvider>(context,
                                    listen: false)
                                .selectedStatusFilter = "جميع";
                            Navigator.pop(context); // Close the dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('تم التعديل بنجاح')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'فشل التعديل، يرجى المحاولة مرة أخرى')),
                            );
                          }
                        }
                      },
                      // onPressed: () async {
                      //   if (_formKey.currentState!.validate()) {
                      //     // Call the update function
                      //     bool isUpdated = await ApiService().updateDataViaAPI(
                      //       selectedItem[
                      //           'مفتاح']!, // Pass the ID of the selected item
                      //       updatedData,
                      //     );

                      //     if (isUpdated) {
                      //       Provider.of<DashboardProvider>(context,
                      //               listen: false)
                      //           .fetchData();
                      //       Provider.of<DashboardProvider>(context,
                      //               listen: false)
                      //           .selectedStatusFilter = "جميع";
                      //       // Provider.of<DashboardProvider>(context, listen: false).filterTable();
                      //       Navigator.pop(context); // Close the dialog
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(content: Text('تم التعديل بنجاح')),
                      //       );
                      //     } else {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(
                      //             content: Text(
                      //                 'فشل التعديل، يرجى المحاولة مرة أخرى')),
                      //       );
                      //     }
                      //   }
                      // },
                      label: "حفظ التعديلات",
                      color: Colors.blue.shade50,
                      textColor: Colors.blue.shade700,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().move(delay: 300.ms);
      },
    );
  }
}
