import 'package:flutter/material.dart';
import '../models/expenses.dart';
import '../services/db_service.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  Future<void> fetchExpenses() async {
    _expenses = await DBService().getExpenses();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await DBService().insertExpense(expense);
    await fetchExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await DBService().deleteExpense(id);
    await fetchExpenses();
  }
}
