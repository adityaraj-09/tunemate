// lib/screens/search/search_screen.dart
import 'package:app/services/di/service_locator.dart';
import 'package:app/services/search_history.dart';
import 'package:app/widgets/home_widgets.dart';
import 'package:app/widgets/search_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../config/theme.dart';
import '../../providers/music_player_provider.dart';
import '../../models/music/song.dart';
import '../../services/api/music_api.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  
  Timer? _debounce;
  bool _isLoading = false;
  String _searchQuery = '';
  Map<String, dynamic> _searchResults = {};
  List<String> _recentSearches = [];
  bool _isLoadingHistory = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward();
    
    // Load search history from local storage
    _loadSearchHistory();
    
    // Focus search field automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });
    
    try {
      final history = await _searchHistoryService.getSearchHistory();
      setState(() {
        _recentSearches = history;
        _isLoadingHistory = false;
      });
    } catch (e) {
      print('Error loading search history: $e');
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }
  
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty && _searchController.text != _searchQuery) {
        _performSearch(_searchController.text);
      } else if (_searchController.text.isEmpty) {
        setState(() {
          _searchQuery = '';
          _searchResults = {};
        });
      }
    });
  }
  
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });
    
    try {
      final musicApi = getIt<MusicApiService>();
      final results = await musicApi.search(query);
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
        
        // Save to search history if results were found
        if (_hasResults(results)) {
          await _searchHistoryService.saveSearchQuery(query);
          // Refresh history
          await _loadSearchHistory();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: ${e.toString()}')),
        );
      }
    }
  }
  
  bool _hasResults(Map<String, dynamic> results) {
    final songs = results['songs'] as List<Song>? ?? [];
    final artists = results['artists'] as List<dynamic>? ?? [];
    final albums = results['albums'] as List<dynamic>? ?? [];
    
    return songs.isNotEmpty || artists.isNotEmpty || albums.isNotEmpty;
  }
  
  void _playSong(Song song) {
    final playerProvider = Provider.of<MusicPlayerProvider>(context, listen: false);
    playerProvider.playSong(song);
  }
  
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchResults = {};
    });
  }
  
  void _onRecentSearchTap(String query) {
    _searchController.text = query;
    _performSearch(query);
  }
  
  Future<void> _clearRecentSearches() async {
    await _searchHistoryService.clearSearchHistory();
    _loadSearchHistory();
  }
  
  Future<void> _removeSearchQuery(String query) async {
    await _searchHistoryService.removeSearchQuery(query);
    _loadSearchHistory();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: child,
            );
          },
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search songs, artists, albums...',
              hintStyle: TextStyle(color: AppTheme.mutedGrey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
            ),
            style: theme.textTheme.bodyLarge,
            textInputAction: TextInputAction.search,
            onSubmitted: _performSearch,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          );
        },
        child: Column(
          children: [
            // Search results
            Expanded(
              child: _isLoading
                  ? _buildLoadingView()
                  : _searchQuery.isEmpty
                      ? _buildRecentSearches()
                      : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading(height: 24, width: 120),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ShimmerLoading(
                    height: 70,
                    borderRadius: 12,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentSearches() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_recentSearches.isNotEmpty)
                TextButton(
                  onPressed: _clearRecentSearches,
                  child: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoadingHistory
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _recentSearches.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                              color: AppTheme.mutedGrey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No recent searches',
                              style: TextStyle(
                                color: AppTheme.mutedGrey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: AnimationLimiter(
                        child: ListView.builder(
                          itemCount: _recentSearches.length,
                          itemBuilder: (context, index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: RecentSearchTile(
                                    query: _recentSearches[index],
                                    onTap: () => _onRecentSearchTap(_recentSearches[index]),
                                    onDelete: () => _removeSearchQuery(_recentSearches[index]),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults() {
    final songs = _searchResults['songs'] as List<Song>? ?? [];
    final artists = _searchResults['artists'] as List<dynamic>? ?? [];
    final albums = _searchResults['albums'] as List<dynamic>? ?? [];
    
    if (songs.isEmpty && artists.isEmpty && albums.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.mutedGrey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "$_searchQuery"',
              style: TextStyle(
                color: AppTheme.mutedGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: AnimationLimiter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Songs section
            if (songs.isNotEmpty) ...[
              Text(
                'Songs',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: SearchResultTile(
                          type: 'song',
                          title: songs[index].name,
                          subtitle: songs[index].artists,
                          imageUrl: songs[index].imageUrl,
                          onTap: () => _playSong(songs[index]),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
            
            // Artists section
            if (artists.isNotEmpty) ...[
              Text(
                'Artists',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: artists.length,
                itemBuilder: (context, index) {
                  final artist = artists[index];
                  return AnimationConfiguration.staggeredList(
                    position: index + songs.length,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: SearchResultTile(
                          type: 'artist',
                          title: artist['name'],
                          subtitle: '${artist['followerCount'] ?? 0} followers',
                          imageUrl: artist['imageUrl'],
                          onTap: () {
                            // Navigate to artist page
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
            
            // Albums section
            if (albums.isNotEmpty) ...[
              Text(
                'Albums',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  final album = albums[index];
                  return AnimationConfiguration.staggeredList(
                    position: index + songs.length + artists.length,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: SearchResultTile(
                          type: 'album',
                          title: album['name'],
                          subtitle: album['artist'],
                          imageUrl: album['imageUrl'],
                          onTap: () {
                            // Navigate to album page
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
            
            // Space at bottom
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}