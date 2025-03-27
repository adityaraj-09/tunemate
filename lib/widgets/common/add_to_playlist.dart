// lib/widgets/dialogs/add_to_playlist_dialog.dart
import 'package:app/providers/music_provider.dart';
import 'package:app/services/api/playlist_api.dart';
import 'package:app/widgets/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';

import '../../models/music/song.dart';
import '../../services/api/music_api.dart';
import '../../services/di/service_locator.dart';

class AddToPlaylistDialog extends StatefulWidget {
  final Song song;

  const AddToPlaylistDialog({
    Key? key,
    required this.song,
  }) : super(key: key);

  @override
  _AddToPlaylistDialogState createState() => _AddToPlaylistDialogState();
}

class _AddToPlaylistDialogState extends State<AddToPlaylistDialog> {
  bool _isLoading = true;
  bool _isCreatingNewPlaylist = false;
  bool _isAddingSong = false;
  String? _error;
  List<Playlist> _playlists = [];
  final TextEditingController _newPlaylistNameController =
      TextEditingController();
  final TextEditingController _newPlaylistDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _newPlaylistNameController.dispose();
    _newPlaylistDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaylists() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final musicApi = getIt<MusicApiService>();
      final userPlaylists = await musicApi.getUserPlaylists();

      setState(() {
        _playlists = userPlaylists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addToPlaylist(Playlist playlist) async {
    try {
      setState(() {
        _isAddingSong = true;
        _error = null;
      });

      final musicApi = getIt<PlaylistApiService>();
      var p = await musicApi.addSongToPlaylist(playlist.id, widget.song.id);

      if (p != null) {
        var provider = Provider.of<MusicProvider>(context, listen: false);
    
        provider.updatePlaylist(p);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${widget.song.name}" to "${playlist.name}"'),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _error = 'Failed to add song to playlist';
          _isAddingSong = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isAddingSong = false;
      });
    }
  }

  Future<void> _createNewPlaylist() async {
    try {
      final name = _newPlaylistNameController.text.trim();
      if (name.isEmpty) {
        setState(() {
          _error = 'Playlist name cannot be empty';
        });
        return;
      }

      setState(() {
        _isAddingSong = true;
        _error = null;
      });

      final description = _newPlaylistDescriptionController.text.trim();
      final musicApi = getIt<MusicApiService>();

      // Create the playlist
      final newPlaylist = await musicApi.createPlaylist(
        name,
        description: description.isNotEmpty ? description : null,
        songIds: [widget.song.id], // Add the song directly when creating
      );
      var provider = Provider.of<MusicProvider>(context, listen: false);
      provider.addPlaylist(newPlaylist);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Created playlist "${name}" with "${widget.song.name}"'),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isAddingSong = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<MusicProvider>(context, listen: false);
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(
                  'Add to Playlist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Song info
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Album art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.song.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, __) => Container(
                        width: 60,
                        height: 60,
                        color: AppTheme.lightGrey,
                        child: Icon(
                          Icons.music_note,
                          color: AppTheme.mutedGrey,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 16),

                  // Song details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.song.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.song.artists,
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

            Divider(height: 1, color: AppTheme.lightGrey),

            if (_error != null)
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            // Playlists
            Expanded(
              child: _isCreatingNewPlaylist
                  ? _buildNewPlaylistForm()
                  : _buildPlaylistList(provider),
            ),

            // Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel Button
                  TextButton(
                    onPressed: _isAddingSong
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppTheme.mutedGrey,
                      ),
                    ),
                  ),

                  // Create New / Back button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCreatingNewPlaylist
                          ? Colors.amber
                          : AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _isAddingSong
                        ? null
                        : () {
                            setState(() {
                              _isCreatingNewPlaylist = !_isCreatingNewPlaylist;
                            });
                          },
                    child: Text(
                      _isCreatingNewPlaylist
                          ? 'Back to Playlists'
                          : 'Create New Playlist',
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

  Widget _buildPlaylistList(MusicProvider provider) {
    var playlists = provider.playlists;

    if (playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_add,
              size: 48,
              color: AppTheme.mutedGrey,
            ),
            SizedBox(height: 16),
            Text(
              "You don't have any playlists yet",
              style: TextStyle(
                color: AppTheme.mutedGrey,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Tap 'Create New Playlist' to get started",
              style: TextStyle(
                color: AppTheme.mutedGrey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        itemCount: playlists.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final playlist = playlists[index];

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 300),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: AppTheme.purpleBlueGradient,
                      ),
                      child: playlist.imageUrl != null
                          ? Image.network(
                              playlist.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, _, __) => Icon(
                                Icons.playlist_play,
                                color: Colors.white,
                                size: 24,
                              ),
                            )
                          : Icon(
                              Icons.playlist_play,
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                  ),
                  title: Text(
                    playlist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${playlist.totalSongs} songs',
                    style: TextStyle(
                      color: AppTheme.mutedGrey,
                      fontSize: 12,
                    ),
                  ),
                  onTap: _isAddingSong ? null : () => _addToPlaylist(playlist),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewPlaylistForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create New Playlist',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),

          // Playlist name input
          TextField(
            controller: _newPlaylistNameController,
            decoration: InputDecoration(
              labelText: 'Playlist Name',
              hintText: 'Enter a name for your playlist',
              filled: true,
              fillColor: AppTheme.lightGrey.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
          ),

          SizedBox(height: 10),

          // Playlist description input
          TextField(
            controller: _newPlaylistDescriptionController,
            decoration: InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'Add a description for your playlist',
              filled: true,
              fillColor: AppTheme.lightGrey.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            minLines: 2,
            maxLines: 3,
          ),

          SizedBox(height: 24),

          // Create button
          Container(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isAddingSong ? null : _createNewPlaylist,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isAddingSong
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Create Playlist',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Show the dialog
void showAddToPlaylistDialog(BuildContext context, Song song) {
  showDialog(
    context: context,
    builder: (context) => AddToPlaylistDialog(song: song),
  );
}
