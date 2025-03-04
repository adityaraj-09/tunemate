// lib/screens/home/home_screen.dart
import 'package:app/screens/search_screen.dart';
import 'package:app/widgets/common/error_widgey.dart';
import 'package:app/widgets/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../config/theme.dart';
import '../../providers/music_player_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/music/song.dart';
import '../../services/api/music_api.dart';
import '../../services/api/profile_api.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;

  List<Song> _trendingSongs = [];
  List<Song> _recommendedSongs = [];
  List<dynamic> _suggestedMatches = [];
  List<dynamic> _featuredPlaylists = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    _scrollController.addListener(_onScroll);

    _loadData();
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

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final musicApi = Provider.of<MusicApiService>(context, listen: false);
      final profileApi = Provider.of<ProfileApiService>(context, listen: false);

      // Fetch data in parallel
      final results = await Future.wait([
        musicApi.getTrendingSongs(limit: 10),
        musicApi.getPersonalRecommendations(limit: 15),
        profileApi.getMatches(limit: 5),
        // Fetch featured playlists would go here
      ]);

      if (mounted) {
        setState(() {
          _trendingSongs = results[0] as List<Song>;
          _recommendedSongs = results[1] as List<Song>;
          _suggestedMatches = results[2];
          _featuredPlaylists = []; // Placeholder for now
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
    final playerProvider =
        Provider.of<MusicPlayerProvider>(context, listen: false);
    playerProvider.playSong(song);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // Calculate parallax effect for background
    final backgroundOffset = _scrollOffset * 0.5;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background with parallax effect
          Positioned(
            top: -backgroundOffset,
            left: 0,
            right: 0,
            height: size.height * 0.5,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.accentPurple,
                    AppTheme.accentBlue,
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                );
              },
              child: _isLoading
                  ? _buildLoadingView()
                  : _error != null
                      ? ErrorView(
                          error: _error!,
                          onRetry: _loadData,
                        )
                      : _buildContent(theme, user),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App bar
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Discover',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon:
                  const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),

        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: ShimmerLoading(height: 32, width: 200),
              ),

              // Featured section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerLoading(
                  height: 180,
                  borderRadius: 16,
                ),
              ),

              const SizedBox(height: 32),

              // Trending section header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerLoading(height: 24, width: 160),
              ),

              const SizedBox(height: 16),

              // Trending songs
              SizedBox(
                height: 220,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: ShimmerLoading(
                        height: 220,
                        width: 160,
                        borderRadius: 12,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Suggested matches header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerLoading(height: 24, width: 180),
              ),

              const SizedBox(height: 16),

              // Suggested matches
              SizedBox(
                height: 180,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: ShimmerLoading(
                        height: 180,
                        width: 140,
                        borderRadius: 12,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme, dynamic user) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App bar
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Discover',
              style: TextStyle(
                color: _scrollOffset > 50 ? theme.primaryColor : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: _scrollOffset > 50 ? theme.primaryColor : Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchScreen()),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: _scrollOffset > 50 ? theme.primaryColor : Colors.white,
                ),
                onPressed: () {
                  // Navigate to notifications
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Text(
                    'Hello, ${user?.firstName ?? 'Music Lover'}!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _scrollOffset > 50
                          ? theme.textTheme.headlineSmall?.color
                          : Colors.white,
                    ),
                  ),
                ),

                // Featured section
                if (_trendingSongs.isNotEmpty)
                  AnimationConfiguration.staggeredList(
                    position: 0,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: FeatureCard(
                            song: _trendingSongs.first,
                            onTap: () => _playSong(_trendingSongs.first),
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // Trending section
                SectionHeader(
                  title: 'Trending Now',
                  textColor: theme.textTheme.headlineSmall?.color,
                  onSeeAllPressed: () {
                    // Navigate to full trending list
                  },
                ),

                SizedBox(
                  height: 240,
                  child: AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _trendingSongs.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: TrendingSongCard(
                                  song: _trendingSongs[index],
                                  onTap: () => _playSong(_trendingSongs[index]),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Suggested matches section
                if (_suggestedMatches.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Music Soulmates',
                    subtitle: 'People who share your taste',
                    textColor: theme.textTheme.headlineSmall?.color,
                    onSeeAllPressed: () {
                      // Navigate to matches screen
                    },
                  ),
                  SizedBox(
                    height: 200,
                    child: AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _suggestedMatches.length,
                        itemBuilder: (context, index) {
                          final match = _suggestedMatches[index];

                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 500),
                            child: SlideAnimation(
                              horizontalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: SuggestedMatchCard(
                                    match: match,
                                    onTap: () {
                                      // Navigate to match profile
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Recommended section
                SectionHeader(
                  title: 'For You',
                  subtitle: 'Based on your listening history',
                  textColor: theme.textTheme.headlineSmall?.color,
                  onSeeAllPressed: () {
                    // Navigate to recommendations
                  },
                ),

                SizedBox(
                  height: 240,
                  child: AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _recommendedSongs.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: TrendingSongCard(
                                  song: _recommendedSongs[index],
                                  onTap: () =>
                                      _playSong(_recommendedSongs[index]),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Space at bottom
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
