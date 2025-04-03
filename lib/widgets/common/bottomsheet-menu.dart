import 'package:app/config/theme.dart';
import 'package:app/models/music/song.dart';
import 'package:app/providers/music_player_provider.dart';
import 'package:app/routes/router.dart';
import 'package:app/widgets/common/add_to_playlist.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void showMenuSheet(BuildContext context, Song song) {
  // This would be fetched from your lyrics provider

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
            // Handle draggable sheet header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Song info
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  song.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(song.name),
              subtitle: Text(song.artists),
            ),

            const Divider(),

            // Menu items
            ListView(
              shrinkWrap: true,
              controller: scrollController,
              children: [
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text('Like'),
                  onTap: () {
                    // Handle like action
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text('Add to Queue'),
                  onTap: () {
                    var provider = Provider.of<MusicPlayerProvider>(context,listen: false);
                    provider.addToQueue([song]);
                  ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to Queue'),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
                    Navigator.pop(context);
                  },
                ),
                if (song.albumUrl != null && song.albumUrl!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.album),
                    title: const Text('Go to Album'),
                    onTap: () {
                  Navigator.pop(context);
                      context.go("/album",
                          extra: AlbumScreenParams(albumUrl: song.albumUrl!));
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.playlist_add),
                  title: const Text('Add to Playlist'),
                  onTap: () {
                      Navigator.pop(context);
                  showAddToPlaylistDialog(context, song);
                  
                  },
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}
