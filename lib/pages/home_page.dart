// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/stats_provider.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/navigation_widget.dart';
import '../widgets/footer_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String? fileName;
  List<double> income = [];
  List<double> spending = [];
  bool showCharts = false;

  // 🎬 Animation fields
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // 📌 Category buckets
  Map<String, double> categoryTotals = {
    "Groceries": 0,
    "Fuel/Gas": 0,
    "Electricity/Bills": 0,
    "Travel": 0,
    "Rent": 0,
    "Others": 0,
  };

  // 🔍 Category classifier
  String getCategory(String description) {
    description = description.toLowerCase();

    if (description.contains("woolworths") ||
        description.contains("coles") ||
        description.contains("grocery")) {
      return "Groceries";
    }
    if (description.contains("bp") ||
        description.contains("7-eleven") ||
        description.contains("fuel")) {
      return "Fuel/Gas";
    }
    if (description.contains("electric") ||
        description.contains("energy") ||
        description.contains("bill")) {
      return "Electricity/Bills";
    }
    if (description.contains("uber") ||
        description.contains("bus") ||
        description.contains("train") ||
        description.contains("opal")) {
      return "Travel";
    }
    if (description.contains("rent") ||
        description.contains("property") ||
        description.contains("accommodation")) {
      return "Rent";
    }
    return "Others";
  }

  // 📂 CSV picker + logic
  Future<void> _pickCSVFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null) {
        Uint8List? fileBytes = result.files.single.bytes;
        String fileNameLocal = result.files.single.name;

        if (fileBytes == null) throw Exception("File bytes are null");

        final contents = String.fromCharCodes(fileBytes);
        final rows = CsvToListConverter(eol: '\n').convert(contents).skip(1);

        Map<int, double> weeklyIncome = {};
        Map<int, double> weeklySpending = {};

        // Reset categories
        categoryTotals.updateAll((key, value) => 0);

        for (var row in rows) {
          if (row.length < 5) continue;

          String description = row[1].toString();
          String debitStr = row[2].toString().replaceAll(RegExp(r'[^\d.-]'), '');
          String creditStr = row[3].toString().replaceAll(RegExp(r'[^\d.-]'), '');

          double debit = double.tryParse(debitStr) ?? 0.0;
          double credit = double.tryParse(creditStr) ?? 0.0;

          DateTime date = DateTime.now();
          int weekNumber = ((date.day - 1) ~/ 7) + 1;

          weeklyIncome[weekNumber] = (weeklyIncome[weekNumber] ?? 0) + credit;
          weeklySpending[weekNumber] = (weeklySpending[weekNumber] ?? 0) + debit;

          // categorize spending
          categoryTotals[getCategory(description)] =
              (categoryTotals[getCategory(description)] ?? 0) + debit;
        }

        setState(() {
          fileName = fileNameLocal;
          income = weeklyIncome.values.toList();
          spending = weeklySpending.values.toList();
          showCharts = false;
        });

        Provider.of<StatsProvider>(context, listen: false)
            .updateStats(totalIncome, totalSpending);
      }
    } catch (e) {
      debugPrint("Error parsing CSV: $e");
    }
  }

  double get totalIncome => income.fold(0, (a, b) => a + b);
  double get totalSpending => spending.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Home'),
      drawer: NavigationWidget(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Expense Tracker Dashboard',
                              style: Theme.of(context).textTheme.headlineSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20),

                            ElevatedButton.icon(
                              onPressed: _pickCSVFile,
                              icon: Icon(Icons.upload_file),
                              label: Text('Upload Bank Statement CSV'),
                            ),

                            if (fileName != null) ...[
                              SizedBox(height: 10),
                              Text('Selected file: $fileName'),
                            ],

                            SizedBox(height: 20),

                            if (income.isNotEmpty && spending.isNotEmpty)
                              ElevatedButton(
                                onPressed: () {
                                  setState(() => showCharts = true);
                                  _fadeController.forward();
                                },
                                child: Text("Track Expenses"),
                              ),

                            SizedBox(height: 20),

                            if (showCharts)
                              AnimatedBuilder(
                                animation: _fadeAnimation,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _fadeAnimation.value,
                                    child: Transform.translate(
                                      offset: Offset(
                                          0, 40 * (1 - _fadeAnimation.value)),
                                      child: Column(
                                        children: [
                                          _buildGraphBox(
                                            _buildPieChart(),
                                            "Income vs Expenses",
                                          ),
                                          SizedBox(height: 20),
                                          _buildGraphBox(
                                            _buildCategoryBarChart(),
                                            "Spending by Category",
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    Footer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🎨 Beautiful reusable graph card
  Widget _buildGraphBox(Widget child, String title) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.teal.withOpacity(0.4),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal),
            ),
            SizedBox(height: 12),
            SizedBox(height: 300, child: child),
          ],
        ),
      ),
    );
  }

  // 🥧 Pie chart
  Widget _buildPieChart() {
    final total = totalIncome + totalSpending;
    if (total == 0) return Text("No data to show");

    final inc = totalIncome / total * 100;
    final exp = totalSpending / total * 100;

    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 45,
        sections: [
          PieChartSectionData(
            value: inc,
            color: Colors.green,
            title: "Income\n${inc.toStringAsFixed(1)}%",
          ),
          PieChartSectionData(
            value: exp,
            color: Colors.redAccent,
            title: "Expenses\n${exp.toStringAsFixed(1)}%",
          ),
        ],
      ),
    );
  }

  // 📊 Category bar chart
  Widget _buildCategoryBarChart() {
    final labels = categoryTotals.keys.toList();
    final values = categoryTotals.values.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),

        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                int i = value.toInt();
                if (i >= labels.length) return SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[i], style: TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),

        barGroups: List.generate(values.length, (i) {
          final amount = values[i];

          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: amount,
                width: 20,
                color: Colors.teal,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          );
        }),

        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                "\$${rod.toY.toStringAsFixed(2)}",
                TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
              );
            },
          ),
        ),
      ),
    );
  }
}