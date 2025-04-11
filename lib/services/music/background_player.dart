// lib/services/music/audio_handler_service.dart
import 'dart:async';
import 'package:app/services/api/music_api.dart';
import 'package:app/services/di/service_locator.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import '../../models/music/song.dart' as app_models;
import '../../models/music/song.dart';

// This class manages the background audio service and media notifications
class AudioHandlerService {
  // Singleton implementation
  static final AudioHandlerService _instance = AudioHandlerService._internal();
  factory AudioHandlerService() => _instance;
  AudioHandlerService._internal();

  // Audio handler instance
  late AudioHandler _audioHandler;

  // Player state controller
  final _playerStateController =
      StreamController<app_models.PlayerState>.broadcast();
  Stream<app_models.PlayerState> get playerStateStream =>
      _playerStateController.stream;

  // State tracking
  app_models.PlayerState _playerState = app_models.PlayerState();
  app_models.PlayerState get playerState => _playerState;
  String? _lastPlayedSongId;

  // Initialize the audio handler
  Future<void> init() async {
    _audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.yourdomain.musicdatingapp.audio',
        androidNotificationChannelName: 'Music Dating App',
        androidNotificationIcon: 'drawable/ic_notification',
        androidShowNotificationBadge: true,
        notificationColor: Color(0xFF6200EE),
        androidStopForegroundOnPause: false,
      ),
    );

    // Listen for media item changes
    _audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem != null) {
        _updateStateFromMediaItem(mediaItem);
      }
    });

    // Listen for playback state changes
    _audioHandler.playbackState.listen((playbackState) {
  
      _updateStateFromPlaybackState(playbackState);
    });

    // Listen for queue changes
    _audioHandler.queue.listen((queue) {
      _updateStateFromQueue(queue);
    });
  }

  // Update state from media item
  void _updateStateFromMediaItem(MediaItem mediaItem) {
   final song = _convertMediaItemToSong(mediaItem);
    _updateState(currentSong: song);
  // Check if this is a different song than the last one
  if (_lastPlayedSongId != song.id) {
    // Save the last song ID
    final previousSongId = _lastPlayedSongId;
    _lastPlayedSongId = song.id;
    
    // This is a song change - could be auto or user-triggered
    _onSongChanged(song, previousSongId);
    
  }
  

  }

  void _onSongChanged(Song newSong, String? previousSongId) async{
  print('Song changed to: ${newSong.name}');
final api=getIt<MusicApiService>();
  await api.listenSong(newSong, int.parse(newSong.duration ??"300"));
  }




  // Update state from playback state
  void _updateStateFromPlaybackState(PlaybackState playbackState) {
    app_models.PlaybackStatus status;

    // Convert playback state to our app's status enum
    if (playbackState.processingState == AudioProcessingState.loading ||
        playbackState.processingState == AudioProcessingState.buffering) {
      status = app_models.PlaybackStatus.buffering;
    } else if (playbackState.playing) {
      status = app_models.PlaybackStatus.playing;
    } else if (playbackState.processingState ==
        AudioProcessingState.completed) {
      status = app_models.PlaybackStatus.completed;
    } else if (playbackState.processingState == AudioProcessingState.error) {
      status = app_models.PlaybackStatus.error;
    } else {
      status = app_models.PlaybackStatus.paused;
    }

    _updateState(
      status: status,
      position: playbackState.position,
    
      isShuffled: playbackState.shuffleMode == AudioServiceShuffleMode.all,
    );
  }

  // Update state from queue
  void _updateStateFromQueue(List<MediaItem> queue) {
    final songs = queue.map(_convertMediaItemToSong).toList();
    _updateState(queue: songs);
  }

  // Convert MediaItem to Song
  Song _convertMediaItemToSong(MediaItem mediaItem) {
    return Song(
      id: mediaItem.id,
      name: mediaItem.title,
      artists: mediaItem.artist ?? 'Unknown Artist',
      album: mediaItem.album ?? 'Unknown Album',
      imageUrl: mediaItem.artUri?.toString() ?? '',
      mediaUrl: mediaItem.extras?['url'] as String? ?? '',
      albumUrl: mediaItem.extras?['albumUrl'] as String? ?? '',
    );
  }


  MediaItem _convertSongToMediaItem(Song song) {
    return MediaItem(
      id: song.id,
      title: song.name,
      artist: song.artists,
      album: song.album,
      duration: Duration(seconds: int.parse(song.duration ??'500')),
      artUri: Uri.parse(song.imageUrl),
      extras: {'url': song.mediaUrl,"albumUrl":song.albumUrl},
      genre: song.genre,
    );
  }

  // Update the player state and broadcast to listeners
  void _updateState({
    app_models.PlaybackStatus? status,
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
      status: status ?? _playerState.status,
      currentSong: currentSong ?? _playerState.currentSong,
      queue: queue ?? _playerState.queue,
      currentIndex: currentIndex ?? _playerState.currentIndex,
      position: position ?? _playerState.position,
      duration: duration ?? _playerState.duration,
      volume: volume ?? _playerState.volume,
      isShuffled: isShuffled ?? _playerState.isShuffled,
      error: error ?? _playerState.error,
    );
  

    _playerStateController.add(_playerState);
  }

  // Play a song directly
  Future<void> playSong(Song song) async {
    final mediaItem = _convertSongToMediaItem(song);
    await _audioHandler.playMediaItem(mediaItem);

    _updateState(
      status: app_models.PlaybackStatus.loading,
      currentSong: song,
      queue: [song],
      currentIndex: 0,
      position: Duration.zero,
    );
  }

  // Play a list of songs (playlist)
  Future<void> playPlaylist(List<Song> songs, int initialIndex) async {
    try {
      if (songs.isEmpty) return;

      // Ensure the index is valid
      final index = initialIndex.clamp(0, songs.length - 1);
      final currentSong = songs[index];

      // Convert songs to media items
      final mediaItems = songs.map(_convertSongToMediaItem).toList();

      // Set the queue
      await _audioHandler.updateQueue(mediaItems);

      // Skip to the desired index
      await _audioHandler.skipToQueueItem(index);

      // Start playback
      await _audioHandler.play();

      _updateState(
        status: app_models.PlaybackStatus.loading,
        currentSong: currentSong,
        queue: songs,
        currentIndex: index,
        position: Duration.zero,
      );
    } catch (e) {
      print('Error playing playlist: $e');
    }
  }

  Future<void> addAllToQueue(List<Song> songs) async {
    try {
      if (songs.isEmpty) return;

      // Convert songs to media items
      final mediaItems = songs.map(_convertSongToMediaItem).toList();

      // Add to the queue
      await _audioHandler.addQueueItems(mediaItems);

      // Update the queue
      final currentQueue = _playerState.queue ?? [];
      final newQueue = [...currentQueue, ...songs];
      _updateState(queue: newQueue);
    } catch (e) {
      print('Error adding songs to queue: $e');
    }
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
    _updateState(
      status: app_models.PlaybackStatus.stopped,
  
    );
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    await _audioHandler.seek(position);
  }

  // Skip to next song
  Future<void> next() async {
    await _audioHandler.skipToNext();
  }

  // Skip to previous song
  Future<void> previous() async {
  
      await _audioHandler.skipToPrevious();
    
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    volume = volume.clamp(0.0, 1.0);
    // The audio_service doesn't have a direct volume control,
    // so we need to handle this in the audio handler implementation
    if (_audioHandler is MyAudioHandler) {
      await (_audioHandler as MyAudioHandler).setVolume(volume);
      _updateState(volume: volume);
    }
  }

  // Toggle shuffle mode
  Future<void> toggleShuffle() async {
    final isCurrentlyShuffle = _playerState.isShuffled;
    if (isCurrentlyShuffle) {
      await _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    } else {
      await _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    }
    _updateState(isShuffled: !isCurrentlyShuffle);
  }

  // Toggle repeat mode
  // Future<void> toggleRepeatMode(RepeatMode mode) async {
  //   AudioServiceRepeatMode audioServiceMode;

  //   switch (mode) {
  //     case RepeatMode.off:
  //       audioServiceMode = AudioServiceRepeatMode.none;
  //       break;
  //     case app_models.RepeatMode.all:
  //       audioServiceMode = AudioServiceRepeatMode.all;
  //       break;
  //     case app_models.RepeatMode.one:
  //       audioServiceMode = AudioServiceRepeatMode.one;
  //       break;
  //     default:
  //       audioServiceMode = AudioServiceRepeatMode.none;
  //   }

  //   await _audioHandler.setRepeatMode(audioServiceMode);
  // }

  // Release resources when done
  void dispose() {
    _playerStateController.close();
  }
}

// Implementation of AudioHandler
class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  // Constructor
  MyAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
  }

  // Load an empty playlist
  Future<void> _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print("Error: $e");
    }
  }

  // Listen for playback events and notify audio handler
  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  // Listen for duration changes
  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      var index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (index >= newQueue.length) return;
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  // Listen for current song index changes
  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      if (index >= playlist.length) return;
      mediaItem.add(playlist[index]);
    });
  }

  // Listen for sequence state changes
  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem).toList();
      queue.add(items);
    });
  }

  // Override play method
  @override
  Future<void> play() => _player.play();

  // Override pause method
  @override
  Future<void> pause() => _player.pause();

  // Override stop method
  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  // Override seek method
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  // Override skipToNext method
  @override
  Future<void> skipToNext() => _player.seekToNext();

  // Override skipToPrevious method
  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  // Override skipToQueueItem method
  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    // This jumps to the beginning of the queue item at [index].
    _player.seek(Duration.zero, index: index);
  }

  // Override addQueueItem method
  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final audioSource = _createAudioSource(mediaItem);
    await _playlist.add(audioSource);
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    final audioSources = mediaItems.map(_createAudioSource).toList();
    await _playlist.addAll(audioSources);
  }

  // Override updateQueue method
  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    await _playlist.clear();
    await _playlist.addAll(
      queue.map(_createAudioSource).toList(),
    );
  }

  // Override removeQueueItem method
  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = queue.value.indexOf(mediaItem);
    if (index == -1) return;
    await _playlist.removeAt(index);
  }

  // Override playMediaItem method
  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    await _playlist.clear();
    await _playlist.add(_createAudioSource(mediaItem));
    await _player.setAudioSource(_playlist);
    await _player.play();
  }

  // Helper method to create an audio source from a media item
  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    final url = mediaItem.extras!['url'] as String;
    return AudioSource.uri(
      Uri.parse(url),
      tag: mediaItem,
    );
  }

  // Custom method to set volume
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  // Override dispose method
  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      super.stop();
    }
    return super.customAction(name, extras);
  }
}

// Extension for RepeatMode
enum RepeatMode {
  off,
  all,
  one,
}
