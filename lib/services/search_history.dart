// lib/services/storage/search_history_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _searchHistoryKey = 'search_history';
  static const int _maxSearchHistoryItems = 20;

  // Save a search query to history
  Future<void> saveSearchQuery(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> searchHistory = await getSearchHistory();
      
      // Remove if already exists (to move it to the top)
      searchHistory.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
      
      // Add to the beginning of the list
      searchHistory.insert(0, query);
      
      // Trim list to max size
      if (searchHistory.length > _maxSearchHistoryItems) {
        searchHistory = searchHistory.sublist(0, _maxSearchHistoryItems);
      }
      
      // Save the updated list
      await prefs.setStringList(_searchHistoryKey, searchHistory);
    } catch (e) {
      print('Error saving search query: $e');
    }
  }

  // Get the search history list
  Future<List<String>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_searchHistoryKey) ?? [];
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  // Clear entire search history
  Future<void> clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_searchHistoryKey);
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  // Remove a specific search query from history
  Future<void> removeSearchQuery(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> searchHistory = await getSearchHistory();
      
      searchHistory.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
      
      await prefs.setStringList(_searchHistoryKey, searchHistory);
    } catch (e) {
      print('Error removing search query: $e');
    }
  }
}