// lib/providers/expenses_provider.dart
import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';

class ExpensesProvider extends ChangeNotifier {
  final List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  late final FirestoreService _firestoreService;

  void setFirestoreService(FirestoreService service) {
    _firestoreService = service;
  }

  void loadExpenses(String userId) {
    // Listen to real-time updates from Firestore
    _firestoreService.streamExpenses(userId).listen((data) {
      _expenses
        ..clear()
        ..addAll(data);
      notifyListeners();
    });
  }

  Future<void> addExpense(Expense expense) async {
    await _firestoreService.addExpense(expense);
    // No need to manually update _expenses because streamExpenses will auto-update
  }

  Future<void> updateExpense(Expense expense) async {
    await _firestoreService.updateExpense(expense);
  }

  Future<void> deleteExpense(String expenseId) async {
    await _firestoreService.deleteExpense(expenseId);
  }
}
