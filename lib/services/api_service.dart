/// Note: TEMPORARILY MOCKED to allow UI testing since real API is not deployed
import 'dart:async';
import '../data/mock_data.dart';
import '../models/app_user.dart';
import '../models/need.dart';
import '../models/volunteer.dart';
import '../models/task.dart';

class ApiService {
  ApiService._();

  static String? _token;

  static void setToken(String token) => _token = token;
  static void clearToken() => _token = null;

  static Future<AppUser> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    setToken('mock-jwt-token');
    return mockUsers.firstWhere((u) => u.role == role, orElse: () => mockUsers.first);
  }

  static Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    setToken('mock-jwt-token');
    return mockUsers.firstWhere((u) => u.role == role, orElse: () => mockUsers.first);
  }

  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    clearToken();
  }

  static Future<List<Need>> fetchNeeds({
    String? status,
    String? category,
    String? urgency,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(mockNeeds);
  }

  static Future<Need> fetchNeedById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return mockNeeds.firstWhere((n) => n.id == id, orElse: () => mockNeeds.first);
  }

  static Future<Need> submitNeed(Need need) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return need;
  }

  static Future<Need> assignVolunteer(String needId, String volunteerId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final need = mockNeeds.firstWhere((n) => n.id == needId, orElse: () => mockNeeds.first);
    return need;
  }

  static Future<List<Need>> fetchNearbyNeeds(
    double lat,
    double lng, {
    double radiusKm = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(mockNeeds);
  }

  static Future<List<Volunteer>> fetchVolunteers() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(mockVolunteers);
  }

  static Future<Volunteer> fetchVolunteerById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return mockVolunteers.firstWhere((v) => v.id == id, orElse: () => mockVolunteers.first);
  }

  static Future<List<Task>> fetchTasks({
    String? volunteerId,
    String? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(mockTasks);
  }

  static Future<Task> updateTaskStatus(String taskId, String status) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return mockTasks.firstWhere((t) => t.id == taskId, orElse: () => mockTasks.first);
  }

  static Future<List<Map<String, dynamic>>> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(mockNotifications);
  }

  static Future<void> markAllNotificationsRead() async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  static Future<void> sendNotification(String volunteerId, String message) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  static Future<double> getUrgencyScore(String description) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return 7.5;
  }

  static Future<String> transcribeVoice(String filePath) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return "This is a mocked transcription from api_service.dart.";
  }

  static Future<Map<String, dynamic>> scanForm(String filePath) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return {
      "location": "Mocked Location, Mumbai",
      "description": "Mocked description extracted from image",
      "peopleAffected": 50,
      "category": "Food"
    };
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
