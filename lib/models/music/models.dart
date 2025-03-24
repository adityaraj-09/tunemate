// lib/models/profile/music_taste.dart
import 'package:app/models/music/song.dart';

class MusicTaste {
  final List<GenrePreference> genres;
  final List<String> favoriteArtists;
  final List<String> favoriteGenres;
  final Map<String, double> eras;

  MusicTaste({
    required this.genres,
    required this.favoriteArtists,
    required this.favoriteGenres,
    required this.eras,
  });

  factory MusicTaste.fromJson(Map<String, dynamic> json) {
    return MusicTaste(
      genres: (json['genres'] as List)
          .map((genre) => GenrePreference.fromJson(genre))
          .toList(),
      favoriteArtists: (json['favoriteArtists'] as List)
          .map((artist) => artist as String)
          .toList(),
      favoriteGenres: (json['favoriteGenres'] as List)
          .map((genre) => genre as String)
          .toList(),
      eras: Map<String, double>.from(json['eras'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'genres': genres.map((genre) => genre.toJson()).toList(),
      'favoriteArtists': favoriteArtists,
      'favoriteGenres': favoriteGenres,
      'eras': eras,
    };
  }
}

class GenrePreference {
  final String name;
  final double percentage;

  GenrePreference({
    required this.name,
    required this.percentage,
  });

  factory GenrePreference.fromJson(Map<String, dynamic> json) {
    return GenrePreference(
      name: json['name'] as String,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'percentage': percentage,
    };
  }
}

// lib/models/profile/match.dart
class Match {
  final String id;
  final String userId;
  final String name;
  final String? imageUrl;
  final double compatibility;
  final List<String> commonGenres;
  final List<String> commonArtists;
  final bool isActive;
  final DateTime matchedAt;
  final int messageCount;

  Match({
    required this.id,
    required this.userId,
    required this.name,
    this.imageUrl,
    required this.compatibility,
    required this.commonGenres,
    required this.commonArtists,
    required this.isActive,
    required this.matchedAt,
    required this.messageCount,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      compatibility: (json['compatibility'] as num).toDouble(),
      commonGenres: (json['commonGenres'] as List)
          .map((genre) => genre as String)
          .toList(),
      commonArtists: (json['commonArtists'] as List)
          .map((artist) => artist as String)
          .toList(),
      isActive: json['isActive'] as bool,
      matchedAt: DateTime.parse(json['matchedAt'] as String),
      messageCount: json['messageCount'] as int,
    );
  }
}

// lib/models/chat/message.dart
class Message {
  final String id;
  final String matchId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? songId;

  Message({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.songId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool,
      songId: json['songId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchId': matchId,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'songId': songId,
    };
  }
}

class Album {
  String title;
  String? name;
  String imageUrl;
  String releaseDate;
  List<Song> songs;
  String permalink;

  Album({
    required this.title,
    this.name,
    required this.imageUrl,
    required this.releaseDate,
    required this.songs,
    required this.permalink,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      title: json['title'] as String,
      name: json['name'] as String?,
      imageUrl: json['image'] as String,
      releaseDate: json['release_date'] as String,
      songs: (json['songs'] as List)
          .map((song) => Song.fromJson(song))
          .toList(),
      permalink: json['perma_url'] as String,
    );
  }
 String get displayName => name ?? title;
  
  // Get total duration of the album
  Duration get totalDuration {
    return songs.fold(
      Duration.zero,
      (total, song) => total + Duration(seconds: int.parse(song.duration ?? '300')),
    );
  }
  
  // Get formatted release year
  String get releaseYear {
    try {
      final date = DateTime.parse(releaseDate);
      return date.year.toString();
    } catch (e) {
      return releaseDate; // Return as is if parsing fails
    }
  }
  
  // Get total number of songs
  int get songCount => songs.length;
}

class Conversation {
  final String matchId;
  final String userId;
  final String name;
  final String? photoUrl;
  final Message? lastMessage;
  final int unreadCount;
  final bool isActive;

  Conversation({
    required this.matchId,
    required this.userId,
    required this.name,
    this.photoUrl,
    this.lastMessage,
    required this.unreadCount,
    required this.isActive,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      matchId: json['matchId'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] as int,
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'userId': userId,
      'name': name,
      'photoUrl': photoUrl,
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'isActive': isActive,
    };
  }
}
