// lib/services/playlist_api_service.dart
import 'package:app/models/music/song.dart';
import 'package:dio/dio.dart';


class PlaylistApiService {
  final Dio _dio;

  PlaylistApiService(this._dio);

  // Create a new playlist
  Future<Playlist> createPlaylist({
    required String name,
    String? description,
    String? imageUrl,
    List<String> songIds = const [],
  }) async {
    try {
      final response = await _dio.post(
        '/api/playlists',
        data: {
          'name': name,
          'description': description,
          'imageUrl': imageUrl,
          'songIds': songIds,
        },
      );

      return Playlist.fromJson(response.data['playlist']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get playlist by ID
  Future<Playlist> getPlaylistById(String id) async {
    try {
      final response = await _dio.get('/api/playlists/$id');
      return Playlist.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get playlist with songs
  Future<Playlist> getPlaylistWithSongs(String id) async {
    try {
      final response = await _dio.get('/api/playlists/get/$id');
      return Playlist.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get user playlists
  Future<List<Playlist>> getUserPlaylists() async {
    try {
      final response = await _dio.get('/api/playlists/user/');
      
      if (response.data != null) {
        return (response.data as List)
            .map((playlistData) => Playlist.fromJson(playlistData))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get popular playlists
  Future<List<Playlist>> getPopularPlaylists({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/api/playlists/popular',
        queryParameters: {'limit': limit},
      );
      
      if (response.data != null) {
        return (response.data as List)
            .map((playlistData) => Playlist.fromJson(playlistData))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update playlist
  Future<Playlist> updatePlaylist({
    required String playlistId,
    String? name,
    String? description,
    String? imageUrl,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (imageUrl != null) data['imageUrl'] = imageUrl;
      
      final response = await _dio.put(
        '/api/playlists/$playlistId',
        data: data,
      );
      
      return Playlist.fromJson(response.data['playlist']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Delete playlist
  Future<bool> deletePlaylist(String playlistId) async {
    try {
      await _dio.delete('/api/playlists/$playlistId');
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Add song to playlist
  Future<Playlist> addSongToPlaylist(String playlistId, String songId) async {
    try {
      final response = await _dio.post(
        '/api/playlists/$playlistId/songs',
        data: {'songId': songId},
      );
      
      return Playlist.fromJson(response.data['playlist']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Add multiple songs to playlist
  Future<Playlist> addSongsToPlaylist(String playlistId, List<String> songIds) async {
    try {
      final response = await _dio.post(
        '/api/playlists/$playlistId/songs/batch',
        data: {'songIds': songIds},
      );
      
      return Playlist.fromJson(response.data['playlist']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Remove song from playlist
  Future<Playlist> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      final response = await _dio.delete('/api/playlists/$playlistId/songs/$songId');
      return Playlist.fromJson(response.data['playlist']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Reorder songs in playlist
  Future<Playlist> reorderPlaylistSongs(String playlistId, List<String> songIds) async {
    try {
      final response = await _dio.put(
        '/api/playlists/$playlistId/reorder',
        data: {'songIds': songIds},
      );
      
      return Playlist.fromJson(response.data['playlist']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Copy a playlist
  Future<Playlist> copyPlaylist(String sourcePlaylistId, {String? newName}) async {
    try {
      final response = await _dio.post(
        '/api/playlists/$sourcePlaylistId/copy',
        data: newName != null ? {'name': newName} : null,
      );
      
      return Playlist.fromJson(response.data['playlist']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Search playlists
  Future<List<Playlist>> searchPlaylists(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/api/playlists/search',
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );
      
      if (response.data != null) {
        return (response.data as List)
            .map((playlistData) => Playlist.fromJson(playlistData))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get user's favorite playlists
  Future<List<Playlist>> getFavoritePlaylists({int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/api/playlists/favorites',
        queryParameters: {'limit': limit},
      );
      
      if (response.data != null) {
        return (response.data as List)
            .map((playlistData) => Playlist.fromJson(playlistData))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Add playlist to favorites
  Future<bool> addToFavorites(String playlistId) async {
    try {
      await _dio.post('/api/playlists/$playlistId/favorite');
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Remove playlist from favorites
  Future<bool> removeFromFavorites(String playlistId) async {
    try {
      await _dio.delete('/api/playlists/$playlistId/favorite');
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


}
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