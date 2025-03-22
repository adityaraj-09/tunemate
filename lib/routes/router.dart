// lib/routes/app_router.dart
import 'package:app/screens/edit_profile.dart';
import 'package:app/screens/listening_history.dart';
import 'package:app/screens/onboarding/onboarding.dart';
import 'package:app/screens/player/full_player_screen.dart';
import 'package:app/screens/privacy_screen.dart';
import 'package:app/screens/search_screen.dart';
import 'package:app/screens/settings_screen.dart';
import 'package:app/screens/sign_in_screen.dart';
import 'package:app/screens/signup_screen.dart';
import 'package:app/screens/splash.dart';
import 'package:app/services/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/music_player_provider.dart';
import '../screens/main_navigation_screen.dart';


class SearchPageParams {
  final String query;
  final String? genreFilter;

  SearchPageParams({
    required this.query,
    this.genreFilter,
  });
}

class AppRouter {
  final authProvider =getIt<AuthProvider>();

  // Runs the authentication middleware
  String? _runAuthMiddleware(BuildContext context, GoRouterState state) {
    final authProvider =getIt<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;

    if (!isAuthenticated) {
      // Don't redirect if we're already going to the login page
      if (state.name == '/login' || state.name == '/register') {
        return null;
      }
      return '/login';
    }
    
    return null;
  }

  GoRouter getRouter() {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        // Handle global redirects
        // For example, redirect to onboarding on first launch
        return null;
      },
      refreshListenable: authProvider, // Refresh routes when auth state changes
      routes: [
        // Splash screen
        GoRoute(
          path: '/splash',
          builder: (context, state) {
            return const SplashScreen();
          },
        ),  GoRoute(
          path: '/onboarding',
          builder: (context, state) {
            return const OnboardingScreen();
          },
        ),

        // Auth routes
        GoRoute(
          path: '/login',
          builder: (context, state) {
            return ChangeNotifierProvider.value(
              value: authProvider,
              child: const SignInScreen(),
            );
          },
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) {
            return ChangeNotifierProvider.value(
              value: authProvider,
              child: const SignUpScreen(),
            );
          },
        ),

        // Main app (authenticated) routes
        GoRoute(
          path: '/',
          redirect: _runAuthMiddleware,
          builder: (context, state) {
            final musicPlayerProvider =getIt<MusicPlayerProvider>();
            
            return MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: authProvider),
                ChangeNotifierProvider.value(value: musicPlayerProvider),
                
              ],
              child: const MainNavigationScreen(),
            );
          },
          routes: [
            // Search route
            GoRoute(
              path: 'search',
              builder: (context, state) {
                final params = state.extra as SearchPageParams?;
                return const SearchScreen();
              },
            ),
            
            // Profile routes
            GoRoute(
              path: 'settings',
              builder: (context, state) {
                return const SettingsScreen();
              },
            ),  GoRoute(
              path: 'full-player',
              builder: (context, state) {
                return const FullPlayerScreen();
              },
            ),
            GoRoute(
              path: 'edit-profile',
              builder: (context, state) {
                return const EditProfileScreen();
              },
            ),
            GoRoute(
              path: 'favorites',
              builder: (context, state) {
                return const FavoriteSongsScreen();
              },
            ),
            GoRoute(
              path: 'history',
              builder: (context, state) {
                return const ListeningHistoryScreen();
              },
            ),
            GoRoute(
              path: 'privacy',
              builder: (context, state) {
                return const PrivacySettingsScreen();
              },
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Route not found: ${state.name}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}