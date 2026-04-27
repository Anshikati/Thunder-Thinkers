import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_providers.dart';
import '../../../models/app_user.dart';
import '../../../screens/common/splash_screen.dart';
import '../../../screens/common/login_screen.dart';
import '../../../screens/common/signup_screen.dart';
import '../../../screens/shared/profile_screen.dart';
import '../../../screens/shared/notifications_screen.dart';
import '../../../screens/shared/need_detail_screen.dart';
import '../../../screens/admin/admin_dashboard.dart';
import '../../../screens/admin/needs_map_screen.dart';
import '../../../screens/admin/volunteer_management_screen.dart';
import '../../../screens/field_worker/field_worker_dashboard.dart';
import '../../../screens/field_worker/report_need_screen.dart';
import '../../../screens/field_worker/voice_report_screen.dart';
import '../../../screens/field_worker/scan_form_screen.dart';
import '../../../screens/field_worker/my_reports_screen.dart';
import '../../../screens/volunteer/volunteer_dashboard.dart';
import '../../../screens/volunteer/task_list_screen.dart';
import '../../../screens/volunteer/volunteer_map_screen.dart';

GoRouter buildRouter(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  bool isAuthorized(String path, AppUser? user) {
    if (user == null) return path.startsWith('/splash') || path == '/login' || path == '/signup';
    
    final rolePaths = {
      UserRole.ngoAdmin: ['/admin'],
      UserRole.fieldWorker: ['/fieldworker'],
      UserRole.volunteer: ['/volunteer'],
    };
    
    final commonPaths = ['/profile', '/notifications', '/need'];
    
    final isCommon = commonPaths.any((p) => path.startsWith(p));
    final roleAllowed = rolePaths[user.role]?.any((p) => path.startsWith(p)) ?? false;
    
    return isCommon || roleAllowed;
  }

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final user = authProvider.currentUser;
      final path = state.fullPath ?? '/';
      
      if (!isAuthorized(path, user)) {
        return user == null ? '/login' : dashboardRouteFor(user!.role);
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      
      // Common
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/need/:id',
        builder: (context, state) => NeedDetailScreen(needId: state.pathParameters['id']!),
      ),
      
      // NGO Admin
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
      
      // Field Worker
      GoRoute(
        path: '/fieldworker',
        builder: (context, state) => const FieldWorkerDashboard(),
      ),
      
      // Volunteer
      GoRoute(
        path: '/volunteer',
        builder: (context, state) => const VolunteerDashboard(),
      ),
      GoRoute(
        path: '/volunteer/tasks',
        builder: (context, state) => const TaskListScreen(),
      ),
      GoRoute(
        path: '/volunteer/map',
        builder: (context, state) => const VolunteerMapScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}

String dashboardRouteFor(UserRole role) {
  switch (role) {
    case UserRole.ngoAdmin: return '/admin';
    case UserRole.fieldWorker: return '/fieldworker';
    case UserRole.volunteer: return '/volunteer';
  }
}

