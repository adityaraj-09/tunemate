import 'package:app/routes/router.dart';
import 'package:app/screens/sign_in_screen.dart';
import 'package:app/screens/signup_screen.dart';
import 'package:app/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/auth_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
    final goRouter = appRouter.getRouter();
    return MaterialApp.router(
      title: 'TuneMate',
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
      
      debugShowCheckedModeBanner: false,
    );
  }
}
