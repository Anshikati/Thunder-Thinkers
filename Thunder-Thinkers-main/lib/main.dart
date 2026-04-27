import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'app_theme.dart';
import 'app_router.dart';
import 'providers/app_providers.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        builder: (context) {
          final router = buildRouter(context);

          return MaterialApp.router(
            title: 'NeedsBridge',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            routerConfig: router,
          );
        },
      ),
    );
  }
}