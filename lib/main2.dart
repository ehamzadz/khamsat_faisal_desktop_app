import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_animate/flutter_animate.dart'; // For animations

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins', // Custom font
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins', // Custom font
      ),
      themeMode: context.watch<DashboardProvider>().themeMode,
      supportedLocales: [Locale('ar'), Locale('en')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: context.watch<DashboardProvider>().locale,
      home: DashboardPage(),
    );
  }
}

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
                child: CircularProgressIndicator(),
              );
            }

            // if (provider.tableData.isEmpty) {
            //   return Center(
            //     child: Text('لا توجد بيانات متاحة').animate().fadeIn(),
            //   );
            // }

            return SmartRefresher(
              controller: _refreshController,
              onRefresh: () async {
                await provider.refreshData();
                _refreshController.refreshCompleted();
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildStatsCards(provider),
                      SizedBox(height: 20),
                      _buildSearchBar(provider),
                      SizedBox(height: 20),
                      DataGridWidget(dataSource: provider.itemDataGridSource),
                      SizedBox(height: 20),
                      _buildPagination(provider),
                      SizedBox(height: 20),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<DashboardProvider>().fetchData();
        },
        child: Icon(Icons.add),
      ).animate().scale(),
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
        ).animate().fadeIn(delay: 100.ms);
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
              fillColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
            onChanged: (value) => provider.filterTable(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildPagination(DashboardProvider provider) {
    final totalPages = provider.totalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: provider.currentPage > 1
              ? () => provider.goToPage(provider.currentPage - 1)
              : null,
        ),
        Text("الصفحة ${provider.currentPage} من $totalPages"),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: provider.currentPage < totalPages
              ? () => provider.goToPage(provider.currentPage + 1)
              : null,
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("© 2023 اسم الشركة. جميع الحقوق محفوظة."),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
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
    ).animate().scale();
  }
}

class DataGridWidget extends StatelessWidget {
  final ItemDataGridSource dataSource;

  const DataGridWidget({required this.dataSource});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.surfaceVariant,
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
          GridColumn(
            columnName: 'حالة المادة',
            label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text('حالة المادة'),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }
}

class ItemDataGridSource extends DataGridSource {
  ItemDataGridSource({required List<Map<String, String>> tableData}) {
    _items = tableData
        .map((data) => DataGridRow(cells: [
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
              DataGridCell<String>(
                  columnName: 'حالة المادة', value: data['حالة المادة']!),
            ]))
        .toList();
  }

  List<DataGridRow> _items = [];

  @override
  List<DataGridRow> get rows => _items;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8),
          child: Text(dataGridCell.value.toString()),
        );
      }).toList(),
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
        "title": "نشط",
        "value": tableData
            .where((item) => item["حالة المادة"] == "نشط")
            .length
            .toString(),
        "icon": Icons.check_circle
      },
      {
        "title": "غير نشط",
        "value": tableData
            .where((item) => item["حالة المادة"] == "غير نشط")
            .length
            .toString(),
        "icon": Icons.cancel
      },
      {
        "title": "معلق",
        "value": tableData
            .where((item) => item["حالة المادة"] == "معلق")
            .length
            .toString(),
        "icon": Icons.pending
      },
    ];
  }

  void showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("تصفية البيانات"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedStatusFilter,
                items: ["جميع", "نشط", "غير نشط", "معلق"].map((String value) {
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
              DropdownButton<String>(
                value: selectedBeneficiaryFilter,
                items: ["جميع", "قسم 1", "قسم 2", "قسم 3"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedBeneficiaryFilter = value!;
                  notifyListeners();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                filterTable();
              },
              child: Text("تطبيق"),
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
}

class ApiService {
  final String baseUrl = 'http://127.0.0.1:5000';

  Future<List<Map<String, String>>> fetchItems() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/items'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data
            .map<Map<String, String>>((item) => {
                  "اسم المادة": item["اسم المادة"],
                  "رقم المادة": item["رقم المادة"],
                  "السيريال نمبر": item["السيريال نمبر"],
                  "الرقم العام": item["الرقم العام"],
                  "لصالح من": item["لصالح من"],
                  "حالة المادة": item["حالة المادة"],
                })
            .toList();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }
}
