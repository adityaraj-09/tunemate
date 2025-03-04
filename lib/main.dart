// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'services/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Setup dependency injection
  await setupDependencies();
  
  runApp(
    MultiProvider(
      providers: providers,
      child: const MyApp(),
    ),
  );
}

// lib/app/app.dart


