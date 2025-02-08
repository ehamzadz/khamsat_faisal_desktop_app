import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../functions/handle_submit.dart';
import 'build_dropdown_field.dart';
import 'build_textfield.dart';
import 'dialog_button.dart';

void showAddDataDialog(BuildContext context) {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> newData = {
    'material_name': '',
    'number': '',
    'serial_number': '',
    'general_number': '',
    'for_who': '',
    'status': '',
    'created_at': '',
    'updated_at_transfert': '',
    'updated_at_exit': '',
  };

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.add_circle_outline, color: Colors.blue.shade700),
                  SizedBox(width: 12),
                  Text(
                    "إضافة مادة جديدة",
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
                        ...newData.keys.map((field) {
                          if (field == 'status') {
                            return buildDropdownField(
                                field, newData, 'يرجى اختيار أحد الإختيارات', [
                              'تحت العمل',
                              'تم التحويل',
                              'شطبت',
                              'تم الانتهاء منها'
                            ]);
                          }
                          if (field == 'created_at' ||
                              field == 'updated_at_transfert' ||
                              field == 'updated_at_exit') {
                            return SizedBox();
                          }
                          return buildTextField(field, newData);
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
                    onPressed: () => handleSubmit(context, _formKey, newData),
                    label: "حفظ",
                    color: Colors.blue.shade50,
                    textColor: Colors.blue.shade700,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
