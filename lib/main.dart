import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase not configured yet');
  }
  runApp(const NeedsBridgeApp());
}

class NeedsBridgeApp extends StatelessWidget {
  const NeedsBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NeedsProvider()),
        ChangeNotifierProvider(create: (_) => VolunteerProvider()),
      ],
      child: Builder(
        builder: (context) => MaterialApp.router(
          title: 'NeedsBridge',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          routerConfig: _buildRouterWithProviders(context),
        ),
      ),
    );
  }

  GoRouter _buildRouterWithProviders(BuildContext context) {
    return buildRouter(context);
  }
}

