import '../models/volunteer.dart';

class FirebaseVolunteerService {
  Future<List<Volunteer>> fetchVolunteers() async {
    // Query volunteers collection. Inject doc.id as id field.
    // Convert any Timestamp fields to ISO string before
    // calling Volunteer.fromJson()
    return [];
  }

  Future<void> updateTaskStatus(
    String taskId,
    String status,
  ) async {
    // Update doc in tasks collection where id == taskId
    // with new status string. If status == completed,
    // also set completedAt to Timestamp.now()
  }
}
