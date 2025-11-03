// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Users Collection Reference
  CollectionReference<AppUser> get usersRef =>
      _db.collection('users').withConverter<AppUser>(
            fromFirestore: (snap, _) => AppUser.fromMap(snap.data()!),
            toFirestore: (user, _) => user.toMap(),
          );

  // Expenses Collection Reference
  CollectionReference<Expense> get expensesRef =>
      _db.collection('expenses').withConverter<Expense>(
            fromFirestore: (snap, _) => Expense.fromMap(snap.data()!),
            toFirestore: (expense, _) => expense.toMap(),
          );

  // ------------------ USER METHODS ------------------

  Future<void> createUser(AppUser user) async {
    await usersRef.doc(user.uid).set(user);
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await usersRef.doc(uid).get();
    return doc.data();
  }

  Future<void> updateUser(AppUser user) async {
    await usersRef.doc(user.uid).update(user.toMap());
  }

  // ------------------ EXPENSE METHODS ------------------

  Future<void> addExpense(Expense expense) async {
    await expensesRef.add(expense);
  }

  Future<void> updateExpense(Expense expense) async {
    await expensesRef.doc(expense.id).update(expense.toMap());
  }

  Future<void> deleteExpense(String id) async {
    await expensesRef.doc(id).delete();
  }

  Stream<List<Expense>> streamExpenses(String uid) {
    return expensesRef
        .where('userId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }
}
