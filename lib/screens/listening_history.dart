// lib/screens/profile/listening_history_screen.dart
import 'package:app/services/api/music_api.dart';
import 'package:app/widgets/common/error_widgey.dart';
import 'package:app/widgets/home_widgets.dart';
import 'package:app/widgets/music_widgets.dart';
import 'package:app/widgets/profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/music_player_provider.dart';
import '../../services/api/profile_api.dart';
import '../../models/music/song.dart';


class ListeningHistoryScreen extends StatefulWidget {
  const ListeningHistoryScreen({Key? key}) : super(key: key);

  @override
  _ListeningHistoryScreenState createState() => _ListeningHistoryScreenState();
}

class _ListeningHistoryScreenState extends State<ListeningHistoryScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _historyItems = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _page = 0;
  final int _pageSize = 20;
  
  @override
  void initState() {
    super.initState();
    _loadHistory();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreHistory();
      }
    }
  }
  
  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _page = 0;
    });
    
    try {
      final profileApi = Provider.of<ProfileApiService>(context, listen: false);
      final history = await profileApi.getListeningHistory(
        limit: _pageSize,
        offset: 0,
      );
      
      setState(() {
        _historyItems = history;
        _isLoading = false;
        _hasMoreData = history.length == _pageSize;
        _page = 1;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadMoreHistory() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      final profileApi = Provider.of<ProfileApiService>(context, listen: false);
      final moreHistory = await profileApi.getListeningHistory(
        limit: _pageSize,
        offset: _page * _pageSize,
      );
      
      setState(() {
        if (moreHistory.isEmpty) {
          _hasMoreData = false;
        } else {
          _historyItems.addAll(moreHistory);
          _page++;
          _hasMoreData = moreHistory.length == _pageSize;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more: ${e.toString()}')),
      );
    }
  }
  
  void _playSong(Song song) {
    final playerProvider = Provider.of<MusicPlayerProvider>(context, listen: false);
    playerProvider.playSong(song);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listening History'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _error != null
              ? ErrorView(
                  error: _error!,
                  onRetry: _loadHistory,
                )
              : _buildHistoryList(),
    );
  }
  
  Widget _buildLoadingView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          10,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ShimmerLoading(
              height: 80,
              borderRadius: 12,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHistoryList() {
    if (_historyItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppTheme.mutedGrey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No listening history yet.\nStart playing some music!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.mutedGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    // Group history by date
    final Map<String, List<dynamic>> groupedHistory = {};
    
    for (final item in _historyItems) {
      final DateTime listenDate = DateTime.parse(item['listenDate']);
      final String dateKey = _getDateKey(listenDate);
      
      if (!groupedHistory.containsKey(dateKey)) {
        groupedHistory[dateKey] = [];
      }
      
      groupedHistory[dateKey]!.add(item);
    }
    
    final sortedDates = groupedHistory.keys.toList()..sort((a, b) => b.compareTo(a));
    
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: AnimationLimiter(
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: sortedDates.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= sortedDates.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            final dateKey = sortedDates[index];
            final items = groupedHistory[dateKey]!;
            
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          _formatDateHeader(dateKey),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      ...items.map((item) {
                        final song = Song.fromJson(item['song']);
                        final DateTime listenDate = DateTime.parse(item['listenDate']);
                        final bool completed = item['completed'] ?? false;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Stack(
                            children: [
                              MusicListTile(
                                song: song,
                                onTap: () => _playSong(song),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Text(
                                  DateFormat.Hm().format(listenDate),
                                  style: TextStyle(
                                    color: AppTheme.mutedGrey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (completed)
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.lightGrey,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Completed',
                                      style: TextStyle(
                                        color: AppTheme.mutedGrey,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  String _formatDateHeader(String dateKey) {
    final now = DateTime.now();
    final today = _getDateKey(now);
    final yesterday = _getDateKey(now.subtract(const Duration(days: 1)));
    
    if (dateKey == today) {
      return 'Today';
    } else if (dateKey == yesterday) {
      return 'Yesterday';
    } else {
      final date = DateFormat('yyyy-MM-dd').parse(dateKey);
      return DateFormat.yMMMd().format(date);
    }
  }
}



class FavoriteSongsScreen extends StatefulWidget {
  const FavoriteSongsScreen({Key? key}) : super(key: key);

  @override
  _FavoriteSongsScreenState createState() => _FavoriteSongsScreenState();
}

class _FavoriteSongsScreenState extends State<FavoriteSongsScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _favoriteSongs = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _page = 0;
  final int _pageSize = 20;
  
  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreFavorites();
      }
    }
  }
  
  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _page = 0;
    });
    
    try {
      final profileApi = Provider.of<ProfileApiService>(context, listen: false);
      final favorites = await profileApi.getFavoriteSongs(
        limit: _pageSize,
        offset: 0,
      );
      
      setState(() {
        _favoriteSongs = favorites;
        _isLoading = false;
        _hasMoreData = favorites.length == _pageSize;
        _page = 1;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadMoreFavorites() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      final profileApi = Provider.of<ProfileApiService>(context, listen: false);
      final moreFavorites = await profileApi.getFavoriteSongs(
        limit: _pageSize,
        offset: _page * _pageSize,
      );
      
      setState(() {
        if (moreFavorites.isEmpty) {
          _hasMoreData = false;
        } else {
          _favoriteSongs.addAll(moreFavorites);
          _page++;
          _hasMoreData = moreFavorites.length == _pageSize;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more: ${e.toString()}')),
      );
    }
  }
  
  void _playSong(Song song) {
    final playerProvider = Provider.of<MusicPlayerProvider>(context, listen: false);
    playerProvider.playSong(song);
  }
  
  Future<void> _unlikeSong(String songId) async {
    try {
      final musicApi = Provider.of<MusicApiService>(context, listen: false);
      final success = await musicApi.unlikeSong(songId);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Song removed from favorites')),
        );
        _loadFavorites();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing song: ${e.toString()}')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Songs'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _error != null
              ? ErrorView(
                  error: _error!,
                  onRetry: _loadFavorites,
                )
              : _buildFavoritesList(),
    );
  }
  
  Widget _buildLoadingView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          10,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ShimmerLoading(
              height: 80,
              borderRadius: 12,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFavoritesList() {
    if (_favoriteSongs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: AppTheme.mutedGrey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No favorite songs yet.\nLike songs to see them here!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.mutedGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: AnimationLimiter(
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _favoriteSongs.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _favoriteSongs.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            final song = Song.fromJson(_favoriteSongs[index]);
            
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Dismissible(
                    key: Key('favorite-${song.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      _unlikeSong(song.id);
                      // Optimistically remove from list
                      setState(() {
                        _favoriteSongs.removeAt(index);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FavoriteSongTile(
                        song: song,
                        onTap: () => _playSong(song),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}