// lib/services/di/service_locator.dart
import 'package:app/providers/music_player_provider.dart';
import 'package:app/services/api/music_api.dart';
import 'package:app/services/api/profile_api.dart';
import 'package:app/services/api/settings_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../providers/auth_provider.dart';
import '../api/auth_api.dart';
import '../storage/secure_storage.dart';

final getIt = GetIt.instance;

// Setup dependency injection
Future<void> setupDependencies() async {
  // Services
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://your-api-endpoint.com', // Replace with your API URL
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add logging interceptor in debug mode
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    
    return dio;
  });
  
  // Register storage and API services
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(getIt<FlutterSecureStorage>()),
  );
  
  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiService(getIt<Dio>()),
  );

    getIt.registerLazySingleton<MusicApiService>(() => MusicApiService(getIt<Dio>()));
    getIt.registerLazySingleton<ProfileApiService>(() => ProfileApiService(getIt<Dio>()));
    getIt.registerLazySingleton<SettingsApiService>(() => SettingsApiService(getIt<Dio>()));

  
  // Register providers
  getIt.registerLazySingleton<AuthProvider>(
    () => AuthProvider(
      getIt<AuthApiService>(),
      getIt<SecureStorageService>(),
    ),
  );

  getIt.registerLazySingleton<MusicPlayerProvider>(
    () => MusicPlayerProvider(
    
    ),
  );

}

// List of providers to be used with MultiProvider
List<SingleChildWidget> get providers {
  return [
    ChangeNotifierProvider<AuthProvider>(
      create: (_) => getIt<AuthProvider>(),
    ),  ChangeNotifierProvider<MusicPlayerProvider>(
      create: (_) => getIt<MusicPlayerProvider>(),
    ),
    // Add more providers here as needed
  ];
}