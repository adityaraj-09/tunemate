// lib/screens/profile/profile_screen.dart
import 'package:app/models/music/models.dart';
import 'package:app/screens/edit_profile.dart';
import 'package:app/screens/listening_history.dart';
import 'package:app/screens/settings_screen.dart';
import 'package:app/widgets/auth_widgets.dart';
import 'package:app/widgets/home_widgets.dart';
import 'package:app/widgets/profile_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/music_player_provider.dart';
import '../../services/api/profile_api.dart';
import '../../models/auth/user.dart';
import '../../models/music/song.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  User? _user;
  MusicTaste? _musicTaste;
  List<dynamic> _favoriteSongs = [];
  
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _scrollController.addListener(_onScroll);
    
    _loadProfileData();
    _animationController.forward();
  }
  
  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final profileApi = Provider.of<ProfileApiService>(context, listen: false);
      
      // Get cached user from auth provider
      _user = authProvider.currentUser;
      
      // Fetch data in parallel
      final results = await Future.wait([
        profileApi.getMusicTaste(),
        profileApi.getFavoriteSongs(limit: 5),
      ]);
      
      if (mounted) {
        setState(() {
          _musicTaste = results[0] as MusicTaste;
          _favoriteSongs = results[1] as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }
  
  void _playSong(Song song) {
    final playerProvider = Provider.of<MusicPlayerProvider>(context, listen: false);
    playerProvider.playSong(song);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    if (_isLoading && _user == null) {
      return const Scaffold(
        body: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }
    
    final user = _user!;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.4,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.purpleBlueGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          
          // Profile content
          SafeArea(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: child,
                  ),
                );
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Profile header
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 32.0,
                      ),
                      child: Column(
                        children: [
                          // Avatar
                          Hero(
                            tag: 'profile-avatar',
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage: user.profilePictureUrl != null
                                    ? NetworkImage(user.profilePictureUrl!)
                                    : null,
                                child: user.profilePictureUrl == null
                                    ? Text(
                                        _getInitials(user),
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          color: AppTheme.primaryColor,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // User name
                          Text(
                            _getUserDisplayName(user),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Username
                          Text(
                            '@${user.username}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Stats row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ProfileStat(
                                title: 'Matches',
                                value: '32',
                                icon: Icons.favorite,
                                color: Colors.white,
                                light: true,
                              ),
                              ProfileStat(
                                title: 'Songs',
                                value: '145',
                                icon: Icons.music_note,
                                color: Colors.white,
                                light: true,
                              ),
                              ProfileStat(
                                title: 'Playlists',
                                value: '7',
                                icon: Icons.playlist_play,
                                color: Colors.white,
                                light: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Main content
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: AnimationLimiter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 500),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              horizontalOffset: 50.0,
                              child: FadeInAnimation(
                                child: widget,
                              ),
                            ),
                            children: [
                              // Edit profile button
                              GradientButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                                  );
                                },
                                text:"Edit Profile",
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // About me
                              Text(
                                'About Me',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              Text(
                                user.bio ?? 'No bio yet. Tell others about yourself and your music taste!',
                                style: theme.textTheme.bodyLarge,
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Music taste
                              Text(
                                'My Music Taste',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Genre chart
                              _isLoading || _musicTaste == null
                                ? const ShimmerLoading(height: 220)
                                : SizedBox(
                                    height: 220,
                                    child: MusicTasteChart(musicTaste: _musicTaste!),
                                  ),
                              
                              const SizedBox(height: 32),
                              
                              // Favorite songs
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Favorite Songs',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const FavoriteSongsScreen()),
                                      );
                                    },
                                    child: const Text('See All'),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Favorites list (preview)
                              _buildFavoriteSongsPreview(),
                              
                              const SizedBox(height: 32),
                              
                              // Listening history
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recent Activity',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const ListeningHistoryScreen()),
                                      );
                                    },
                                    child: const Text('See All'),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Activity list
                              _buildRecentActivityList(),
                              
                              // Settings button
                              const SizedBox(height: 32),
                              
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                  );
                                },
                                icon: const Icon(Icons.settings),
                                label: const Text('Settings'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                              ),
                              
                              // Space at bottom for mini player
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFavoriteSongsPreview() {
    if (_isLoading) {
      return Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ShimmerLoading(
              height: 70,
              borderRadius: 12,
            ),
          ),
        ),
      );
    }
    
    if (_favoriteSongs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.lightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'You haven\'t liked any songs yet. Start exploring!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.mutedGrey,
            ),
          ),
        ),
      );
    }
    
    return Column(
      children: _favoriteSongs.map((song) {
        return FavoriteSongTile(
          song: Song.fromJson(song),
          onTap: () => _playSong(Song.fromJson(song)),
        );
      }).toList(),
    );
  }
  
  Widget _buildRecentActivityList() {
    // Placeholder for recent activity
    if (_isLoading) {
      return Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ShimmerLoading(
              height: 70,
              borderRadius: 12,
            ),
          ),
        ),
      );
    }
    
    // Dummy activity items
    final activities = [
      {
        'type': 'listened',
        'song': 'Shape of You',
        'artist': 'Ed Sheeran',
        'time': '2 hours ago'
      },
      {
        'type': 'matched',
        'name': 'Alex Johnson',
        'time': '3 days ago'
      },
      {
        'type': 'created',
        'playlist': 'Workout Mix',
        'time': '1 week ago'
      },
    ];
    
    return Column(
      children: activities.map((activity) {
        final IconData icon;
        final String text;
        
        switch (activity['type']) {
          case 'listened':
            icon = Icons.headphones;
            text = 'Listened to ${activity['song']} by ${activity['artist']}';
            break;
          case 'matched':
            icon = Icons.favorite;
            text = 'Matched with ${activity['name']}';
            break;
          case 'created':
            icon = Icons.playlist_add;
            text = 'Created playlist ${activity['playlist']}';
            break;
          default:
            icon = Icons.music_note;
            text = 'Unknown activity';
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity['time']!,
                      style: TextStyle(
                        color: AppTheme.mutedGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  String _getInitials(User user) {
    String initials = '';
    
    if (user.firstName != null && user.firstName!.isNotEmpty) {
      initials += user.firstName![0];
    }
    
    if (user.lastName != null && user.lastName!.isNotEmpty) {
      initials += user.lastName![0];
    }
    
    if (initials.isEmpty && user.username.isNotEmpty) {
      initials = user.username[0].toUpperCase();
    }
    
    return initials;
  }
  
  String _getUserDisplayName(User user) {
    if (user.firstName != null && user.lastName != null) {
      return '${user.firstName} ${user.lastName}';
    }
    
    if (user.firstName != null) {
      return user.firstName!;
    }
    
    return user.username;
  }
}