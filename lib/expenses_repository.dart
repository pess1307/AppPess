import 'package:cloud_firestore/cloud_firestore.dart';

class ExpensesRepository {
  final String userId;

  ExpensesRepository(this.userId);

  Stream<QuerySnapshot> queryByCategory(int month, String categoryName) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .where("month", isEqualTo: month)
        .where("category", isEqualTo: categoryName)
        .snapshots();
  }

  Stream<QuerySnapshot> queryByMonth(int month) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .where("month", isEqualTo: month)
        .snapshots();
  }

  delete(String documentId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(documentId)
        .delete();
  }

  add(String categoryName, double value, DateTime date) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc()
        .set({
      "category": categoryName,
      "value": value,
      "month": date.month,
      "day": date.day,
      "year": date.year
    });
  }
}
