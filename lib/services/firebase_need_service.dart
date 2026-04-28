import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/need.dart';

class FirebaseNeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Need>> fetchNeeds({
    String? status,
    String? category,
    String? urgency,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('needs');

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (urgency != null) {
      query = query.where('urgencyLevel', isEqualTo: urgency);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final Map<String, dynamic> jsonData = {...data, 'id': doc.id};
      if (data['timestamp'] is Timestamp) {
        jsonData['timestamp'] =
            (data['timestamp'] as Timestamp).toDate().toIso8601String();
      }
      return Need.fromJson(jsonData);
    }).toList();
  }

  Future<Need?> submitNeed(Need need) async {
    try {
      final docRef = await _firestore.collection('needs').add(need.toJson());
      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;
      return Need.fromJson({...data, 'id': docRef.id});
    } catch (e) {
      print('Error submitting need: $e');
      return null;
    }
  }

  Future<Need?> assignVolunteer(String needId, String volunteerId) async {
    try {
      await _firestore.collection('needs').doc(needId).update({
        'assignedVolunteerId': volunteerId,
        'status': 'assigned',
      });
      final doc = await _firestore.collection('needs').doc(needId).get();
      final data = doc.data() as Map<String, dynamic>;
      final Map<String, dynamic> jsonData = {...data, 'id': doc.id};
      if (data['timestamp'] is Timestamp) {
        jsonData['timestamp'] =
            (data['timestamp'] as Timestamp).toDate().toIso8601String();
      }
      final need = Need.fromJson(jsonData);

      // Auto-create a Task for the volunteer
      final taskData = {
        'needId': need.id,
        'volunteerId': volunteerId,
        'status': 'assigned',
        'assignedAt': Timestamp.now(),
        'title': need.categoryLabel,
        'location': need.location,
        'category': need.category.name,
        'urgencyLevel': need.urgencyLabel,
        'skillsNeeded': '',
        'reportedBy': need.submittedBy,
        'peopleAffected': need.peopleAffected,
        'distanceKm': 0.0,
        'description': need.description,
      };
      await _firestore.collection('tasks').add(taskData);

      // Mark the volunteer as busy
      await _firestore.collection('users').doc(volunteerId).update({
        'isAvailable': false,
      });

      return need;
    } catch (e) {
      print('Error assigning volunteer: $e');
      return null;
    }
  }
}
