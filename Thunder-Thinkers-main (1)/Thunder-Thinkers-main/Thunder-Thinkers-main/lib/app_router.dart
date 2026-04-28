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

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final loggedIn = authProvider.isLoggedIn;
      final atAuth = state.fullPath == '/login' || state.fullPath == '/signup' || state.fullPath == '/splash';
      if (!loggedIn && !atAuth) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),

      GoRoute(path: '/admin', builder: (_, __) => const AdminDashboard()),
      GoRoute(path: '/admin/map', builder: (_, __) => const NeedsMapScreen()),
      GoRoute(path: '/admin/volunteers', builder: (_, __) => const VolunteerManagementScreen()),
      GoRoute(
        path: '/admin/need/:id',
        builder: (_, state) => NeedDetailScreen(needId: state.pathParameters['id']!),
      ),

      GoRoute(path: '/fieldworker', builder: (_, __) => const FieldWorkerDashboard()),
      GoRoute(path: '/fieldworker/report', builder: (_, __) => const ReportNeedScreen()),
      GoRoute(path: '/fieldworker/voice', builder: (_, __) => const VoiceReportScreen()),
      GoRoute(path: '/fieldworker/scan', builder: (_, __) => const ScanFormScreen()),
      GoRoute(path: '/fieldworker/myreports', builder: (_, __) => const MyReportsScreen()),

      GoRoute(path: '/volunteer', builder: (_, __) => const VolunteerDashboard()),
      GoRoute(path: '/volunteer/tasks', builder: (_, __) => const TaskListScreen()),
      GoRoute(
        path: '/volunteer/tasks/:id',
        builder: (_, state) => TaskDetailScreen(taskId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/volunteer/map', builder: (_, __) => const VolunteerMapScreen()),

      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
    ],
    errorBuilder: (_, state) => Scaffold(
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