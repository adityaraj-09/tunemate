// lib/providers/music_preferences_provider.dart
import 'package:app/models/music/music_prefernces.dart';
import 'package:app/services/api/preference_api.dart';
import 'package:flutter/foundation.dart';


class MusicPreferencesProvider with ChangeNotifier {
  final PreferenceApiService _musicApiService;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  List<MusicPreference> _languages = [];
  List<MusicPreference> get languages => _languages;
  
  List<MusicPreference> _genres = [];
  List<MusicPreference> get genres => _genres;
  
  List<MusicPreference> _artists = [];
  List<MusicPreference> get artists => _artists;
  
  List<MusicPreference> _searchedArtists = [];
  List<MusicPreference> get searchedArtists => _searchedArtists;
  
  MusicPreferencesProvider(this._musicApiService);
  
  // Fetch all available languages
  Future<void> fetchLanguages() async {
    _setLoading(true);
    _clearError();
    
    try {
      _languages = await _musicApiService.getAvailableLanguages();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Fetch all available genres
  Future<void> fetchGenres() async {
    _setLoading(true);
    _clearError();
    
    try {
      _genres = await _musicApiService.getAvailableGenres();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Fetch popular artists as initial suggestions
  Future<void> fetchPopularArtists() async {
    _setLoading(true);
    _clearError();
    
    try {
      _artists = await _musicApiService.getAvailableArtists();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Search artists by name
  Future<void> searchArtists(String query) async {
    if (query.isEmpty) {
      _searchedArtists = [];
      notifyListeners();
      return;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      _searchedArtists = await _musicApiService.searchArtists(query);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Toggle language selection
  void toggleLanguage(String languageId) {
    final index = _languages.indexWhere((lang) => lang.id == languageId);
    if (index != -1) {
      _languages[index].isSelected = !_languages[index].isSelected;
      notifyListeners();
    }
  }
  
  // Toggle genre selection
  void toggleGenre(String genreId) {
    final index = _genres.indexWhere((genre) => genre.id == genreId);
    if (index != -1) {
      _genres[index].isSelected = !_genres[index].isSelected;
      notifyListeners();
    }
  }
  
  // Toggle artist selection
  void toggleArtist(String artistId) {
    // Check in main artists list
    var index = _artists.indexWhere((artist) => artist.id == artistId);
    if (index != -1) {
      _artists[index].isSelected = !_artists[index].isSelected;
      notifyListeners();
      return;
    }
    
    // Check in searched artists list
    index = _searchedArtists.indexWhere((artist) => artist.id == artistId);
    if (index != -1) {
      _searchedArtists[index].isSelected = !_searchedArtists[index].isSelected;
      
      // If artist is selected, add to main list if not already there
      if (_searchedArtists[index].isSelected) {
        final existsInMainList = _artists.any((a) => a.id == artistId);
        if (!existsInMainList) {
          _artists.add(_searchedArtists[index]);
        }
      }
      
      notifyListeners();
    }
  }
  
  // Get all selected preferences
  MusicPreferences getSelectedPreferences() {
    return MusicPreferences(
      languages: _languages.where((lang) => lang.isSelected).toList(),
      genres: _genres.where((genre) => genre.isSelected).toList(),
      artists: _artists.where((artist) => artist.isSelected).toList(),
    );
  }
  
  // Save music preferences to backend
  Future<bool> saveMusicPreferences() async {
    _setLoading(true);
    _clearError();
    
    try {
      final preferences = getSelectedPreferences();
      await _musicApiService.updateMusicPreferences(preferences);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}