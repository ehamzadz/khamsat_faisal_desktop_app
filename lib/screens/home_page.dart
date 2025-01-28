import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_service_materials.dart'; // For animations

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
        title: Text('لوحة التحكم'),
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
                child: CircularProgressIndicator()
                    .animate()
                    .shimmer(delay: 400.ms),
              );
            }

            // if (provider.tableData.isEmpty) {
            //   return Center(
            //     child: Text('لا توجد بيانات متاحة').animate().fadeIn(),
            //   );
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
                          ).animate().shimmer(delay: 400.ms),
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
                          ).animate().shimmer(delay: 400.ms),
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
                          ).animate().shimmer(delay: 400.ms),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      _buildStatsCards(provider),
                      SizedBox(height: 20),
                      _buildSearchBar(provider),
                      SizedBox(height: 20),
                      Expanded(
                          child: Container(
                              child: DataGridWidget(
                                  dataSource: provider.itemDataGridSource))),
                      // SizedBox(height: 20),
                      // _buildPagination(provider),
                      SizedBox(height: 20),
                      _buildFooter(),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // context.read<DashboardProvider>().fetchData();

      //     showAddDataDialog(context); // Open the add data dialog
      //   },
      //   child: Icon(Icons.add),
      // ).animate().scale(),
    );
  }

  Widget _buildStatsCards(DashboardProvider provider) {
    final stats = provider.getStats();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: stats.map((stat) {
        return StatsCard(
          title: stat["title"] as String,
          value: stat["value"] as String,
          icon: stat["icon"] as IconData,
        ).animate().shimmer(delay: 400.ms);
      }).toList(),
    );
  }

  Widget _buildSearchBar(DashboardProvider provider) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: provider.searchController,
            decoration: InputDecoration(
              hintText: "ابحث عن مادة...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainer,
            ),
            onChanged: (value) => provider.filterTable(),
          ),
        ),
      ],
    ).animate().shimmer(delay: 400.ms);
  }

  // Widget _buildPagination(DashboardProvider provider) {
  //   final totalPages = provider.totalPages;

  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       IconButton(
  //         icon: Icon(Icons.arrow_back),
  //         onPressed: provider.currentPage > 1
  //             ? () => provider.goToPage(provider.currentPage - 1)
  //             : null,
  //       ),
  //       Text("الصفحة ${provider.currentPage} من $totalPages"),
  //       IconButton(
  //         icon: Icon(Icons.arrow_forward),
  //         onPressed: provider.currentPage < totalPages
  //             ? () => provider.goToPage(provider.currentPage + 1)
  //             : null,
  //       ),
  //     ],
  //   ).animate().fadeIn(delay: 300.ms);
  // }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              child: Text("©eHamzaDZ"),
              onTap: () async {
                final whatsappUrl = "https://wa.me/+213672138811";

                // Check if the platform is a desktop (Windows, macOS, Linux)
                if (Platform.isWindows ||
                    Platform.isMacOS ||
                    Platform.isLinux) {
                  try {
                    // Open the URL in the browser using Process.start for desktop platforms
                    await Process.start('cmd', ['/c', 'start', whatsappUrl]);
                  } catch (e) {
                    print("Could not launch URL on desktop: $e");
                  }
                } else {
                  // Use url_launcher on mobile devices
                  final uri = Uri.parse(whatsappUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    throw 'Could not launch $whatsappUrl';
                  }
                }
              },
            ),
          ),
        ],
      ),
    ).animate().shimmer(delay: 400.ms);
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatsCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            SizedBox(height: 10),
            Text(value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    ).animate().shimmer(delay: 400.ms);
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
    ).animate().shimmer(delay: 400.ms);
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

  void _handleEdit(Map<String, String> item) {
    // Handle edit action
    print('Edit item: ${item['اسم المادة']}');
    // You can open a dialog or navigate to an edit screen here
  }

  void _handleDelete(Map<String, String> item) {
    // Handle delete action
    print('Delete item: ${item['اسم المادة']}');
    // You can show a confirmation dialog and delete the item from the data source
  }

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
                  _ActionButton(
                    icon: Icons.edit_rounded,
                    label: 'تعديل',
                    color: Colors.blue.shade100,
                    iconColor: Colors.blue.shade700,
                    onPressed: () => _handleEdit(dataGridCell.value),
                  ),
                  SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.delete_rounded,
                    label: 'حذف',
                    color: Colors.red.shade50,
                    iconColor: Colors.red.shade600,
                    onPressed: () => _handleDelete(dataGridCell.value),
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

            return Padding(
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: iconColor.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: iconColor),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Map<String, String>> tableData = [];
  bool isLoading = false;
  late ItemDataGridSource itemDataGridSource;
  TextEditingController searchController = TextEditingController();
  String selectedStatusFilter = "جميع";
  String selectedBeneficiaryFilter = "جميع";
  int currentPage = 1;
  final int itemsPerPage = 10;
  ThemeMode themeMode = ThemeMode.light;
  Locale locale = Locale('ar');

  DashboardProvider() {
    itemDataGridSource = ItemDataGridSource(tableData: tableData);
  }

  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();

    try {
      tableData = await _apiService.fetchItems();
      itemDataGridSource = ItemDataGridSource(tableData: tableData);
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
    tableData.add(newData); // Add the new data to the list
    itemDataGridSource =
        ItemDataGridSource(tableData: tableData); // Update the data source
    notifyListeners(); // Notify listeners to update the UI
  }
}

void showAddDataDialog(BuildContext context) {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> newData = {
    'اسم المادة': '',
    'رقم المادة': '',
    'السيريال نمبر': '',
    'الرقم العام': '',
    'لصالح من': '',
    'حالة المادة': '',
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
                          if (field == 'حالة المادة') {
                            return _buildDropdownField(field, newData);
                          }
                          return _buildTextField(field, newData);
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
                  _DialogButton(
                    onPressed: () => Navigator.pop(context),
                    label: "إلغاء",
                    color: Colors.grey.shade200,
                    textColor: Colors.grey.shade700,
                  ),
                  SizedBox(width: 12),
                  _DialogButton(
                    onPressed: () => _handleSubmit(context, _formKey, newData),
                    label: "حفظ",
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

Widget _buildTextField(String label, Map<String, String> data) {
  return TextFormField(
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    validator: (value) => value?.isEmpty ?? true ? 'يرجى إدخال $label' : null,
    onSaved: (value) => data[label] = value ?? '',
  );
}

Widget _buildDropdownField(String label, Map<String, String> data) {
  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    items: ['تحت العمل', 'تم التحويل', 'شطبت', 'تم الانتهاء منها']
        .map((value) => DropdownMenuItem(value: value, child: Text(value)))
        .toList(),
    validator: (value) => value == null ? 'يرجى اختيار حالة المادة' : null,
    onChanged: (value) => data[label] = value ?? '',
  );
}

class _DialogButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Color color;
  final Color textColor;

  const _DialogButton({
    required this.onPressed,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Text(label,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }
}

Future<void> _handleSubmit(
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
        _showErrorSnackbar(context);
      }
    } catch (e) {
      _showErrorSnackbar(context);
    }
  }
}

void _showErrorSnackbar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('فشل في إضافة البيانات'),
      backgroundColor: Colors.red.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(10),
    ),
  );
}
