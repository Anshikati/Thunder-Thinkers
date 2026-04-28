import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Task>> fetchTasks() async {
    final snapshot = await _db.collection('tasks').get();

    return snapshot.docs.map((doc) {
      return Task.fromFirestore(doc.data(), doc.id);
    }).toList();
  }
}