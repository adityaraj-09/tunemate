

import 'package:app/models/music/song.dart';
import 'package:flutter/material.dart';

class MusicProvider  extends ChangeNotifier{
  List<Playlist> _playlists = [];
  List<Playlist> get playlists => _playlists;
  void setPlaylists(List<Playlist> playlists) {
    _playlists = playlists;
    notifyListeners();
  }
  void addPlaylist(Playlist playlist) {
    _playlists.add(playlist);
    notifyListeners();
  }
  void removePlaylist(Playlist playlist) {
    _playlists.remove(playlist);
    notifyListeners();
  }

  void updatePlaylist(Playlist playlist) {
    final index = _playlists.indexWhere((p) => p.id == playlist.id);
    if (index != -1) {
      _playlists[index] = playlist;
      notifyListeners();
    }
  }

}