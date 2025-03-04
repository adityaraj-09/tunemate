// lib/widgets/search/search_result_tile.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SearchResultTile extends StatelessWidget {
  final String type;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback onTap;

  const SearchResultTile({
    Key? key,
    required this.type,
    required this.title,
    required this.subtitle,
    this.imageUrl,
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
                // Thumbnail or avatar
                if (imageUrl != null) ...[
                  _buildThumbnail(),
                  const SizedBox(width: 16),
                ],
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildTypeIcon(),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              subtitle,
                              style: TextStyle(
                                color: AppTheme.mutedGrey,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Action button
                _buildActionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildThumbnail() {
    switch (type) {
      case 'artist':
        return CircleAvatar(
          radius: 28,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          backgroundColor: AppTheme.lightGrey,
          child: imageUrl == null
              ? const Icon(
                  Icons.person,
                  color: AppTheme.mutedGrey,
                )
              : null,
        );
      case 'album':
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 56,
            height: 56,
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: AppTheme.lightGrey,
                    child: const Icon(
                      Icons.album,
                      color: AppTheme.mutedGrey,
                    ),
                  ),
          ),
        );
      case 'song':
      default:
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 56,
            height: 56,
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: AppTheme.lightGrey,
                    child: const Icon(
                      Icons.music_note,
                      color: AppTheme.mutedGrey,
                    ),
                  ),
          ),
        );
    }
  }
  
  Widget _buildTypeIcon() {
    final IconData iconData;
    final Color color;
    
    switch (type) {
      case 'artist':
        iconData = Icons.person;
        color = AppTheme.accentPurple;
        break;
      case 'album':
        iconData = Icons.album;
        color = AppTheme.accentBlue;
        break;
      case 'song':
      default:
        iconData = Icons.music_note;
        color = AppTheme.primaryColor;
    }
    
    return Icon(
      iconData,
      size: 14,
      color: color,
    );
  }
  
  Widget _buildActionButton() {
    switch (type) {
      case 'artist':
        return Icon(
          Icons.arrow_forward_ios,
          color: AppTheme.mutedGrey,
          size: 16,
        );
      case 'album':
        return Icon(
          Icons.arrow_forward_ios,
          color: AppTheme.mutedGrey,
          size: 16,
        );
      case 'song':
      default:
        return IconButton(
          icon: Icon(
            Icons.play_circle_fill,
            color: AppTheme.primaryColor,
            size: 32,
          ),
          onPressed: onTap,
        );
    }
  }
}


class RecentSearchTile extends StatelessWidget {
  final String query;
  final VoidCallback onTap;

  const RecentSearchTile({
    Key? key,
    required this.query,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              Icon(
                Icons.history,
                color: AppTheme.mutedGrey,
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  query,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.north_west,
                  color: AppTheme.mutedGrey,
                  size: 16,
                ),
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}