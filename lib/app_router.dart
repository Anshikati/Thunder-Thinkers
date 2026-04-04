import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/app_user.dart';
import 'providers/app_providers.dart';

String dashboardRouteFor(UserRole role) {
  switch (role) {
    case UserRole.ngoAdmin: return '/admin';
    case UserRole.fieldWorker: return '/fieldworker';
    case UserRole.volunteer: return '/volunteer';
  }
}