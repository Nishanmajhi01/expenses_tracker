import 'package:flutter/material.dart';

class StatsProvider extends ChangeNotifier {
  double totalIncome = 0;
  double totalSpending = 0;

  void updateStats(double income, double spending) {
    totalIncome = income;
    totalSpending = spending;
    notifyListeners();
  }
}