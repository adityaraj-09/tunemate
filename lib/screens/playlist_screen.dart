import 'package:app/config/theme.dart';
import 'package:app/models/music/song.dart';
import 'package:app/services/api/playlist_api.dart';
import 'package:app/services/di/service_locator.dart';
import 'package:app/widgets/common/bottomsheet-menu.dart';
import 'package:app/widgets/common/error_widgey.dart';
import 'package:app/widgets/miniplayer.dart';
import 'package:app/widgets/music_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/music_player_provider.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String? playlistId;
  final Playlist? playlist;

  // Constructor allows passing either a playlistId or a full playlist object
  const PlaylistDetailScreen({
    Key? key,
    this.playlistId,
    this.playlist,
  })  : assert(playlistId != null || playlist != null),
        super(key: key);

  @override
  _PlaylistDetailScreenState createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late Future<Playlist> _playlistFuture;
  final _playlistService = getIt<PlaylistApiService>();
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    _loadPlaylistData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final bool isHeaderCollapsed = _scrollController.offset > 200;
    if (isHeaderCollapsed != _isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = isHeaderCollapsed;
      });
    }
  }

  void _loadPlaylistData() {
    // If we already have a playlist object, use it
    // Otherwise, fetch the playlist using the ID
    if (widget.playlist != null) {
      _playlistFuture = Future.value(widget.playlist!);
    } else {
      _playlistFuture =
          _playlistService.getPlaylistWithSongs(widget.playlistId!);
    }
  }

  void _playAllSongs(Playlist playlist, MusicPlayerProvider playerProvider) {
    if (playlist.songs.isEmpty) return;

    playerProvider.playPlaylist(playlist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [FutureBuilder<Playlist>(
          future: _playlistFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.accentPurple,
                ),
              );
            }
        
            if (snapshot.hasError) {
              return ErrorView(
                error: snapshot.error.toString(),
                onRetry: () {
                  setState(() {
                    _loadPlaylistData();
                  });
                },
              );
            }
        
            if (!snapshot.hasData) {
              return ErrorView(
                error: "Playlist not found",
                onRetry: () {},
              );
            }
        
            final playlist = snapshot.data!;
            return _buildPlaylistDetail(context, playlist);
          },
        ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(),
          ),
        ]
      ),
    );
  }

  Widget _buildPlaylistDetail(BuildContext context, Playlist playlist) {
    final playerProvider = Provider.of<MusicPlayerProvider>(context);

    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            title: _isHeaderCollapsed ? Text(playlist.name) : null,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildPlaylistHeader(context, playlist),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  _showPlaylistOptionsModal(context, playlist);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share song'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement song sharing
                },
              ),
            ],
          ),
        ];
      },
      body: Column(
        children: [
          _buildPlaylistActions(context, playlist, playerProvider),
          Expanded(
            child: _buildSongsList(context, playlist, playerProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistHeader(BuildContext context, Playlist playlist) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.0),
          ],
        ),
      ),
      child: Stack(
        children: [
          if (playlist.songs.isNotEmpty)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: playlist.songs[0].imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surface,
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: const Icon(Icons.music_note, size: 60),
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  playlist.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (playlist.description != null &&
                    playlist.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      playlist.description!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    children: [
                      Text(
                        '${playlist.totalSongs} songs',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistActions(BuildContext context, Playlist playlist,
      MusicPlayerProvider playerProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              _playAllSongs(playlist, playerProvider);
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Play All'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shuffle_rounded),
            onPressed: () {
              if (playlist.songs.isEmpty) return;
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList(BuildContext context, Playlist playlist,
      MusicPlayerProvider playerProvider) {
    if (playlist.songs.isEmpty) {
      return const Center(
        child: Text('This playlist has no songs yet'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: playlist.songs.length,
      itemBuilder: (context, index) {
        final song = playlist.songs[index];
        return MusicListTile(
          song: song,
          onTap: () {
            _playSong(index, playlist, context);
          },
          onOptionsTap: () {
            showMenuSheet(context, song);
          },
        );
      },
    );
  }

  void _playSong(int index, Playlist pl, BuildContext context) {
    final playerProvider =
        Provider.of<MusicPlayerProvider>(context, listen: false);
    playerProvider.playPlaylist(pl, index);
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Playlist'),
          content: const Text(
              'Are you sure you want to delete this playlist? This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void _showPlaylistOptionsModal(BuildContext context, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit playlist'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to edit playlist screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.content_copy),
                title: const Text('Duplicate playlist'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await _playlistService.copyPlaylist(playlist.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Playlist duplicated')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete playlist'),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await _showDeleteConfirmationDialog(context);
                  if (confirm == true) {
                    try {
                      await _playlistService.deletePlaylist(playlist.id);
                      Navigator.pop(context); // Return to previous screen
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
