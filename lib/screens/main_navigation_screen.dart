// lib/screens/main_navigation_screen.dart
import 'package:app/screens/home/home_screen.dart';
import 'package:app/screens/player/music_screen.dart';
import 'package:app/screens/profile_screen.dart';
import 'package:app/screens/search_screen.dart';
import 'package:app/widgets/miniplayer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/music_player_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = [
      MusicScreen(),
    SearchScreen(),
  
    Container(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;

    _animationController.reverse().then((_) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.jumpToPage(index);
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<MusicPlayerProvider>();
    final bool hasMiniplayer = playerProvider.isMiniPlayerVisible;

    print("miniplayer: $hasMiniplayer");

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _screens,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),

          // Mini player
          Positioned(
            left: 0,
            right: 0,
            bottom:0, // Adjust for bottom nav
            child: const MiniPlayer(),
          ),
        ],
      ),

      bottomNavigationBar: _buildBottomNavBar(),

      // Floating action button for quick match
      floatingActionButton: _currentIndex == 0 || _currentIndex == 2
          ? FloatingActionButton(
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.favorite),
              onPressed: () {
                // Show quick match dialog
                _showQuickMatchDialog();
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(
                  1, Icons.search, Icons.search, 'Music'),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(
                  2, Icons.chat_bubble_outline, Icons.chat_bubble, 'Matches'),
              _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData outlinedIcon, IconData filledIcon, String label) {
    final isSelected = _currentIndex == index;
    final iconColor = isSelected ? AppTheme.primaryColor : AppTheme.mutedGrey;
    final textColor = isSelected ? AppTheme.primaryColor : AppTheme.mutedGrey;
    final iconSize = isSelected ? 28.0 : 24.0;

    return InkWell(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: iconColor,
              size: iconSize,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickMatchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Quick Match',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Expanded(
              child: Center(
                child: Text('Quick match feature coming soon!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
