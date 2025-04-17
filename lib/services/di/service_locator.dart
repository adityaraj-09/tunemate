// lib/services/di/service_locator.dart
import 'package:app/providers/loc_provider.dart';
import 'package:app/providers/music_player_provider.dart';
import 'package:app/providers/music_provider.dart';
import 'package:app/providers/pref_provider.dart';
import 'package:app/providers/preference_provider.dart';
import 'package:app/services/api/location_api.dart';
import 'package:app/services/api/music_api.dart';
import 'package:app/services/api/playlist_api.dart';
import 'package:app/services/api/preference_api.dart';
import 'package:app/services/api/profile_api.dart';
import 'package:app/services/api/settings_api.dart';
import 'package:app/services/api/user_pref.dart';
import 'package:app/services/music/audio_player_service.dart';
import 'package:app/services/music/background_player.dart';
import 'package:app/services/search_history.dart';
import 'package:app/utils/constant.dart';
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

  getIt.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());

  getIt.registerLazySingleton<Dio>(() {
    var token;
    getIt<SecureStorageService>().getToken().then((value) => token = value);
    print("token: $token");
    final dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl, // Replace with your API URL
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          "authorization": "Bearer ${token}"
        },
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get the token dynamically for each request
          final token = await getIt<SecureStorageService>().getToken();
          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // If the error is 401 (Unauthorized), try to refresh the token
          if (error.response?.statusCode == 401) {
            try {
              print("Received 401, attempting to refresh token...");

              // Get the auth provider
              final authProvider = getIt<AuthProvider>();

              // Try to refresh the token
              final refreshResult = await authProvider.refreshToken();

              if (refreshResult) {
                print("Token refreshed successfully, retrying request");

                // Get the new token
                final newToken = await getIt<SecureStorageService>().getToken();

                // Clone the original request with the new token
                final options = error.requestOptions;
                options.headers["Authorization"] = "Bearer $newToken";

                // Create a new request with the updated token
                final response = await dio.fetch(options);

                // Return the new response
                return handler.resolve(response);
              } else {
                print("Failed to refresh token, proceeding with error");
                // If refresh failed, continue with the original error
                return handler.next(error);
              }
            } catch (e) {
              print("Error during token refresh: $e");

              // If there was an error during refresh, we need to handle it
              // This might mean forcing a logout if refresh fails
              final authProvider = getIt<AuthProvider>();
              authProvider.signOut();

              // Continue with the original error
              return handler.next(error);
            }
          }

          // For other errors, just continue with the error
          return handler.next(error);
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

  getIt.registerLazySingleton<LocationApiService>(
    () => LocationApiService(getIt<Dio>()),
  );

  final audioHandlerService = AudioHandlerService();
  await audioHandlerService.init(); // Initialize it before registration

  getIt.registerSingleton<AudioHandlerService>(audioHandlerService);

  getIt.registerLazySingleton<AudioPlayerService>(
    () => AudioPlayerService(getIt<AudioHandlerService>()),
  );
  getIt.registerLazySingleton<SearchHistoryService>(
    () => SearchHistoryService(),
  );

  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<MusicApiService>(
      () => MusicApiService(getIt<Dio>()));
  getIt.registerLazySingleton<PlaylistApiService>(
      () => PlaylistApiService(getIt<Dio>()));
  getIt.registerLazySingleton<ProfileApiService>(
      () => ProfileApiService(getIt<Dio>()));
  getIt.registerLazySingleton<SettingsApiService>(
      () => SettingsApiService(getIt<Dio>()));
getIt.registerLazySingleton<UserPreferenceService>(
    () => UserPreferenceService(getIt<Dio>()),
  );
  // Register providers
  getIt.registerLazySingleton<AuthProvider>(
    () => AuthProvider(
      getIt<AuthApiService>(),
      getIt<SecureStorageService>(),
    ),
  );

  getIt.registerLazySingleton<MusicPlayerProvider>(
    () => MusicPlayerProvider(),
  );
  getIt.registerLazySingleton<MusicProvider>(
    () => MusicProvider(),
  );


  getIt.registerLazySingleton<LocationProvider>(() => LocationProvider(
  locationService:   getIt<LocationApiService>()
  ));

  getIt.registerLazySingleton( () => MusicPreferencesProvider(
  
     getIt<PreferenceApiService>(),
  ));

  getIt.registerLazySingleton<UserPreferenceProvider>(
    () => UserPreferenceProvider(
      preferenceService:  getIt<UserPreferenceService>(),
    ),
  );
}

// List of providers to be used with MultiProvider
List<SingleChildWidget> get providers {
  return [
    ChangeNotifierProvider<AuthProvider>(
      create: (_) => getIt<AuthProvider>(),
    ),
    ChangeNotifierProvider<MusicPlayerProvider>(
      create: (_) => getIt<MusicPlayerProvider>(),
    ),
    ChangeNotifierProvider<MusicPreferencesProvider>(
      create: (_) => getIt<MusicPreferencesProvider>(),
    ),
    ChangeNotifierProvider<MusicProvider>(
        create: (_) => getIt<MusicProvider>()),

    ChangeNotifierProvider<LocationProvider>(
        create: (_) => getIt<LocationProvider>()),
    ChangeNotifierProvider<UserPreferenceProvider>(
        create: (_) => getIt<UserPreferenceProvider>()),

    // Add more providers here as needed
  ];
}
