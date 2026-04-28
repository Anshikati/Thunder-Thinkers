import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/volunteer.dart';
import '../models/task.dart';

class FirebaseVolunteerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Volunteer>> fetchVolunteers() async {
    final snapshot = await _firestore.collection('users').where('role', isEqualTo: 'volunteer').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Volunteer.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  Future<List<Task>> fetchTasks({String? volunteerId, String? status}) async {
    Query<Map<String, dynamic>> query = _firestore.collection('tasks');
    if (volunteerId != null) {
      query = query.where('volunteerId', isEqualTo: volunteerId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Task.fromFirestore(doc.data(), doc.id)).toList();
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    final updates = <String, dynamic>{'status': status};
    if (status == 'completed') {
      updates['completedAt'] = Timestamp.now();
    }
    await _firestore.collection('tasks').doc(taskId).update(updates);

    if (status == 'completed') {
      try {
        final taskDoc = await _firestore.collection('tasks').doc(taskId).get();
        final volunteerId = taskDoc.data()?['volunteerId'] as String?;
        if (volunteerId != null) {
          await _firestore.collection('users').doc(volunteerId).update({
            'isAvailable': true,
          });
        }
      } catch (e) {
        print('Error updating volunteer status: $e');
      }
    }
  }
}
