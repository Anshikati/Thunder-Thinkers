import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/volunteer.dart';

class FirebaseVolunteerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Volunteer>> fetchVolunteers() async {
    final snapshot = await _firestore.collection('users').where('role', isEqualTo: 'volunteer').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Volunteer.fromJson({...data, 'id': doc.id});
    }).toList();
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
