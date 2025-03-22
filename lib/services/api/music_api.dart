// lib/services/api/music_api.dart
import 'package:dio/dio.dart';
import '../../models/music/song.dart';

class MusicApiService {
  final Dio _dio;

  MusicApiService(this._dio);

  // Get trending songs
  Future<List<Song>> getTrendingSongs(
      {int limit = 20, String timeframe = 'week'}) async {
    try {
      final response = await _dio.get(
        '/api/music/trending',
        queryParameters: {
          'limit': limit,
          'timeframe': timeframe,
        },
      );

      if (response.data['success'] && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((songData) => Song.fromJson(songData))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get trending songs by genre
  Future<Map<String, List<Song>>> getTrendingByGenre(
      {int limit = 5, String timeframe = 'week'}) async {
    try {
      final response = await _dio.get(
        '/api/music/trending-by-genre',
        queryParameters: {
          'limit': limit,
          'timeframe': timeframe,
        },
      );

      if (response.data['success'] && response.data['data'] != null) {
        final result = <String, List<Song>>{};

        for (var genreData in response.data['data']) {
          final genre = genreData['genre'] as String;
          final songs = (genreData['songs'] as List)
              .map((songData) => Song.fromJson(songData))
              .toList();

          result[genre] = songs;
        }

        return result;
      }

      return {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get personalized recommendations
  Future<List<Song>> getPersonalRecommendations({int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/api/music/personal-trending',
        queryParameters: {
          'limit': limit,
        },
      );

      if (response.data['success'] && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((songData) => Song.fromJson(songData))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get next songs based on current song
  Future<List<Song>> getNextSongs(String currentSongId,
      {int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/api/music/next-songs',
        queryParameters: {
          'currentSongId': currentSongId,
          'limit': limit,
        },
      );

      if (response.data['success'] && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((songData) => Song.fromJson(songData))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Create or update song queue
  Future<bool> createQueue(List<String> songIds, {bool isActive = true}) async {
    try {
      final response = await _dio.post(
        '/api/music/queue',
        data: {
          'songIds': songIds,
          'isActive': isActive,
        },
      );

      return response.data['success'] ?? false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get song radio based on seed song
  Future<List<Song>> getSongRadio(String seedSongId, {int limit = 25}) async {
    try {
      final response = await _dio.get(
        '/api/music/radio/$seedSongId',
        queryParameters: {
          'limit': limit,
        },
      );

      if (response.data['success'] && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((songData) => Song.fromJson(songData))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Search for songs, artists, or albums
  Future<Map<String, dynamic>> search(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/api/songs/search',
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );

      if (response.data['success']) {
        final result = <String, dynamic>{};

        if (response.data['songs'] != null) {
          result['songs'] = (response.data['songs'] as List)
              .map((songData) => Song.fromJson(songData))
              .toList();
        }

        if (response.data['artists'] != null) {
          result['artists'] = response.data['artists'];
        }

        if (response.data['albums'] != null) {
          result['albums'] = response.data['albums'];
        }

        return result;
      }

      return {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Like a song
  Future<bool> likeSong(String songId,bool isFav) async {
    try {
      final response = await _dio.post(
        '/api/users/music/favorite',
        data: {
          'songId': songId,
          "isFavorite": isFav,
        },
      );

      return response.data['success'] ?? false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }  
  
  Future<bool> listenSong(String songId,int duration) async {
    try {
      final response = await _dio.post(
        '/api/songs/listen',
        data: {
          'songId': songId,
          "duration": duration,
        },
      );

      return response.data['success'] ?? false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

Future<dynamic> getAlbum(String url) async{
    try {
      final response = await _dio.get(
        '/api/songs/albums',
        queryParameters: {
          "query": url,
          "lyrics": true,
        }
      );

    
        return response.data;
      

    
    } on DioException catch (e) {
      throw _handleError(e);
    }
}

  // Get user playlists
  Future<List<Playlist>> getUserPlaylists() async {
    try {
      final response = await _dio.get('/api/music/playlists');

      if (response.data['success'] && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((playlistData) => Playlist.fromJson(playlistData))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Create playlist
  Future<Playlist> createPlaylist(String name,
      {String? description, List<String>? songIds}) async {
    try {
      final data = <String, dynamic>{
        'name': name,
      };

      if (description != null) data['description'] = description;
      if (songIds != null) data['songIds'] = songIds;

      final response = await _dio.post(
        '/api/music/playlists',
        data: data,
      );

      return Playlist.fromJson(response.data['playlist']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get playlist details
  Future<Playlist> getPlaylist(String playlistId) async {
    try {
      final response = await _dio.get('/api/music/playlists/$playlistId');
      return Playlist.fromJson(response.data['playlist']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Add song to playlist
  Future<bool> addToPlaylist(String playlistId, String songId) async {
    try {
      final response = await _dio.post(
        '/api/music/playlists/$playlistId/songs',
        data: {
          'songId': songId,
        },
      );

      return response.data['success'] ?? false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Remove song from playlist
  Future<bool> removeFromPlaylist(String playlistId, String songId) async {
    try {
      final response = await _dio.delete(
        '/api/music/playlists/$playlistId/songs/$songId',
      );

      return response.data['success'] ?? false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Log song play
  Future<void> logSongPlay(String songId,
      {int duration = 0, bool completed = false, String? source}) async {
    try {
      await _dio.post(
        '/api/music/log-play',
        data: {
          'songId': songId,
          'duration': duration,
          'completed': completed,
          if (source != null) 'source': source,
        },
      );
    } on DioException catch (e) {
      // Silent fail, but log error
      print('Error logging song play: ${e.message}');
    }
  }

  // Get song details
  Future<Song> getSongDetails(String songId) async {
    try {
      final response = await _dio.get('/api/music/songs/$songId');
      return Song.fromJson(response.data['song']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(DioException e) {
    if (e.response != null) {
      if (e.response!.statusCode == 401) {
        return UnauthorizedException(
            e.response?.data?['error'] ?? 'Unauthorized access');
      }

      if (e.response!.statusCode == 404) {
        return NotFoundException(
            e.response?.data?['error'] ?? 'Resource not found');
      }

      return ServerException(e.response?.data?['error'] ?? 'Server error');
    }

    return NetworkException('Network error: ${e.message}');
  }
}

// Custom exceptions
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}
