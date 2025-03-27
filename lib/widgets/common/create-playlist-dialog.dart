
// lib/widgets/dialogs/create_playlist_dialog.dart
import 'package:app/services/api/playlist_api.dart';
import 'package:app/services/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../config/theme.dart';

import '../../providers/auth_provider.dart';

class CreatePlaylistDialog extends StatefulWidget {
  final List<String>? initialSongIds;

  const CreatePlaylistDialog({
    Key? key,
    this.initialSongIds,
  }) : super(key: key);

  @override
  _CreatePlaylistDialogState createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _imageUrl;
  File? _imageFile;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageUrl = null; // Clear existing URL if we have a new file
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
  
  void _removeImage() {
    setState(() {
      _imageFile = null;
      _imageUrl = null;
    });
  }
  
  Future<void> _createPlaylist() async {
    if (!_formKey.currentState!.validate()) return;
    
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
  
    
  
    setState(() {
      _isLoading = true;
    });
    
    try {
      // TODO: Upload image if _imageFile is not null and get URL
      // For now, we'll assume _imageUrl is already set or null
      
      final playlistService = getIt<PlaylistApiService>();
      final playlist = await playlistService.createPlaylist(
        name: name,
        description: description,
        songIds: [],
      );
      
      Navigator.of(context).pop(playlist);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playlist "$name" created successfully',),),
        
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating playlist: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.purpleBlueGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create Playlist',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Playlist Cover Image
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.darkGrey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _imageFile != null
                              ? Image.file(
                                  _imageFile!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                              : _imageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: _imageUrl!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) => const Icon(
                                        Icons.music_note,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.add_photo_alternate,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                        ),
                      ),
                      if (_imageFile != null || _imageUrl != null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Playlist Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Playlist Name',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.playlist_play),
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.darkGrey,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a playlist name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.darkGrey,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createPlaylist,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                              ),
                            )
                          : const Text('Create Playlist'),
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