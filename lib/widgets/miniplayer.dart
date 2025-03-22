// lib/widgets/player/mini_player.dart
import 'package:app/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/music_player_provider.dart';
import 'package:go_router/go_router.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<MusicPlayerProvider>(context);

    final playerState = playerProvider.playerState;
    final currentSong = playerState.currentSong;

  
    if (currentSong == null || !playerProvider.isMiniPlayerVisible) {
      return SizedBox.shrink();
    }
    
    return GestureDetector(
      onTap: () => {playerProvider.showFullScreenPlayer(), context.go('/full-player')},
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          // Swipe up to show full player
          playerProvider.showFullScreenPlayer();
          context.go('/full-player');
        } else if (details.primaryVelocity! > 0) {
          // Swipe down to hide mini player
          playerProvider.toggleMiniPlayer();
        }
      },
      child: Container(
        height: 72,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Colors.transparent,
            child: Row(
              children: [
                // Album art
                Hero(
                  tag: 'album-art-${currentSong.id}',
                  child: Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(currentSong.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                
                // Song info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'song-title-${currentSong.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              currentSong.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Hero(
                          tag: 'song-artist-${currentSong.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              currentSong.artists,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        // Progress indicator
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: playerState.duration.inMilliseconds > 0
                              ? playerState.position.inMilliseconds / 
                                playerState.duration.inMilliseconds
                              : 0.0,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Controls
                Row(
                  children: [
                    // Previous button
                    IconButton(
                      icon: const Icon(Icons.skip_previous, color: Colors.white),
                      onPressed: playerState.hasPrevious
                          ? () => playerProvider.skipToPrevious()
                          : null,
                      iconSize: 28,
                    ),
                    
                    // Play/Pause button
                    IconButton(
                      icon: Icon(
                        playerState.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: Colors.white,
                      ),
                      onPressed: () => playerProvider.togglePlayPause(),
                      iconSize: 36,
                    ),
                    
                    // Next button
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: playerState.hasNext
                          ? () => playerProvider.skipToNext()
                          : null,
                      iconSize: 28,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}