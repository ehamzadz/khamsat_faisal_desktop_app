import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/home_page.dart';
import '../services/api_service_materials.dart';
import '../widgets/snackbar.dart';

Future<void> handleSubmit(
  BuildContext context,
  GlobalKey<FormState> formKey,
  Map<String, String> data,
) async {
  if (formKey.currentState!.validate()) {
    formKey.currentState!.save();
    try {
      final success = await ApiService().insertDataViaAPI(data);
      if (success) {
        Provider.of<DashboardProvider>(context, listen: false).fetchData();
        Navigator.pop(context);
      } else {
        showErrorSnackbar(
            context, 'فشل في إضافة البيانات', Colors.red.shade400);
      }
    } catch (e) {
      showErrorSnackbar(context, 'فشل في إضافة البيانات', Colors.red.shade400);
    }
  }
}
