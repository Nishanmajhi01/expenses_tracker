import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expenses.dart';
import '../providers/expense_provider.dart';

class ExpenseItem extends StatelessWidget {
  final Expense expense;
  const ExpenseItem({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        title: Text(expense.title),
        subtitle: Text(
            "${expense.category} • ${DateFormat.yMMMd().format(expense.date)}"),
        trailing: Text("\$${expense.amount.toStringAsFixed(2)}"),
        onLongPress: () {
          context.read<ExpenseProvider>().deleteExpense(expense.id!);
        },
      ),
    );
  }
}
