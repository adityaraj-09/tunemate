// lib/providers/music_player_provider.dart
import 'package:app/screens/player/full_player_screen.dart';
import 'package:app/services/di/service_locator.dart';
import 'package:app/services/music/background_player.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/music/song.dart';

import '../services/music/audio_player_service.dart';

class MusicPlayerProvider with ChangeNotifier {
  final AudioPlayerService _audioService = getIt<AudioPlayerService>();


  // Player state
  PlayerState _playerState = PlayerState();
  PlayerState get playerState => _playerState;

  // Active playlist
  Playlist? _currentPlaylist;
  Playlist? get currentPlaylist => _currentPlaylist;

  // Mini player visibility
  bool _isMiniPlayerVisible = false;
  bool get isMiniPlayerVisible => _isMiniPlayerVisible;

  // Full screen player visibility
  bool _isFullScreenPlayerVisible = false;
  bool get isFullScreenPlayerVisible => _isFullScreenPlayerVisible;

  // // Repeat mode
  // RepeatMode _repeatMode = RepeatMode.off;
  // RepeatMode get repeatMode => _repeatMode;

  // Stream subscription
  late StreamSubscription _playerStateSubscription;

  MusicPlayerProvider() {
    _playerStateSubscription =
        _audioService.playerStateStream.listen(_onPlayerStateChanged);
  }

  // Handle player state changes
  void _onPlayerStateChanged(PlayerState state) {
    print('Player state changed: ${state.currentSong?.toJson() ??''}');
    _playerState = state;

    // Auto-show mini player when a song is playing
    if (state.currentSong != null) {
      _isMiniPlayerVisible = true;
    }

    // Handle song completion
    if (state.status == PlaybackStatus.completed) {
      _handleSongCompletion();
    }

    notifyListeners();
  }

  // Play a single song
  Future<void> playSong(Song song) async {
    await _audioService.playSong(song);
    _isMiniPlayerVisible = true;
  

    notifyListeners();
  }

  // Play a playlist
  Future<void> playPlaylist(Playlist playlist, [int initialIndex = 0]) async {
    _currentPlaylist = playlist;
    await _audioService.playPlaylist(playlist.songs, initialIndex);
    _isMiniPlayerVisible = true;
    notifyListeners();
  }

  // Add song to queue
  void addToQueue(List<Song> song) {
  _audioService.addToQueue(song);
    notifyListeners();
  }

  // Play/Pause toggle
  Future<void> togglePlayPause() async {
    if (_playerState.isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.play();
    }
  }

  // Stop playback
  Future<void> stop() async {
    await _audioService.stop();
    _isMiniPlayerVisible = false;
    _isFullScreenPlayerVisible = false;
    notifyListeners();
  }

  // Seek to position
  Future<void> seekTo(Duration position) async {
    await _audioService.seek(position);
  }

  // Skip to next song
  Future<void> skipToNext() async {
    await _audioService.next();
  }

  // Skip to previous song
  Future<void> skipToPrevious() async {
    await _audioService.previous();
  }

  // Set volume
  Future<void> setVolume(double volume) async {
    await _audioService.setVolume(volume);
  }

  // Toggle shuffle mode
  void toggleShuffle() {
    _audioService.toggleShuffle();
  }

  // Toggle repeat mode
  // Future<void> toggleRepeatMode() async {
  //   switch (_repeatMode) {
  //     case RepeatMode.off:
  //       _repeatMode = RepeatMode.all;
  //       break;
  //     case RepeatMode.all:
  //       _repeatMode = RepeatMode.one;
  //       break;
  //     case RepeatMode.one:
  //       _repeatMode = RepeatMode.off;
  //       break;
  //   }

  //   await _audioService.to(_repeatMode);
  //   notifyListeners();
  // }

  // Show full screen player
  void showFullScreenPlayer() {
    _isFullScreenPlayerVisible = true;
    notifyListeners();
  }

  // Hide full screen player
  void hideFullScreenPlayer() {
    _isFullScreenPlayerVisible = false;
    notifyListeners();
  }

  // Toggle mini player visibility
  void toggleMiniPlayer() {
    if (_playerState.currentSong != null) {
      _isMiniPlayerVisible = !_isMiniPlayerVisible;
      notifyListeners();
    }
  }

  // Handle song completion
  void _handleSongCompletion() {
    if (playerState.hasNext) {
      skipToNext();
    } else {
      stop();
    }
  }

  // Download a song for offline playback
  Future<void> downloadSong(Song song) async {
    // Implementation would handle actual download
    print('Downloading ${song.name}');
    // TODO: Implement download functionality
  }

  // Share a song with a match
  Future<void> shareSongWithMatch(Song song, String matchId) async {
    // Implementation would connect to your backend
    print('Shared ${song.name} with match $matchId');
    // TODO: Implement sharing functionality
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
