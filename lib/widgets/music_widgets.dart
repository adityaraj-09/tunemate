// lib/widgets/music/genre_bubble.dart
import 'package:app/models/music/song.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class GenreBubble extends StatelessWidget {
  final String genre;
  final VoidCallback onTap;

  const GenreBubble({
    Key? key,
    required this.genre,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: _getGradient(genre),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _getBaseColor(genre).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          genre,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
  
  LinearGradient _getGradient(String genre) {
    switch (genre.toLowerCase()) {
      case 'pop':
        return const LinearGradient(
          colors: [AppTheme.accentPink, AppTheme.accentPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'rock':
        return const LinearGradient(
          colors: [Colors.red, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'hip hop':
      case 'rap':
        return const LinearGradient(
          colors: [Colors.amber, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'jazz':
        return const LinearGradient(
          colors: [Colors.indigo, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'classical':
        return const LinearGradient(
          colors: [Colors.teal, Colors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'electronic':
        return const LinearGradient(
          colors: [Colors.purple, Colors.deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
  
  Color _getBaseColor(String genre) {
    switch (genre.toLowerCase()) {
      case 'pop':
        return AppTheme.accentPink;
      case 'rock':
        return Colors.red;
      case 'hip hop':
      case 'rap':
        return Colors.amber;
      case 'jazz':
        return Colors.indigo;
      case 'classical':
        return Colors.teal;
      case 'electronic':
        return Colors.purple;
      default:
        return AppTheme.primaryColor;
    }
  }
}



class AlbumCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const AlbumCard({
    Key? key,
    required this.song,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppTheme.lightGrey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Album art with shadow and reflection effect
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      // Album image
                      Image.network(
                        song.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      
                      // Play overlay
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.1),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Song info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  Text(
                    song.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artists,
                    style: TextStyle(
                      color: AppTheme.mutedGrey,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  final bool isCompact;

  const PlaylistCard({
    Key? key,
    required this.playlist,
    required this.onTap,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isCompact ? double.infinity : 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Playlist cover
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: playlist.imageUrl != null
                      ? Image.network(
                          playlist.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Icon(
                            Icons.playlist_play_rounded,
                            size: 64,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                ),
              ),
            ),
            
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${playlist.songs.length} songs',
                    style: TextStyle(
                      color: AppTheme.mutedGrey,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class MusicListTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final bool showThumbnail;

  const MusicListTile({
    Key? key,
    required this.song,
    required this.onTap,
    this.showThumbnail = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail
                if (showThumbnail) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: Image.network(
                        song.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${song.artists} • ${song.album}',
                        style: TextStyle(
                          color: AppTheme.mutedGrey,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Duration
                Text(
                  _formatDuration(Duration(seconds: int.parse(song.duration!))),
                  style: TextStyle(
                    color: AppTheme.mutedGrey,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // More button
                Icon(
                  Icons.more_vert,
                  color: AppTheme.mutedGrey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}