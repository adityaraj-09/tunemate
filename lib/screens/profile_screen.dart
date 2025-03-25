// lib/screens/profile/profile_screen.dart
import 'package:app/models/music/models.dart';
import 'package:app/routes/router.dart';
import 'package:app/screens/edit_profile.dart';
import 'package:app/screens/listening_history.dart';
import 'package:app/screens/settings_screen.dart';
import 'package:app/services/di/service_locator.dart';
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
import 'package:go_router/go_router.dart';


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
    
    // Delay data loading slightly to ensure providers are fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
    
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
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      // Get auth provider safely
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Check if user is available from auth provider
      final user = authProvider.currentUser;
      print("Current user: $user");
      
      if (user != null) {
        setState(() {
          _user = user;
        });
        
        // Now get profile API
        if (!mounted) return;
        final profileApi = getIt<ProfileApiService>();
        
        // Get music taste and favorite songs data
        try {
          final results = await Future.wait([
            // profileApi.getMusicTaste(),
            profileApi.getFavoriteSongs(limit: 5),
          ]);
          
          if (mounted) {
            setState(() {
              // _musicTaste = results[0] as MusicTaste;
              _favoriteSongs = results[0] ;
            });
          }
        } catch (e) {
          print("Error fetching music taste or favorites: $e");
          // Don't set error state here to allow partial UI to show
        }
      } else {
        setState(() {
          _error = "User not found. Please log in again.";
        });
      }
    } catch (e) {
      print("Error in _loadProfileData: $e");
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
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
    
    // Show loading indicator while initial loading
    if (_isLoading && _user == null) {
      return const Scaffold(
        body: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }
    
    // Handle error case
    if (_error != null && _user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading profile',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(_error!),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadProfileData,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }
    
    // If no user is available after loading, show a user-friendly message
    if (_user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_off,
                size: 60,
                color: AppTheme.mutedGrey,
              ),
              const SizedBox(height: 16),
              Text(
                'Profile not available',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text('Please log in to view your profile'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate to login or take appropriate action
                },
                child: const Text('Log In'),
              ),
            ],
          ),
        ),
      );
    }
    
    // If we reach here, we have a user
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
              decoration: const BoxDecoration(
                gradient: AppTheme.purpleBlueGradient,
                borderRadius: BorderRadius.only(
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
                          // const Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //   children: [
                          //     ProfileStat(
                          //       title: 'Matches',
                          //       value: '32',
                          //       icon: Icons.favorite,
                          //       color: Colors.white,
                          //       light: true,
                          //     ),
                          //     ProfileStat(
                          //       title: 'Songs',
                          //       value: '145',
                          //       icon: Icons.music_note,
                          //       color: Colors.white,
                          //       light: true,
                          //     ),
                          //     ProfileStat(
                          //       title: 'Playlists',
                          //       value: '7',
                          //       icon: Icons.playlist_play,
                          //       color: Colors.white,
                          //       light: true,
                          //     ),
                          //   ],
                          // ),
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
                              // Text(
                              //   'My Music Taste',
                              //   style: theme.textTheme.titleLarge?.copyWith(
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                              
                              // const SizedBox(height: 16),
                              
                              // // Genre chart
                              // _musicTaste == null
                              //   ? const ShimmerLoading(height: 220)
                              //   : SizedBox(
                              //       height: 220,
                              //       child: MusicTasteChart(musicTaste: _musicTaste!),
                              //     ),
                              
                              // const SizedBox(height: 32),
                              
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
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Text(
                              //       'History',
                              //       style: theme.textTheme.titleLarge?.copyWith(
                              //         fontWeight: FontWeight.bold,
                              //       ),
                              //     ),
                              //     TextButton(
                              //       onPressed: () {
                              //         Navigator.push(
                              //           context,
                              //           MaterialPageRoute(builder: (context) => const ListeningHistoryScreen()),
                              //         );
                              //       },
                              //       child: const Text('See All'),
                              //     ),
                              //   ],
                              // ),
                              
                              // const SizedBox(height: 16),
                              
                              // // Activity list
                              // _buildRecentActivityList(),
                              
                              // Settings button
                              // const SizedBox(height: 32),
                              ListTile(
                                title: const Text('Settings'),
                                leading: const Icon(Icons.settings),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                  );
                                },
                              ),  ListTile(
                                title: const Text('Listening History'),
                                leading: const Icon(Icons.history),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ListeningHistoryScreen()),
                                  );
                                },
                              ),
                            
                              OutlinedButton.icon(

                                onPressed: ()async {
                                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                await  authProvider.signOut();
                                
                              context.pushReplacement("/login");

                                },
                                icon: const Icon(Icons.settings),
                                label: const Text('Log Out'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  iconColor: Colors.red,
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
          song: Song.fromJson(song["song"]),
          onTap: () => _playSong(Song.fromJson(song["song"])),
        );
      }).toList(),
    );
  }
  
  Widget _buildRecentActivityList() {
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
                      style: const TextStyle(
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