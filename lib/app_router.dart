import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/app_user.dart';
import 'providers/app_providers.dart';

import 'screens/common/splash_screen.dart';
import 'screens/common/login_screen.dart';
import 'screens/common/signup_screen.dart';

import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/needs_map_screen.dart';
import 'screens/admin/volunteer_management_screen.dart';
import 'screens/admin/add_need_screen.dart';

import 'screens/field_worker/field_worker_dashboard.dart';
import 'screens/field_worker/report_need_screen.dart';
import 'screens/field_worker/voice_report_screen.dart';
import 'screens/field_worker/scan_form_screen.dart';
import 'screens/field_worker/my_reports_screen.dart';

import 'screens/volunteer/volunteer_dashboard.dart';
import 'screens/volunteer/task_list_screen.dart';
import 'screens/volunteer/task_detail_screen.dart';
import 'screens/volunteer/volunteer_map_screen.dart';

import 'screens/shared/profile_screen.dart';
import 'screens/shared/notifications_screen.dart';
import 'screens/shared/need_detail_screen.dart';

GoRouter buildRouter(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  bool isAuthorized(String path, AppUser? user) {
    if (user == null) {
      return path.startsWith('/splash') ||
          path == '/login' ||
          path == '/signup';
    }

    final rolePaths = {
      UserRole.ngoAdmin: ['/admin', '/fieldworker'],
      UserRole.fieldWorker: ['/fieldworker'],
      UserRole.volunteer: ['/volunteer', '/fieldworker'],
    };

    final commonPaths = ['/profile', '/notifications', '/need'];

    final isCommon = commonPaths.any((p) => path.startsWith(p));
    final roleAllowed =
        rolePaths[user.role]?.any((p) => path.startsWith(p)) ?? false;

    return isCommon || roleAllowed;
  }

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final user = authProvider.currentUser;
      final path = state.fullPath ?? '/';

      if (!isAuthorized(path, user)) {
        return user == null ? '/login' : dashboardRouteFor(user.role);
      }
      return null;
    },
    routes: [
      // Auth / Common
      GoRoute(
          path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
          path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: '/signup', builder: (_, __) => const SignupScreen()),

      // Shared
      GoRoute(
          path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(
          path: '/notifications',
          builder: (_, __) => const NotificationsScreen()),
      GoRoute(
        path: '/need/:id',
        builder: (_, state) =>
            NeedDetailScreen(needId: state.pathParameters['id']!),
      ),

      // NGO Admin
      GoRoute(
          path: '/admin', builder: (_, __) => const AdminDashboard()),
      GoRoute(
          path: '/admin/map',
          builder: (_, __) => const NeedsMapScreen()),
      GoRoute(
          path: '/admin/volunteers',
          builder: (_, __) => const VolunteerManagementScreen()),
      GoRoute(
        path: '/admin/need/:id',
        builder: (_, state) =>
            NeedDetailScreen(needId: state.pathParameters['id']!),
      ),
      GoRoute(
          path: '/admin/add-need',
          builder: (_, __) => const AddNeedScreen()),

      // Field Worker
      GoRoute(
          path: '/fieldworker',
          builder: (_, __) => const FieldWorkerDashboard()),
      GoRoute(
          path: '/fieldworker/report',
          builder: (_, __) => const ReportNeedScreen()),
      GoRoute(
          path: '/fieldworker/voice',
          builder: (_, __) => const VoiceReportScreen()),
      GoRoute(
          path: '/fieldworker/scan',
          builder: (_, __) => const ScanFormScreen()),
      GoRoute(
          path: '/fieldworker/myreports',
          builder: (_, __) => const MyReportsScreen()),

      // Volunteer
      GoRoute(
          path: '/volunteer',
          builder: (_, __) => const VolunteerDashboard()),
      GoRoute(
          path: '/volunteer/tasks',
          builder: (_, __) => const TaskListScreen()),
      GoRoute(
        path: '/volunteer/tasks/:id',
        builder: (_, state) =>
            TaskDetailScreen(taskId: state.pathParameters['id']!),
      ),
      GoRoute(
          path: '/volunteer/map',
          builder: (_, __) => const VolunteerMapScreen()),
    ],
    errorBuilder: (_, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}

String dashboardRouteFor(UserRole role) {
  switch (role) {
    case UserRole.ngoAdmin:
      return '/admin';
    case UserRole.fieldWorker:
      return '/fieldworker';
    case UserRole.volunteer:
      return '/volunteer';
  }
}
