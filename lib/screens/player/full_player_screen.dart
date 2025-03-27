// lib/screens/player/full_player_screen.dart
import 'package:app/models/music/song.dart';
import 'package:app/routes/router.dart';
import 'package:app/screens/splash.dart';
import 'package:app/services/api/music_api.dart';
import 'package:app/services/di/service_locator.dart';
import 'package:app/widgets/common/bottomsheet-menu.dart';
import 'package:app/widgets/common/lyrics.dart';
import 'package:app/widgets/player/vinyl_record.dart';
import 'package:app/widgets/player/waveform_painter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../config/theme.dart';
import '../../providers/music_player_provider.dart';
import 'package:go_router/go_router.dart';

class FullPlayerScreen extends StatelessWidget {
  const FullPlayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<MusicPlayerProvider>();
    final musicApi = getIt<MusicApiService>();
    final playerState = playerProvider.playerState;
    final currentSong = playerState.currentSong;
  
    if (currentSong == null || !playerProvider.isFullScreenPlayerVisible) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Swipe down to close
            context.pop();
          }
        },
        child: Stack(
          children: [
            // Background with blur
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(currentSong.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App bar with close button
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white),
                          onPressed: () => context.pop(),
                          iconSize: 32,
                        ),
                        const Text(
                          'NOW PLAYING',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              showMenuSheet(context, currentSong);
                            },
                            icon: Icon(
                              Icons.more_horiz,
                              color: Colors.white,
                            ))
                      ],
                    ),
                  ),

                  // Album art with vinyl effect
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Hero(
                        tag: 'album-art-${currentSong.id}',
                        child: VinylRecord(
                          albumArt: currentSong.imageUrl,
                          isPlaying: playerState.isPlaying,
                          size: size.width * 0.6,
                        ),
                      ),
                    ),
                  ),

                  // Song info
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Song title
                          Hero(
                            tag: 'song-title-${currentSong.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                currentSong.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Artist
                          Hero(
                            tag: 'song-artist-${currentSong.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                currentSong.artists,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Album
                          Text(
                            currentSong.album,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 15),

                          // Waveform visualization
                          // SizedBox(
                          //   height: 60,
                          //   child: ClipRRect(
                          //     borderRadius: BorderRadius.circular(8),
                          //     child: CustomPaint(
                          //       painter: WaveformPainter(
                          //         progress: playerState
                          //                     .duration.inMilliseconds >
                          //                 0
                          //             ? playerState.position.inMilliseconds /
                          //                 playerState.duration.inMilliseconds
                          //             : 0.0,
                          //         activeColor: Colors.white,
                          //         inactiveColor: Colors.white30,
                          //         spacing: 3,
                          //         barWidth: 4,
                          //       ),
                          //       size: Size(size.width - 48, 60),
                          //     ),
                          //   ),
                          // ),

                          // const SizedBox(height: 16),

                          // Progress bar and duration
                          Row(
                            children: [
                              Text(
                                _formatDuration(playerState.position),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value:
                                      playerState.position.inSeconds.toDouble(),
                                  min: 0.0,
                                  max: double.parse(
                                      playerState.currentSong!.duration ??
                                          '500'),
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white24,
                                  onChanged: (value) {
                                    playerProvider.seekTo(
                                        Duration(seconds: value.toInt()));
                                  },
                                ),
                              ),
                              Text(
                                _formatDuration(Duration(
                                    seconds: int.parse(
                                        playerState.currentSong!.duration ??
                                            '500'))),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          // Player controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Shuffle button
                              // IconButton(
                              //   icon: Icon(
                              //     Icons.shuffle,
                              //     color: playerState.isShuffled
                              //         ? AppTheme.accentAmber
                              //         : Colors.white70,
                              //   ),
                              //   onPressed: () => playerProvider.toggleShuffle(),
                              //   iconSize: 24,
                              // ),

                              // Previous button
                              IconButton(
                                icon: const Icon(Icons.skip_previous,
                                    color: Colors.white),
                                onPressed: playerState.hasPrevious
                                    ? () => playerProvider.skipToPrevious()
                                    : null,
                                iconSize: 36,
                              ),

                              // Play/Pause button
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppTheme.purpleBlueGradient,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    playerState.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                  onPressed: () =>
                                      playerProvider.togglePlayPause(),
                                  iconSize: 48,
                                  padding: const EdgeInsets.all(8),
                                ),
                              ),

                              // Next button
                              IconButton(
                                icon: const Icon(Icons.skip_next,
                                    color: Colors.white),
                                onPressed: playerState.hasNext
                                    ? () => playerProvider.skipToNext()
                                    : null,
                                iconSize: 36,
                              ),

                              // Repeat button
                              // IconButton(
                              //   icon: Icon(
                              //     _getRepeatIcon(playerState.isShuffled
                              //         ? RepeatMode.off
                              //         : ),
                              //     color: playerState.repeatMode != RepeatMode.off
                              //         ? AppTheme.accentAmber
                              //         : Colors.white70,
                              //   ),
                              //   onPressed: () => playerProvider.toggleShuffle(),
                              //   iconSize: 24,
                              // ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Bottom controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Add to playlist
                              _buildCircleButton(
                                icon: Icons.playlist_add,
                                onPressed: () {
                                  // Show add to playlist dialog
                                  _showAddToPlaylistDialog(
                                      context, currentSong);
                                },
                              ),

                              // Share with match
                              _buildCircleButton(
                                icon: Icons.favorite_border,
                                onPressed: () async {
                                  await musicApi.likeSong(currentSong, true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Liked ${currentSong.name}'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),

                              // Lyrics
                              _buildCircleButton(
                                icon: Icons.music_note,
                                onPressed: () {
                                  // Show lyrics dialog
                                  _showLyricsSheet(context, currentSong);
                                },
                              ),

                              // Download
                              _buildCircleButton(
                                icon: Icons.download_outlined,
                                onPressed: () {
                                  // Download song
                                  // playerProvider.downloadSong(currentSong);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Downloading ${currentSong.name}'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        iconSize: 24,
      ),
    );
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.off:
        return Icons.repeat;
      case RepeatMode.all:
        return Icons.repeat;
      case RepeatMode.one:
        return Icons.repeat_one;
      default:
        return Icons.repeat;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showSongOptions(BuildContext context, Song song) {
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
              icon: Icons.playlist_add,
              title: 'Add to Playlist',
              onTap: () {
                Navigator.pop(context);
                _showAddToPlaylistDialog(context, song);
              },
            ),
            _buildOptionTile(
              icon: Icons.favorite_border,
              title: 'Share with Match',
              onTap: () {
                Navigator.pop(context);
                _showShareWithMatchDialog(context, song);
              },
            ),
            _buildOptionTile(
              icon: Icons.person,
              title: 'View Artist',
              onTap: () {
                Navigator.pop(context);

                // Navigate to artist page
              },
            ),
            if (song.albumUrl != null)
              _buildOptionTile(
                icon: Icons.album,
                title: 'View Album',
                onTap: () {
                  Navigator.pop(context);
                  context.go("/album",
                      extra: AlbumScreenParams(albumUrl: song.albumUrl!));
                },
              ),
            _buildOptionTile(
              icon: Icons.download_outlined,
              title: 'Download',
              onTap: () {
                Navigator.pop(context);
                // Download logic
                final playerProvider =
                    Provider.of<MusicPlayerProvider>(context, listen: false);
                playerProvider.downloadSong(song);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Downloading ${song.name}'),
                    behavior: SnackBarBehavior.floating,
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

  void _showAddToPlaylistDialog(BuildContext context, Song song) {
    // This would be populated from your provider with actual playlists
    final playlists = [
      'Favorites',
      'My Playlist 1',
      'Workout Mix',
      'Chill Vibes'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGrey,
        title: const Text(
          'Add to Playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount:
                playlists.length + 1, // +1 for "Create new playlist" option
            itemBuilder: (context, index) {
              if (index == playlists.length) {
                return ListTile(
                  leading: const Icon(Icons.add, color: AppTheme.accentBlue),
                  title: const Text(
                    'Create new playlist',
                    style: TextStyle(color: AppTheme.accentBlue),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Show create playlist dialog
                  },
                );
              }

              return ListTile(
                title: Text(
                  playlists[index],
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Add song to selected playlist
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added to ${playlists[index]}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showShareWithMatchDialog(BuildContext context, Song song) {
    // This would be populated from your matches provider
    final matches = [
      {'name': 'Alex', 'imageUrl': 'https://via.placeholder.com/150'},
      {'name': 'Jordan', 'imageUrl': 'https://via.placeholder.com/150'},
      {'name': 'Taylor', 'imageUrl': 'https://via.placeholder.com/150'},
      {'name': 'Casey', 'imageUrl': 'https://via.placeholder.com/150'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGrey,
        title: const Text(
          'Share with Match',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(match['imageUrl']!),
                ),
                title: Text(
                  match['name']!,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Share song with selected match
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Shared "${song.name}" with ${match['name']}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLyricsSheet(BuildContext context, Song song) {
    // This would be fetched from your lyrics provider
    final lyrics = song.lyrics ?? "No lyrics available";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                song.name,
                style: const TextStyle(
                  color: AppTheme.primaryVariantColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                song.artists,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: LyricsDisplay(lyrics: lyrics),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Model extension for RepeatMode
enum RepeatMode {
  off,
  all,
  one,
}

// Extension methods for PlayerState to provide helpful getters
extension PlayerStateExtension on PlayerState {
  bool get isPlaying => status == PlaybackStatus.playing;
  bool get isBuffering => status == PlaybackStatus.buffering;
  bool get isPaused => status == PlaybackStatus.paused;
  bool get isStopped => status == PlaybackStatus.stopped;
  bool get isCompleted => status == PlaybackStatus.completed;
  bool get isError => status == PlaybackStatus.error;
  bool get isLoading => status == PlaybackStatus.loading;

  bool get hasNext => queue.isNotEmpty && currentIndex < queue.length - 1;
  bool get hasPrevious => queue.isNotEmpty && currentIndex > 0;
}
