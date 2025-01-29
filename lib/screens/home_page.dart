import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/api_service_materials.dart';
import '../widgets/build_footer.dart';
import '../widgets/build_searchbar.dart';
import '../widgets/build_stats_card.dart';
import '../widgets/show_delete_confirmation_dialog.dart';
import '../widgets/show_dialog_add.dart';
import '../widgets/show_edit_confirmation_dialog.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20.0, // Adjust the size of the avatar as needed
                  backgroundImage:
                      AssetImage('assets/logo.png'), // Add your image here
                ),
                SizedBox(width: 10), // Space between the image and text
                Text('الشركة المتحدة العربية'),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () =>
                context.read<DashboardProvider>().showFilterDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.import_export),
            onPressed: () =>
                context.read<DashboardProvider>().exportData(context),
          ),
          IconButton(
            icon: Icon(
                context.watch<DashboardProvider>().themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode),
            onPressed: () => context.read<DashboardProvider>().toggleTheme(),
          ),
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () => context.read<DashboardProvider>().toggleLocale(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            // if (provider.tableData.isEmpty) {
            //   return noDataPanel();
            // }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Container(
                    height: 145,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            showAddDataDialog(context);
                          },
                          child: Card(
                            elevation: 4,
                            color: Colors.green[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 40,
                                      // color: Theme.of(context)
                                      //     .colorScheme
                                      //     .primary,

                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'إضافة',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'مادة جديدة',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: Container()),
                        InkWell(
                          onTap: () {
                            context
                                .read<DashboardProvider>()
                                .showFilterDialog(context);
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Icon(Icons.filter_list,
                                      size: 40,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  SizedBox(height: 10),
                                  Text('فلتر',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  Text('بحدث متقدم',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            context
                                .read<DashboardProvider>()
                                .exportData(context);
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Icon(Icons.save,
                                      size: 40,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  SizedBox(height: 10),
                                  Text('تصدير',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  Text('نصدير البيانات',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      buildStatsCards(provider),
                      SizedBox(height: 20),
                      buildSearchBar(context, provider),
                      SizedBox(height: 20),
                      if (!provider.tableData.isEmpty)
                        Expanded(
                            child: Container(
                                child: DataGridWidget(
                                    dataSource: provider.itemDataGridSource)))
                      else
                        noDataPanel(),
                      SizedBox(height: 20),
                      // buildFooter(context),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: HiddenFooter(), // Add the hidden footer
    );
  }
}

class noDataPanel extends StatelessWidget {
  const noDataPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height - 392,
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 72,
                  color: Colors.blue,
                ),
              )
                  .animate()
                  .fadeIn()
                  .scale(duration: const Duration(milliseconds: 400)),
              const SizedBox(height: 24),
              Text(
                'لا توجد بيانات متاحة',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  height: 1.2,
                ),
              )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 200))
                  .slideY(
                      begin: 0.3, duration: const Duration(milliseconds: 400)),
              const SizedBox(height: 12),
              Text(
                'سيتم عرض البيانات هنا عند توفرها',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 400))
                  .slideY(
                      begin: 0.3, duration: const Duration(milliseconds: 400)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class DataGridWidget extends StatelessWidget {
  final ItemDataGridSource dataSource;

  const DataGridWidget({required this.dataSource});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 645,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: SfDataGrid(
        source: dataSource,
        columnWidthMode: ColumnWidthMode.fill,
        allowColumnsResizing: true,
        allowSorting: true,
        gridLinesVisibility: GridLinesVisibility.horizontal,
        headerGridLinesVisibility: GridLinesVisibility.horizontal,
        columns: [
          GridColumn(
            columnName: 'مفتاح',
            label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text('مفتاح'),
            ),
          ),
          GridColumn(
            columnName: 'حالة المادة',
            label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text('حالة المادة'),
            ),
          ),
          GridColumn(
            columnName: 'اسم المادة',
            label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text('اسم المادة'),
            ),
          ),
          GridColumn(
            columnName: 'رقم المادة',
            label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text('رقم المادة'),
            ),
          ),
          GridColumn(
            columnName: 'السيريال نمبر',
            label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text('السيريال نمبر'),
            ),
          ),
          GridColumn(
            columnName: 'الرقم العام',
            label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text('الرقم العام'),
            ),
          ),
          GridColumn(
            columnName: 'لصالح من',
            label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text('لصالح من'),
            ),
          ),
          // Add a new column for actions
          GridColumn(
            columnName: 'الإجراءات',
            label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text('الإجراءات'),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemDataGridSource extends DataGridSource {
  ItemDataGridSource({required List<Map<String, String>> tableData}) {
    _items = tableData
        .map((data) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'مفتاح', value: data['مفتاح']!),
              DataGridCell<String>(
                  columnName: 'حالة المادة', value: data['حالة المادة']!),
              DataGridCell<String>(
                  columnName: 'اسم المادة', value: data['اسم المادة']!),
              DataGridCell<String>(
                  columnName: 'رقم المادة', value: data['رقم المادة']!),
              DataGridCell<String>(
                  columnName: 'السيريال نمبر', value: data['السيريال نمبر']!),
              DataGridCell<String>(
                  columnName: 'الرقم العام', value: data['الرقم العام']!),
              DataGridCell<String>(
                  columnName: 'لصالح من', value: data['لصالح من']!),
              // Add a new cell for actions
              DataGridCell<Map<String, String>>(
                  columnName: 'الإجراءات', value: data),
            ]))
        .toList();
  }

  List<DataGridRow> _items = [];

  @override
  List<DataGridRow> get rows => _items;

  // void _handleEdit(Map<String, String> item) {
  //   // Handle edit action
  //   print('Edit item: ${item['مفتاح']}');
  //   // You can open a dialog or navigate to an edit screen here
  // }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'الإجراءات') {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShowEditonfirmationDialog(
                    item: dataGridCell.value,
                  ),
                  // ActionButton(
                  //   icon: Icons.edit_rounded,
                  //   label: 'تعديل',
                  //   color: Colors.blue.shade100,
                  //   iconColor: Colors.blue.shade700,
                  //   onPressed: () =>
                  //       showEditDataDialog(context, dataGridCell.value),
                  // ),
                  SizedBox(width: 8),
                  ShowDeleteConfirmationDialog(
                    item: dataGridCell.value,
                  ),
                ],
              ),
            ),
          );
        } else {
          if (dataGridCell.columnName == 'حالة المادة') {
            // Customize the text based on the status
            final status = dataGridCell.value.toString();
            IconData icon;
            Color color;
            Color backgroundColor;

            switch (status) {
              case 'تحت العمل':
                icon = Icons.construction;
                color =
                    Colors.orange.shade800; // Darker shade for better contrast
                backgroundColor = Colors.orange.shade100; // Lighter background
                break;
              case 'تم التحويل':
                icon = Icons.swap_horiz;
                color = Colors.blue.shade800;
                backgroundColor = Colors.blue.shade100;
                break;
              case 'شطبت':
                icon = Icons.delete_forever;
                color = Colors.red.shade800;
                backgroundColor = Colors.red.shade100;
                break;
              case 'تم الانتهاء منها':
                icon = Icons.check_circle_outline;
                color = Colors.green.shade800;
                backgroundColor = Colors.green.shade100;
                break;
              default:
                icon = Icons.error;
                color = Colors.grey.shade800;
                backgroundColor = Colors.grey.shade100;
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                // padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 14, color: color),
                      ),
                      SizedBox(width: 6),
                      Text(
                        status,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            // Render regular cell content
            return Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(8),
              child: Text(
                dataGridCell.value.toString(),
                style: TextStyle(
                    // color: Colors.black,
                    ),
              ),
            );
          }
        }
      }).toList(),
    );
  }
}

class DashboardProvider with ChangeNotifier {
  String selectedStatusFilter = "جميع";
  final ApiService _apiService = ApiService();
  List<Map<String, String>> tableData = [];
  bool isLoading = false;
  late ItemDataGridSource itemDataGridSource;
  TextEditingController searchController = TextEditingController();
  String selectedBeneficiaryFilter = "جميع";
  int currentPage = 1;
  final int itemsPerPage = 10;
  ThemeMode themeMode = ThemeMode.light;
  Locale locale = Locale('ar');

  DashboardProvider() {
    itemDataGridSource = ItemDataGridSource(tableData: tableData);
  }

  // Function to update selectedStatusFilter
  void updateSelectedStatusFilter(String newStatus) {
    selectedStatusFilter = newStatus;
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();

    try {
      tableData = await _apiService.fetchItems();
      itemDataGridSource = ItemDataGridSource(tableData: tableData);
      print(selectedStatusFilter);
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await fetchData();
  }

  void filterTable() {
    String searchTerm = searchController.text.toLowerCase();
    if (searchTerm.isEmpty) {
      fetchData();
    } else {
      tableData = tableData
          .where((item) => item.values
              .any((value) => value.toLowerCase().contains(searchTerm)))
          .toList();
      itemDataGridSource = ItemDataGridSource(tableData: tableData);
      notifyListeners();
    }
    // // if (selectedStatusFilter == "جميع") {
    // //   // Show all data
    // //   print(selectedStatusFilter);
    // //   fetchData();
    // // } else {
    // print('====${selectedStatusFilter}');
    // // Filter data based on selectedStatusFilter
    // // }
  }

  void goToPage(int page) {
    currentPage = page;
    notifyListeners();
  }

  int get totalPages => (tableData.length / itemsPerPage).ceil();

  List<Map<String, String>> get paginatedData {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return tableData.sublist(
        startIndex, endIndex > tableData.length ? tableData.length : endIndex);
  }

  List<Map<String, dynamic>> getStats() {
    return [
      {
        "title": "إجمالي المواد",
        "value": tableData.length.toString(),
        "icon": Icons.inventory
      },
      {
        "title": "تحت العمل",
        "value": tableData
            .where((item) => item["حالة المادة"] == "تحت العمل")
            .length
            .toString(),
        "icon": Icons.construction
      },
      {
        "title": "تم التحويل",
        "value": tableData
            .where((item) => item["حالة المادة"] == "تم التحويل")
            .length
            .toString(),
        "icon": Icons.swap_horiz
      },
      {
        "title": "شطبت",
        "value": tableData
            .where((item) => item["حالة المادة"] == "شطبت")
            .length
            .toString(),
        "icon": Icons.delete_forever
      },
      {
        "title": "تم الانتهاء منها",
        "value": tableData
            .where((item) => item["حالة المادة"] == "تم الانتهاء منها")
            .length
            .toString(),
        "icon": Icons.check_circle_outline
      },
      // تم الانتهاء منها - شُطبت - تم التحويل - تحت العمل
    ];
  }

  void showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "تصفية البيانات",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "اختر الحالة:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8), // Spacing
                  DropdownButtonFormField<String>(
                    value: selectedStatusFilter,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      "جميع",
                      "تحت العمل",
                      "تم التحويل",
                      "شطبت",
                      "تم الانتهاء منها"
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedStatusFilter = value!;
                      notifyListeners();
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Reset filters
                selectedStatusFilter = "جميع";
                notifyListeners();
                Navigator.pop(context);
                filterTable();
              },
              child: Text(
                "إعادة تعيين",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // filterTable();
                await fetchData();

                if (selectedStatusFilter == "جميع") {
                  // Show all data
                  // print(selectedStatusFilter);
                  fetchData();
                } else {
                  tableData = tableData
                      .where(
                          (item) => item["حالة المادة"] == selectedStatusFilter)
                      .toList();

                  // Update the data source
                  itemDataGridSource = ItemDataGridSource(tableData: tableData);

                  // Notify listeners to refresh the UI
                  notifyListeners();
                }
              },
              child: Text(
                "تطبيق",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleLocale() {
    locale = locale.languageCode == 'ar' ? Locale('en') : Locale('ar');
    notifyListeners();
  }

  Future<void> exportData(BuildContext context) async {
    try {
      final csvData = const ListToCsvConverter().convert(
        tableData.map((row) => row.values.toList()).toList(),
      );

      final bom = utf8.encode('\uFEFF');
      final csvBytes = [...bom, ...utf8.encode(csvData)];

      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception("Could not access downloads directory.");
      }

      final file = File('${directory.path}/data.csv');
      await file.writeAsBytes(csvBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تصدير البيانات إلى ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تصدير البيانات: $e')),
      );
    }
  }

  void addData(Map<String, String> newData) {
    tableData.add(newData);
    itemDataGridSource = ItemDataGridSource(tableData: tableData);
    notifyListeners();
  }

  void refresh(Map<String, String> newData) {
    tableData.remove(newData); // Modify condition as needed
    itemDataGridSource = ItemDataGridSource(tableData: tableData);
    notifyListeners();
  }

  void deleteData(Map<String, String> newData) {
    tableData.remove(newData); // Modify condition as needed

    itemDataGridSource = ItemDataGridSource(tableData: tableData);
    notifyListeners();
  }
}
