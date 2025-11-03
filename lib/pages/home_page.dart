import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/navigation_widget.dart';
import '../widgets/footer_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? fileName;
  List<List<dynamic>>? csvData;
  List<double> income = [];
  List<double> spending = [];
  List<double> investment = [];

  Future<void> _pickCSVFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true, // Important for web
    );

    if (result != null) {
      Uint8List? fileBytes = result.files.single.bytes;
      String fileNameLocal = result.files.single.name;

      if (fileBytes != null) {
        // Convert bytes → String
        final contents = String.fromCharCodes(fileBytes);
        final data = const CsvToListConverter().convert(contents);

        // Skip header
        final rows = data.skip(1).toList();
        income = [];
        spending = [];
        investment = [];

        for (var row in rows) {
          if (row.length >= 4) {
            income.add(double.tryParse(row[1].toString()) ?? 0);
            spending.add(double.tryParse(row[2].toString()) ?? 0);
            investment.add(double.tryParse(row[3].toString()) ?? 0);
          }
        }

        setState(() {
          fileName = fileNameLocal;
          csvData = data;
        });
      }
    }
  }

  double get totalIncome => income.fold(0, (a, b) => a + b);
  double get totalSpending => spending.fold(0, (a, b) => a + b);
  double get totalInvestment => investment.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final bool hasData = income.isNotEmpty;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Home'),
      drawer: const NavigationWidget(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Financial Overview',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Upload button
            ElevatedButton.icon(
              onPressed: _pickCSVFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload CSV File'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            if (fileName != null) ...[
              const SizedBox(height: 10),
              Text('Selected file: $fileName',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
            const SizedBox(height: 20),

            if (hasData) ...[
              _buildSectionTitle('Weekly Income, Spending & Investment'),
              SizedBox(height: 250, child: _buildBarChart()),

              const SizedBox(height: 30),

              _buildSectionTitle('Overall Distribution'),
              SizedBox(height: 250, child: _buildPieChart()),

              const SizedBox(height: 30),

              _buildSectionTitle('Trends Over Time'),
              SizedBox(height: 250, child: _buildLineChart()),
            ] else
              const Text('Upload a CSV file to see visualized results.'),

            const SizedBox(height: 30),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );

  // --- BAR CHART ---
  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, _) => Text('W${(value + 1).toInt()}'),
            ),
          ),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 200)),
        ),
        barGroups: List.generate(income.length, (i) {
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(
                toY: income[i],
                color: Colors.green,
                width: 10,
                borderRadius: BorderRadius.circular(4)),
            BarChartRodData(
                toY: spending[i],
                color: Colors.redAccent,
                width: 10,
                borderRadius: BorderRadius.circular(4)),
            BarChartRodData(
                toY: investment[i],
                color: Colors.blueAccent,
                width: 10,
                borderRadius: BorderRadius.circular(4)),
          ]);
        }),
      ),
    );
  }

  // --- PIE CHART ---
  Widget _buildPieChart() {
    final total = totalIncome + totalSpending + totalInvestment;
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: totalIncome,
            color: Colors.green,
            title:
                'Income\n${(totalIncome / total * 100).toStringAsFixed(1)}%',
          ),
          PieChartSectionData(
            value: totalSpending,
            color: Colors.redAccent,
            title:
                'Spending\n${(totalSpending / total * 100).toStringAsFixed(1)}%',
          ),
          PieChartSectionData(
            value: totalInvestment,
            color: Colors.blueAccent,
            title:
                'Investment\n${(totalInvestment / total * 100).toStringAsFixed(1)}%',
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  // --- LINE CHART ---
  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) =>
                    Text('W${(value + 1).toInt()}')),
          ),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 200)),
        ),
        lineBarsData: [
          _buildLine(income, Colors.green),
          _buildLine(spending, Colors.redAccent),
          _buildLine(investment, Colors.blueAccent),
        ],
      ),
    );
  }

  LineChartBarData _buildLine(List<double> values, Color color) {
    return LineChartBarData(
      isCurved: true,
      color: color,
      barWidth: 3,
      belowBarData: BarAreaData(show: false),
      spots: List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i])),
    );
  }
}