// lib/models/music/song.dart
class Song {
  final String id;
  final String name;
  final String album;
  final String artists;
  final String imageUrl;
  final String mediaUrl;
  final String? lyrics;
  final String? duration;
  final String? year;
  final String? language;
  final String? genre;
  final String? albumUrl;

  Song({
    required this.id,
    required this.name,
    required this.album,
    required this.artists,
    required this.imageUrl,
    required this.mediaUrl,
    this.lyrics,
    this.duration,
    this.year,
    this.language,
    this.genre,
    this.albumUrl,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] ?? '',
      name: json['song'] ?? json['name'] ?? '',
      album: json['album'] ?? '',
      artists: json['artists'] ?? json['primary_artists'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? json['image'] ?? '',
      mediaUrl: json['mediaUrl'] ?? json['media_url'] ?? '',
      lyrics: json['lyrics'],
      duration: json['duration'],
      year: json['year'] ?? json['release_year'],
      language: json['language'],
      genre: json['genre'],
      albumUrl: json['album_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'song': name,
      'album': album,
      'primary_artists': artists,
      'singers':artists,
      'image': imageUrl,
      'media_url': mediaUrl,
      'lyrics': lyrics,
      'duration': duration,
      "copyright_text":'',
      'year': year,
      'language': language,
      'genre': genre,
      'album_url': albumUrl,
    };
  }
}

// lib/models/music/playlist.dart
class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<Song> songs;
  final String? createdBy;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.songs,
    this.createdBy,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      songs: (json['songs'] as List?)
              ?.map((song) => Song.fromJson(song))
              .toList() ??
          [],
      createdBy: json['createdBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'songs': songs.map((song) => song.toJson()).toList(),
      'createdBy': createdBy,
    };
  }
}

// lib/models/music/player_state.dart
enum PlaybackStatus {
  idle,
  loading,
  buffering,
  playing,
  paused,
  stopped,
  completed,
  error
}

enum RepeatMode {
  off,
  all,
  one,
}

class PlayerState {
  final PlaybackStatus status;
  final Song? currentSong;
  final List<Song> queue;
  final int currentIndex;
  final Duration position;
  final Duration duration;
  final double volume;
  final bool isShuffled;
  final String? error;

  PlayerState({
    this.status = PlaybackStatus.idle,
    this.currentSong,
    this.queue = const [],
    this.currentIndex = -1,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.isShuffled = false,
    this.error,
  });

  bool get isPlaying => status == PlaybackStatus.playing;
  bool get isPaused => status == PlaybackStatus.paused;
  bool get isLoading =>
      status == PlaybackStatus.loading || status == PlaybackStatus.buffering;
  bool get hasError => status == PlaybackStatus.error;
  bool get isIdle => status == PlaybackStatus.idle;
  bool get hasPrevious => currentIndex > 0;
  bool get hasNext => currentIndex < queue.length - 1;

  // Progress percentage (0.0 to 1.0)
  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  // Returns the remaining time
  Duration get remaining {
    return duration - position;
  }

  PlayerState copyWith({
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
    return PlayerState(
      status: status ?? this.status,
      currentSong: currentSong ?? this.currentSong,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isShuffled: isShuffled ?? this.isShuffled,
      error: error ?? this.error,
    );
  }
}
