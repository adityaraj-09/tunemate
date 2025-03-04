// lib/widgets/profile/profile_stat.dart
import 'package:app/models/music/models.dart';
import 'package:app/models/music/song.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

import 'package:fl_chart/fl_chart.dart';
class ProfileStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool light;

  const ProfileStat({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color = AppTheme.primaryColor,
    this.light = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: light 
                ? Colors.white.withOpacity(0.2) 
                : color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: light ? Colors.white : color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: light ? Colors.white : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: light ? Colors.white.withOpacity(0.8) : AppTheme.mutedGrey,
          ),
        ),
      ],
    );
  }
}

// lib/widgets/profile/music_taste_chart.dart



class MusicTasteChart extends StatelessWidget {
  final MusicTaste musicTaste;

  const MusicTasteChart({
    Key? key,
    required this.musicTaste,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final genres = musicTaste.genres;
    
    if (genres.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              size: 48,
              color: AppTheme.lightGrey,
            ),
            SizedBox(height: 16),
            Text(
              'No music taste data yet.\nStart listening to build your profile!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.mutedGrey,
              ),
            ),
          ],
        ),
      );
    }
    
    // Convert to data for PieChart
    final pieChartSections = genres.asMap().entries.map((entry) {
      final index = entry.key;
      final genre = entry.value;
      
      return PieChartSectionData(
        value: genre.percentage,
        title: '${genre.name}\n${genre.percentage.toInt()}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        color: _getGenreColor(index),
        badgeWidget: _getGenreIcon(genre.name),
        badgePositionPercentageOffset: 1.5,
      );
    }).toList();
    
    return Row(
      children: [
        // Chart
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: pieChartSections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              startDegreeOffset: 180,
            ),
          ),
        ),
        
        // Legend
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: genres.asMap().entries.map((entry) {
              final index = entry.key;
              final genre = entry.value;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getGenreColor(index),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        genre.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Color _getGenreColor(int index) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.accentPurple,
      AppTheme.accentBlue,
      AppTheme.accentPink,
      AppTheme.accentTeal,
      AppTheme.accentAmber,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.indigo,
    ];
    
    return colors[index % colors.length];
  }
  
  Widget _getGenreIcon(String genre) {
    final IconData iconData;
    
    switch (genre.toLowerCase()) {
      case 'pop':
        iconData = Icons.people;
        break;
      case 'rock':
        iconData = Icons.music_note_sharp;
        break;
      case 'hip hop':
      case 'rap':
        iconData = Icons.mic;
        break;
      case 'jazz':
        iconData = Icons.music_note;
        break;
      case 'classical':
        iconData = Icons.piano;
        break;
      case 'electronic':
        iconData = Icons.waves;
        break;
      default:
        iconData = Icons.headphones;
    }
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: AppTheme.primaryColor,
        size: 16,
      ),
    );
  }
}



class FavoriteSongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const FavoriteSongTile({
    Key? key,
    required this.song,
    required this.onTap,
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
                Stack(
                  children: [
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
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.accentPink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
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
                        song.artists,
                        style: const TextStyle(
                          color: AppTheme.mutedGrey,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Play button
                IconButton(
                  icon: const Icon(
                    Icons.play_circle_fill,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                  onPressed: onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}