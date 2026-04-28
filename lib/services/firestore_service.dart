import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../models/need.dart';
import '../models/volunteer.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch all tasks from Firestore
  Future<List<Task>> fetchTasks({String? volunteerId, String? status}) async {
    Query<Map<String, dynamic>> query = _db.collection('tasks');

    if (volunteerId != null) {
      query = query.where('volunteerId', isEqualTo: volunteerId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      return Task.fromFirestore(doc.data(), doc.id);
    }).toList();
  }

  /// Fetch all needs from Firestore with optional filters
  Future<List<Need>> fetchNeeds({
    String? status,
    String? category,
    String? urgency,
  }) async {
    Query<Map<String, dynamic>> query = _db.collection('needs');

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
      // Handle Firestore Timestamps
      final Map<String, dynamic> jsonData = {...data, 'id': doc.id};
      if (data['timestamp'] is Timestamp) {
        jsonData['timestamp'] =
            (data['timestamp'] as Timestamp).toDate().toIso8601String();
      }
      return Need.fromJson(jsonData);
    }).toList();
  }

  /// Fetch all volunteers from Firestore
  Future<List<Volunteer>> fetchVolunteers() async {
    final snapshot = await _db.collection('users').where('role', isEqualTo: 'volunteer').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Volunteer.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  /// Submit a new need document
  Future<Need?> submitNeed(Need need) async {
    try {
      final docRef = await _db.collection('needs').add(need.toJson());
      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;
      return Need.fromJson({...data, 'id': docRef.id});
    } catch (e) {
      debugPrint('Error submitting need: $e');
      return null;
    }
  }

  /// Assign a volunteer to a need AND auto-create a Task for them
  Future<Need?> assignVolunteer(String needId, String volunteerId) async {
    try {
      await _db.collection('needs').doc(needId).update({
        'assignedVolunteerId': volunteerId,
        'status': 'assigned',
      });
      final doc = await _db.collection('needs').doc(needId).get();
      final data = doc.data() as Map<String, dynamic>;
      // Handle Firestore Timestamps
      final Map<String, dynamic> jsonData = {...data, 'id': doc.id};
      if (data['timestamp'] is Timestamp) {
        jsonData['timestamp'] =
            (data['timestamp'] as Timestamp).toDate().toIso8601String();
      }
      final need = Need.fromJson(jsonData);

      // Auto-create a Task for the volunteer
      await createTaskFromNeed(need, volunteerId);

      // Mark the volunteer as busy
      await _db.collection('users').doc(volunteerId).update({
        'isAvailable': false,
      });

      return need;
    } catch (e) {
      debugPrint('Error assigning volunteer: $e');
      return null;
    }
  }

  /// Create a Task document in Firestore from a Need
  Future<Task?> createTaskFromNeed(Need need, String volunteerId) async {
    try {
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
      final docRef = await _db.collection('tasks').add(taskData);
      return Task.fromFirestore(taskData, docRef.id);
    } catch (e) {
      debugPrint('Error creating task: $e');
      return null;
    }
  }

  /// Update task status
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    final updates = <String, dynamic>{'status': newStatus};
    if (newStatus == 'completed') {
      updates['completedAt'] = Timestamp.now();
    }
    await _db.collection('tasks').doc(taskId).update(updates);

    if (newStatus == 'completed') {
      try {
        final taskDoc = await _db.collection('tasks').doc(taskId).get();
        final volunteerId = taskDoc.data()?['volunteerId'] as String?;
        if (volunteerId != null) {
          await _db.collection('users').doc(volunteerId).update({
            'isAvailable': true,
          });
        }
      } catch (e) {
        debugPrint('Error updating volunteer status: $e');
      }
    }
  }
}
