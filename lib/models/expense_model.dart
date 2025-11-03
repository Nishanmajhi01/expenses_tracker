class Expense {
  String id;
  String title;
  double amount;
  DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
  });

  // Convert Expense object to Map (for Firestore storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  // Convert Map from Firestore to Expense object
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
    );
  }
}
