// lib/screens/music/album_detail_screen.dart
import 'package:app/models/music/models.dart';
import 'package:app/services/api/music_api.dart';
import 'package:app/services/di/service_locator.dart';
import 'package:app/widgets/common/bottomsheet-menu.dart';
import 'package:app/widgets/miniplayer.dart';
import 'package:app/widgets/music_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../config/theme.dart';

import '../../models/music/song.dart';
import '../../providers/music_player_provider.dart';

class AlbumDetailScreen extends StatefulWidget {
  final String albumUrl;
  final Album? album; // Optional: pass album object directly if available

  const AlbumDetailScreen({
    Key? key,
    required this.albumUrl,
    this.album,
  }) : super(key: key);

  @override
  _AlbumDetailScreenState createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  Album? _album;

  late ScrollController _scrollController;
  double _scrollOffset = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();

    // If album is already provided, use it; otherwise fetch from URL
    if (widget.album != null) {
      _album = widget.album;
      _isLoading = false;
    } else {
      _loadAlbum();
    }
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAlbum() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final albumApi = getIt<MusicApiService>();
      final album = await albumApi.getAlbum(widget.albumUrl);

      if (mounted) {
        setState(() {
          _album = Album.fromJson(album);
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

  void _playSong(int index) {
    final playerProvider =
        Provider.of<MusicPlayerProvider>(context, listen: false);
  playerProvider.playPlaylist(Playlist(id:_album!.title , name: _album!.title, songs: _album!.songs), index);
  }

  void _playAlbum() {
  

    final playerProvider =
        Provider.of<MusicPlayerProvider>(context, listen: false);
        playerProvider.playPlaylist(Playlist(id:_album!.title , name: _album!.title, songs: _album!.songs), 0);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Album'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Album'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
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
                'Error loading album',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(_error!),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadAlbum,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final album = _album!;
    final collapsedAppBar = _scrollOffset > 150;

    return Scaffold(
      body: Stack(
        children: [
          // Background blur image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.5,
            child: AnimatedOpacity(
              opacity: collapsedAppBar ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(album.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
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
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // App bar
                  SliverAppBar(
                    backgroundColor: collapsedAppBar
                        ? theme.scaffoldBackgroundColor
                        : Colors.transparent,
                    elevation: collapsedAppBar ? 4 : 0,
                    floating: false,
                    pinned: true,
                    expandedHeight: 250,
                    title: AnimatedOpacity(
                      opacity: collapsedAppBar ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        album.displayName,
                        style: TextStyle(
                          color: collapsedAppBar ? null : Colors.white,
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        color: collapsedAppBar ? null : Colors.white,
                        onPressed: () {
                          // Show options menu
                          _showAlbumOptions(context, album);
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: AnimatedOpacity(
                        opacity: collapsedAppBar ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 48), // Space for app bar

                                // Album info row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Album cover
                                    Hero(
                                      tag: 'album-cover-${album.permalink}',
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                          image: DecorationImage(
                                            image: NetworkImage(album.imageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    // Album details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            album.displayName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Released: ${album.releaseYear}',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${album.songCount} songs • ${_formatDuration(album.totalDuration)}',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Play button and song list
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Play button
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                            child: Row(
                              children: [
                                // Play button
                                ElevatedButton.icon(
                                  onPressed: _playAlbum,
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Play All'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Shuffle button
                                IconButton(
                                  icon: const Icon(Icons.shuffle),
                                  color: AppTheme.primaryColor,
                                  onPressed: () {
                                    // _playAlbum();
                                  },
                                ),

                                const SizedBox(width: 8),

                                // Download button
                                IconButton(
                                  icon: const Icon(Icons.download_outlined),
                                  color: AppTheme.primaryColor,
                                  onPressed: () {
                                    // Download album logic
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Album download started'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const Divider(),

                          // Songs title
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Row(
                              children: [
                                Text(
                                  'Songs',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${album.songCount} songs',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.mutedGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Song list
                          AnimationLimiter(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: album.songs.length,
                              itemBuilder: (context, index) {
                                final song = album.songs[index];
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: MusicListTile(
                                        song: song,
                                        onOptionsTap: () {
                                          showMenuSheet(context, song);
                                        },
                                        onTap: () => _playSong(index),
                                        showThumbnail: true,
                                        // Add track number
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Space for mini player
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Mini player
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(),
          ),
        ],
      ),
    );
  }

  void _showAlbumOptions(BuildContext context, Album album) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.darkGrey,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildOptionTile(
              icon: Icons.add_to_queue,
              title: 'Add to Queue',
              onTap: () {
                Navigator.pop(context);
                // Add all songs to queue
                final playerProvider =
                    Provider.of<MusicPlayerProvider>(context, listen: false);
                for (final song in album.songs) {
                  // Add to queue logic
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Album added to queue'),
                  ),
                );
              },
            ),
            _buildOptionTile(
              icon: Icons.playlist_add,
              title: 'Add to Playlist',
              onTap: () {
                Navigator.pop(context);
                // Show add to playlist dialog
              },
            ),
            _buildOptionTile(
              icon: Icons.share,
              title: 'Share',
              onTap: () {
                Navigator.pop(context);
                // Share album
              },
            ),
            _buildOptionTile(
              icon: Icons.download_outlined,
              title: 'Download',
              onTap: () {
                Navigator.pop(context);
                // Download album
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Album download started'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }
}
