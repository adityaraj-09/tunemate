// lib/screens/music/music_screen.dart
import 'package:app/screens/playlist_screen.dart';
import 'package:app/screens/search_screen.dart';
import 'package:app/services/api/playlist_api.dart';
import 'package:app/services/di/service_locator.dart';
import 'package:app/widgets/common/bottomsheet-menu.dart';
import 'package:app/widgets/common/create-playlist-dialog.dart';
import 'package:app/widgets/common/error_widgey.dart';
import 'package:app/widgets/home_widgets.dart';
import 'package:app/widgets/music_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../config/theme.dart';
import '../../providers/music_player_provider.dart';
import '../../services/api/music_api.dart';
import '../../models/music/song.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;

  List<Song> _recentlyPlayed = [];
  List<Playlist> _userPlaylists = [];
  Map<String, List<Song>> _genreSongs = {};
  List<String> _genres = [];
  List<Song> _recommendedSongs = [];

  late TabController _tabController;

  // Animation controller for page transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final ScrollController _scrollController = ScrollController();
  final List<String> _tabs = ['For You', 'Playlists', 'Genres', 'Artists'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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

    _loadData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final musicApi = getIt<MusicApiService>();
      final playlistAPi=getIt<PlaylistApiService>();

      // Fetch data in parallel
      final results = await Future.wait([
        musicApi.getTrendingSongs(limit: 15),
playlistAPi.getUserPlaylists()
        // musicApi.getPersonalRecommendations(),

        // musicApi.getTrendingByGenre(limit: 6),
      ]);

      if (mounted) {
        setState(() {
          _recentlyPlayed = results[0] as List<Song>;
          _userPlaylists = results[1] as List<Playlist>;
      
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

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 160.0,
              floating: true,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.accentPurple,
                            AppTheme.accentPurple.withOpacity(0.7),
                            AppTheme.accentPurple.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                            Colors.white,
                          ],
                          stops: const [0.0, 0.3, 0.5, 0.65, 0.8, 1.0],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.9),
                            AppTheme.accentPurple,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    titlePadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    title: Container(
                      margin: const EdgeInsets.only(bottom: 60),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.music_note_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Music',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(68),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                      top: 16, bottom: 12, left: 8, right: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: List.generate(_tabs.length, (index) {
                        final isSelected = _tabController.index == index;
                        return GestureDetector(
                          onTap: () {
                            _tabController.animateTo(index);
                            setState(() {});
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [
                                        AppTheme.primaryColor,
                                        AppTheme.accentPurple
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isSelected
                                  ? null
                                  : AppTheme.lightGrey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Text(
                              _tabs[index],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.mutedGrey,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            )
          ];
        },
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: child,
            );
          },
          child: TabBarView(
            controller: _tabController,
            children: [
              // For You Tab
              _buildForYouTab(),

              // Playlists Tab
              _buildPlaylistsTab(),

              // Genres Tab
              _buildGenresTab(),

              // Artists Tab
              _buildArtistsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForYouTab() {
    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_error != null) {
      return ErrorView(
        error: _error!,
        onRetry: _loadData,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                // Recently played section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Recently Played',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                const SizedBox(height: 16.0),

                // Album artwork grid
                SizedBox(
                  height: 220.0,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: _recentlyPlayed.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: AlbumCard(
                          song: _recentlyPlayed[index],
                          onTap: () => _playSong(_recentlyPlayed[index]),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32.0),

                // Made for you section (playlists)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Made For You',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to recommendations
                        },
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16.0),

                SizedBox(
                  height: 212.0,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: _userPlaylists.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: PlaylistCard(
                          playlist: _userPlaylists[index],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return PlaylistDetailScreen(
                                    playlistId: _userPlaylists[index].id,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32.0),

                // Popular genres
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Popular Genres',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                const SizedBox(height: 16.0),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    children: _genres.map((genre) {
                      return GenreBubble(
                        genre: genre,
                        onTap: () {},
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 32.0),

                // Popular songs list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Popular Songs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                const SizedBox(height: 16.0),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: min(_recentlyPlayed.length, 5),
                  itemBuilder: (context, index) {
                    return MusicListTile(
                      song: _recentlyPlayed[index],
                      onOptionsTap: () {
                        showMenuSheet(context, _recentlyPlayed[index]);
                      },
                      onTap: () => _playSong(_recentlyPlayed[index]),
                    );
                  },
                ),

                const SizedBox(height: 100.0), // Space for mini player
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_error != null) {
      return ErrorView(
        error: _error!,
        onRetry: _loadData,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: AnimationLimiter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Create playlist button
              Container(
                margin: const EdgeInsets.only(bottom: 24.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      showDialog(context: context, builder: (context) {
                        return CreatePlaylistDialog();
                      });
                    },
                    borderRadius: BorderRadius.circular(12.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 24.0,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          const Expanded(
                            child: Text(
                              'Create New Playlist',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 16.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Your playlists
              Text(
                'Your Playlists',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 16.0),

              _userPlaylists.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'You haven\'t created any playlists yet.\nTap the button above to get started!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.mutedGrey,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    )
                  : StaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      children: List.generate(
                        _userPlaylists.length,
                        (index) => StaggeredGridTile.fit(
                          crossAxisCellCount: 1,
                          child: AnimationConfiguration.staggeredGrid(
                            position: index,
                            duration: const Duration(milliseconds: 500),
                            columnCount: 2,
                            child: ScaleAnimation(
                              child: FadeInAnimation(
                                child: PlaylistCard(
                                  playlist: _userPlaylists[index],
                                  isCompact: true,
                                  onTap: () {},
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

              const SizedBox(height: 100.0), // Space for mini player
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenresTab() {
    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_error != null) {
      return ErrorView(
        error: _error!,
        onRetry: _loadData,
      );
    }

    // Custom grid layout for genres
    return RefreshIndicator(
      onRefresh: _loadData,
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: _genres.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 500),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    gradient: LinearGradient(
                      colors: [
                        _getGenreColor(index),
                        _getGenreColor(index).withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getGenreColor(index).withOpacity(0.3),
                        blurRadius: 8.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _getGenreIcon(_genres[index]),
                              color: Colors.white,
                              size: 36.0,
                            ),
                            const Spacer(),
                            Text(
                              _genres[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              '${_genreSongs[_genres[index]]?.length ?? 0} songs',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArtistsTab() {
    // Would be populated with artists data in a real app
    return const Center(
      child: Text('Artists coming soon!'),
    );
  }

  Widget _buildLoadingView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loading for recently played
          const ShimmerLoading(height: 28.0, width: 160.0),
          const SizedBox(height: 16.0),

          SizedBox(
            height: 180.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: ShimmerLoading(
                    height: 180.0,
                    width: 140.0,
                    borderRadius: 12.0,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32.0),

          // Loading for playlists
          const ShimmerLoading(height: 28.0, width: 120.0),
          const SizedBox(height: 16.0),

          SizedBox(
            height: 160.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: ShimmerLoading(
                    height: 160.0,
                    width: 160.0,
                    borderRadius: 12.0,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32.0),

          // Loading for genres
          const ShimmerLoading(height: 28.0, width: 140.0),
          const SizedBox(height: 16.0),

          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: List.generate(
              6,
              (index) => ShimmerLoading(
                height: 40.0,
                width: 100.0 + (index * 10.0),
                borderRadius: 20.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper functions for genre styling
  Color _getGenreColor(int index) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.accentPurple,
      AppTheme.accentBlue,
      AppTheme.accentPink,
      AppTheme.accentTeal,
      AppTheme.accentAmber,
    ];

    return colors[index % colors.length];
  }

  IconData _getGenreIcon(String genre) {
    final genreLower = genre.toLowerCase();

    if (genreLower.contains('pop')) return Icons.people_outline;
    if (genreLower.contains('rock')) return Icons.music_note_rounded;
    if (genreLower.contains('hip hop') || genreLower.contains('rap'))
      return Icons.mic_external_on;
    if (genreLower.contains('jazz')) return Icons.music_note;
    if (genreLower.contains('classic')) return Icons.piano;
    if (genreLower.contains('electronic')) return Icons.waves;
    if (genreLower.contains('indie')) return Icons.album;
    if (genreLower.contains('folk')) return Icons.music_note;

    return Icons.headphones;
  }

  int min(int a, int b) {
    return a < b ? a : b;
  }
}
