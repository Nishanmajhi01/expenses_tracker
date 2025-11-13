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
  List<double> income = [];
  List<double> spending = [];
  bool showCharts = false; // only show after clicking Track Expenses

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

        if (fileBytes == null) {
          throw Exception("File bytes are null — please reselect file.");
        }

        final contents = String.fromCharCodes(fileBytes);
        final data = const CsvToListConverter(eol: '\n').convert(contents);
        final rows = data.skip(1).toList();

        Map<int, double> weeklyIncome = {};
        Map<int, double> weeklySpending = {};

        for (var row in rows) {
          if (row.length < 5) continue;

          String dateStr = row[0].toString().trim();
          String debitStr =
              row[2].toString().replaceAll(RegExp(r'[^\d.-]'), '');
          String creditStr =
              row[3].toString().replaceAll(RegExp(r'[^\d.-]'), '');

          double debit = double.tryParse(debitStr) ?? 0.0;
          double credit = double.tryParse(creditStr) ?? 0.0;

          try {
            DateTime date = DateTime.now();
            int weekNumber = ((date.day - 1) ~/ 7) + 1;

            weeklyIncome[weekNumber] =
                (weeklyIncome[weekNumber] ?? 0) + credit;
            weeklySpending[weekNumber] =
                (weeklySpending[weekNumber] ?? 0) + debit;
          } catch (_) {
            continue;
          }
        }

        setState(() {
          fileName = fileNameLocal;
          income = weeklyIncome.values.toList();
          spending = weeklySpending.values.toList();
          showCharts = false;
        });
      }
    } catch (e) {
      debugPrint("2Error parsing CSV: $e");
    }
  }

  double get totalIncome => income.fold(0, (a, b) => a + b);
  double get totalSpending => spending.fold(0, (a, b) => a + b);

  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: const CustomAppBar(title: 'Home'),
    drawer: const NavigationWidget(),
    body: LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Expense Tracker Dashboard',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),

                          // Upload button
                          ElevatedButton.icon(
                            onPressed: _pickCSVFile,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload Bank Statement CSV'),
                          ),

                          if (fileName != null) ...[
                            const SizedBox(height: 10),
                            Text('Selected file: $fileName',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                          ],

                          const SizedBox(height: 20),

                          if (income.isNotEmpty && spending.isNotEmpty)
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  showCharts = true;
                                });
                              },
                              child: const Text('Track Expenses'),
                            ),

                          const SizedBox(height: 20),

                          if (showCharts) ...[
                            _buildSummaryCard(),
                            const SizedBox(height: 20),
                            _buildPieChart(),
                            const SizedBox(height: 30),
                            _buildBarChart(),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ✅ Footer always pinned to bottom
                  const Footer(),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

  //  Box showing Income & Expenses
  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Summary',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Total Income: \$${totalIncome.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.green, fontSize: 16)),
            Text('Total Expenses: \$${totalSpending.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  //  Pie Chart
  Widget _buildPieChart() {
    final total = totalIncome + totalSpending;
    if (total == 0) return const Text("No data to show.");

    final incomePercent = totalIncome / total * 100;
    final spendingPercent = totalSpending / total * 100;

    return Column(
      children: [
        const Text('Income vs Expenses',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        SizedBox(
          height: 230,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 45,
              sections: [
                PieChartSectionData(
                  value: incomePercent.toDouble(),
                  color: Colors.green,
                  title:
                      'Income\n${incomePercent.toStringAsFixed(1)}%',
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                PieChartSectionData(
                  value: spendingPercent.toDouble(),
                  color: Colors.redAccent,
                  title:
                      'Spending\n${spendingPercent.toStringAsFixed(1)}%',
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  //  Bar Chart
Widget _buildBarChart() {
  return Column(
    children: [
      const Text(
        'Weekly Income vs Spending',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            gridData: FlGridData(show: true, horizontalInterval: 2000),
            alignment: BarChartAlignment.spaceBetween,
            barTouchData: BarTouchData(enabled: true),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              //  Only show left and bottom titles — hide right & top to stop overlap
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45,
                  interval: 1,
                  getTitlesWidget: (value, _) => Transform.rotate(
                    angle: -0.4, // slight rotation for readability
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        'W${(value + 1).toInt()}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48,
                  interval: 2000,
                  getTitlesWidget: (value, _) => Text(
                    '\$${value ~/ 1000}K',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
            barGroups: List.generate(income.length, (i) {
              return BarChartGroupData(
                x: i,
                barsSpace: 6,
                barRods: [
                  BarChartRodData(
                    toY: income[i],
                    color: Colors.green,
                    width: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  BarChartRodData(
                    toY: i < spending.length ? spending[i] : 0,
                    color: Colors.redAccent,
                    width: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    ],
  );
}
}