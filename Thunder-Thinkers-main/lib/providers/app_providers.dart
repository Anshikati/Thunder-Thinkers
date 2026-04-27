import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../models/need.dart';
import '../models/volunteer.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_need_service.dart';
import '../services/firebase_volunteer_service.dart';

const bool useFirebase = false;


// AuthProvider


class AuthProvider extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _errorMessage;
  Future<bool> login(String email, String password, UserRole role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (useFirebase) {
        _currentUser = await FirebaseAuthService().login(
          email: email,
          password: password,
          role: role,
        );
      } else {
        _currentUser = await ApiService.login(
          email: email,
          password: password,
          role: role,
        );
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (useFirebase) {
        _currentUser = await FirebaseAuthService().register(
          name: name,
          email: email,
          phone: phone,
          password: password,
          role: role,
        );
      } else {
        _currentUser = await ApiService.register(
          name: name,
          email: email,
          phone: phone,
          password: password,
          role: role,
        );
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> logout() async {
    try {
      if (useFirebase) {
        await FirebaseAuthService().logout();
      } else {
        await ApiService.logout();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    _currentUser = null;
    notifyListeners();
  }
}


// NeedsProvider


class NeedsProvider extends ChangeNotifier {
  List<Need> _needs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Need> get needs => _needs;
  bool get isLoading => _isLoading;
  String? get error => _errorMessage;

  List<Need> get criticalNeeds =>
      _needs.where((n) => n.urgencyLevel == UrgencyLevel.critical).toList();

  int get totalCount => _needs.length;
  int get pendingCount => _needs.where((n) => n.status == NeedStatus.reported).length;
  int get inProgressCount => _needs.where((n) => n.status == NeedStatus.inProgress).length;
  int get completedCount => _needs.where((n) => n.status == NeedStatus.completed).length;

  List<Need> needsByFieldWorker(String fieldWorkerId) =>
      _needs.where((n) => n.submittedBy == fieldWorkerId).toList();
  Future<void> loadNeeds({String? status, String? category, String? urgency}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (useFirebase) {
        _needs = await FirebaseNeedService().fetchNeeds(
          status: status,
          category: category,
          urgency: urgency,
        );
      } else {
        _needs = await ApiService.fetchNeeds(
          status: status,
          category: category,
          urgency: urgency,
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> submitNeed(Need need) async {
    try {
      if (useFirebase) {
        final created = await FirebaseNeedService().submitNeed(need);
        if (created != null) _needs = [created, ..._needs];
      } else {
        final created = await ApiService.submitNeed(need);
        _needs = [created, ..._needs];
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  Future<void> assignVolunteer(String needId, String volunteerId) async {
    try {
      if (useFirebase) {
        final updated = await FirebaseNeedService().assignVolunteer(needId, volunteerId);
        if (updated != null) _needs = _needs.map((n) => n.id == needId ? updated : n).toList();
      } else {
        final updated = await ApiService.assignVolunteer(needId, volunteerId);
        _needs = _needs.map((n) => n.id == needId ? updated : n).toList();
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}

// VolunteerProvider

class VolunteerProvider extends ChangeNotifier {
  List<Volunteer> _volunteers = [];
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Volunteer> get volunteers => _volunteers;
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _errorMessage;

  List<Volunteer> get availableVolunteers =>
      _volunteers.where((v) => v.isAvailable).toList();

  List<Task> get newTasks => _tasks.where((t) => t.status == 'new').toList();
  List<Task> get activeTasks =>
      _tasks.where((t) => t.status == 'assigned' || t.status == 'inProgress').toList();
  List<Task> get completedTasks => _tasks.where((t) => t.status == 'completed').toList();

  Task? activeTaskFor(String volunteerId) {
    try {
      return _tasks.firstWhere(
        (t) =>
            t.volunteerId == volunteerId &&
            (t.status == 'assigned' || t.status == 'inProgress'),
      );
    } catch (_) {
      return null;
    }
  }
  Future<void> loadVolunteers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (useFirebase) {
        _volunteers = await FirebaseVolunteerService().fetchVolunteers();
      } else {
        _volunteers = await ApiService.fetchVolunteers();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> loadTasks({String? volunteerId, String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (useFirebase) {
        // Not stubbed in FirebaseVolunteerService, placeholder for now
        _tasks = _tasks;
      } else {
        _tasks = await ApiService.fetchTasks(
          volunteerId: volunteerId,
          status: status,
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      if (useFirebase) {
        await FirebaseVolunteerService().updateTaskStatus(taskId, newStatus);
      } else {
        final updated = await ApiService.updateTaskStatus(taskId, newStatus);
        _tasks = _tasks.map((t) => t.id == taskId ? updated : t).toList();
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  static VolunteerProvider of(BuildContext context) =>
      Provider.of<VolunteerProvider>(context, listen: false);
}
