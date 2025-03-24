  import 'package:app/models/music/song.dart';
import 'package:app/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
void showMenuSheet(BuildContext context, Song song) {
    // This would be fetched from your lyrics provider
  
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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

                if(song.albumUrl!=null && song.albumUrl!.isNotEmpty) 
                 ListTile(
                    leading: const Icon(Icons.album),
                    title: const Text('Go to Album'),
                    onTap: () {
                      // Navigate to album
                        Navigator.pop(context);
                        print("Album URL: ${song.albumUrl}");
                      context.go("/album",extra:  AlbumScreenParams(albumUrl: song.albumUrl!));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.playlist_add),
                    title: const Text('Add to Playlist'),
                    onTap: () {
                      // Show playlist selection dialog
                      Navigator.pop(context);
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