// lib/services/music/audio_player_service.dart
import 'dart:async';
import 'package:app/services/api/music_api.dart';
import 'package:app/services/di/service_locator.dart';
import 'package:app/services/music/background_player.dart' hide RepeatMode;
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import '../../models/music/song.dart';


class AudioPlayerService {
  // Singleton instance
  static AudioPlayerService? _instance;
  
  // Factory that takes the dependency
  factory AudioPlayerService(AudioHandlerService audioHandler) {
    _instance ??= AudioPlayerService._internal(audioHandler);
    return _instance!;
  }
  
  // Audio handler for background playback
  final AudioHandlerService _audioHandler;
  final musicApi=getIt<MusicApiService>();
  
  AudioPlayerService._internal(this._audioHandler) {
    _init();
  }

  // Player state controller
  final _playerStateController = StreamController<PlayerState>.broadcast();
  Stream<PlayerState> get playerStateStream => _playerStateController.stream;

  // State tracking
  PlayerState _playerState = PlayerState();
  PlayerState get playerState => _playerState;

  // Initialize the audio service
  Future<void> _init() async {
    try {
      
      // Forward state updates from the audio handler
      _audioHandler.playerStateStream.listen((state) {

        _playerState = state;
        _playerStateController.add(_playerState);
      });
      
      // Configure the audio session
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      _updateState(
        status: PlaybackStatus.error,
        error: e.toString(),
      );
    }
  }

  // Update the player state and broadcast to listeners
  void _updateState({
    PlaybackStatus? status,
    Song? currentSong,
    List<Song>? queue,
    int? currentIndex,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isShuffled,
    String? error,
  }) {
    _playerState = _playerState.copyWith(
      status: status,
      currentSong: currentSong,
      queue: queue,
      currentIndex: currentIndex,
      position: position,
      duration: duration,
      volume: volume,
      isShuffled: isShuffled,
      error: error,
    );

    _playerStateController.add(_playerState);
  }

  // Play a song directly
  Future<void> playSong(Song song) async {
    try {
      await _audioHandler.playSong(song);
    await musicApi.listenSong(song,int.parse( song.duration ?? "180"));
    } catch (e) {
      _updateState(
        status: PlaybackStatus.error,
        error: e.toString(),
      );
    }
  }

  // Play a list of songs (playlist)
  Future<void> playPlaylist(List<Song> songs, int initialIndex) async {
    if (songs.isEmpty) return;

    try {
      await _audioHandler.playPlaylist(songs, initialIndex);
    } catch (e) {
      _updateState(
        status: PlaybackStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> addToQueue(List<Song> songs) async {
    await _audioHandler.addAllToQueue(songs);
  }

  // Resume playback
  Future<void> play() async {
    await _audioHandler.play();
  }

  // Pause playback
  Future<void> pause() async {
    await _audioHandler.pause();
  }

  // Stop playback
  Future<void> stop() async {
    await _audioHandler.stop();
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    await _audioHandler.seek(position);
  }

  // Skip to next song
  Future<void> next() async {
    await _audioHandler.next();
  }

  // Skip to previous song
  Future<void> previous() async {
    await _audioHandler.previous();
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _audioHandler.setVolume(volume);
  }

  // Toggle shuffle mode
  void toggleShuffle() {
    _audioHandler.toggleShuffle();
  }
  
  // Toggle repeat mode
  // Future<void> toggleRepeatMode(RepeatMode mode) async {
  //   await _audioHandler.toggleRepeatMode(mode);
  // }

  // Release resources when done
  void dispose() {
    _audioHandler.dispose();
    _playerStateController.close();
  }

  void updateState({
    Song? currentSong,
    List<Song>? queue,
    int? currentIndex,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isShuffled,
  }) {
    _updateState(
      currentSong: currentSong,
      queue: queue,
      currentIndex: currentIndex,
      position: position,
      duration: duration,
      volume: volume,
      isShuffled: isShuffled,
    );
  }
}

// Repeat mode enum
enum RepeatMode {
  off,
  all,
  one,
}