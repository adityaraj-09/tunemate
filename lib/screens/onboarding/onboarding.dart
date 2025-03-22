// lib/screens/onboarding/onboarding_screen.dart
// Updated version that uses the enhanced animations

import 'package:app/screens/sign_in_screen.dart';
import 'package:app/screens/splash.dart';
import 'package:app/widgets/auth_widgets.dart';
import 'package:app/widgets/common/animated_onboarding_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _pages = [
    {
      'image': 'assets/images/onboarding1.png',
      'title': 'Discover Music Matches',
      'description':
          'Connect with people who share your music taste and discover new artists together.',
      'color': const Color(0xFF6200EE),
      'icon': Icons.music_note,
    },
    {
      'image': 'assets/images/onboarding2.png',
      'title': 'Share Your Favorites',
      'description':
          'Create playlists, share songs, and see what others are listening to in real-time.',
      'color': const Color(0xFF9C27B0),
      'icon': Icons.playlist_play,
    },
    {
      'image': 'assets/images/onboarding3.png',
      'title': 'Find Your Harmony',
      'description':
          'Our matching algorithm connects you with your music soulmates for meaningful connections.',
      'color': const Color(0xFF2196F3),
      'icon': Icons.favorite,
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _isLastPage = page == _pages.length - 1;
    });
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _completeOnboarding() async {
    // Save that onboarding is completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);

    // Navigate to login screen
    if (mounted) {
      context.pushReplacement(
        "/login"
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: !_isLastPage
                      ? TextButton(
                          onPressed: _skipToEnd,
                          child: const Text('Skip'),
                          style: TextButton.styleFrom(
                            foregroundColor: _pages[_currentPage]['color'],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return EnhancedOnboardingPage(
                      image: page['image'],
                      title: page['title'],
                      description: page['description'],
                      imageSize: 160,
                      imageColor: page['color'],
                      iconData: page['icon'],
                    );
                  },
                ),
              ),

              // Page indicator
              Container(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    // Dots indicator
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: _pages.length,
                        effect: ExpandingDotsEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          spacing: 8,
                          expansionFactor: 4,
                          activeDotColor: _pages[_currentPage]['color'],
                          dotColor: Colors.grey.shade300,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Next button or Get Started button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: _isLastPage
                            ? Column(
                                children: [
                                  GradientButton(
                                      onPressed: _completeOnboarding,
                                      gradient: LinearGradient(
                                        colors: [
                                          _pages[_currentPage]['color'],
                                          _pages[_currentPage]['color']
                                              .withOpacity(0.7),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      text: "Get Started"),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Already have an account?'),
                                      TextButton(
                                        onPressed: () {
                                          context.go("/login");
                                        },
                                        child: Text(
                                          'Sign In',
                                          style: TextStyle(
                                            color: _pages[_currentPage]
                                                ['color'],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : SizedBox(
                                width: double.infinity,
                                child: GradientButton(
                                  onPressed: _nextPage,
                                  gradient: LinearGradient(
                                    colors: [
                                      _pages[_currentPage]['color'],
                                      _pages[_currentPage]['color']
                                          .withOpacity(0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  text: _isLastPage ? 'Get Started' : 'Next',
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
