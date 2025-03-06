// lib/screens/onboarding/music_preferences_screen.dart
import 'package:app/providers/preference_provider.dart';
import 'package:app/widgets/auth_widgets.dart';
import 'package:app/widgets/common/prefernce_chip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';


class MusicPreferencesScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const MusicPreferencesScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  _MusicPreferencesScreenState createState() => _MusicPreferencesScreenState();
}

class _MusicPreferencesScreenState extends State<MusicPreferencesScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _pageIndicators = [
    "Languages",
    "Genres",
    "Artists"
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final provider = Provider.of<MusicPreferencesProvider>(context, listen: false);
    await provider.fetchLanguages();
    await provider.fetchGenres();
    await provider.fetchPopularArtists();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveMusicPreferences();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveMusicPreferences() async {
    final provider = Provider.of<MusicPreferencesProvider>(context, listen: false);
    final success = await provider.saveMusicPreferences();
    
    if (success) {
      widget.onComplete();
    } else {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to save preferences'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MusicPreferencesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && 
              provider.languages.isEmpty && 
              provider.genres.isEmpty && 
              provider.artists.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildProgressIndicator(provider),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      _buildLanguagesPage(provider),
                      _buildGenresPage(provider),
                      _buildArtistsPage(provider),
                    ],
                  ),
                ),
                _buildNavigationButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Music Taste',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let us know what you love to listen to so we can find your perfect music match.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedGrey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(MusicPreferencesProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _pageIndicators.asMap().entries.map((entry) {
          int index = entry.key;
          String label = entry.value;
          
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: _currentPage == index 
                          ? AppTheme.primaryColor 
                          : AppTheme.mutedGrey,
                      fontWeight: _currentPage == index 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: _currentPage == index 
                          ? AppTheme.primaryColor 
                          : AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLanguagesPage(MusicPreferencesProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Which languages do you prefer to listen to?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Select all that apply',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedGrey,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: provider.languages.isEmpty
                ? const Center(child: Text('No languages available'))
                : Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: provider.languages.map((language) {
                      return PreferenceChip(
                        label: language.name,
                        isSelected: language.isSelected,
                        onSelected: () {
                          provider.toggleLanguage(language.id);
                        },
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenresPage(MusicPreferencesProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What genres do you enjoy?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Select at least 3 genres',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedGrey,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: provider.genres.isEmpty
                ? const Center(child: Text('No genres available'))
                : Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: provider.genres.map((genre) {
                      return PreferenceChip(
                        label: genre.name,
                        isSelected: genre.isSelected,
                        onSelected: () {
                          provider.toggleGenre(genre.id);
                        },
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistsPage(MusicPreferencesProvider provider) {
    final selectedArtistsCount = provider.artists.where((a) => a.isSelected).length;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Who are your favorite artists?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Select at least 5 artists',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedGrey,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for artists',
                prefixIcon: const Icon(Icons.search, color: AppTheme.mutedGrey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                provider.searchArtists(value);
              },
            ),
          ),
          const SizedBox(height: 16),
          if (provider.isLoading && _searchController.text.isNotEmpty)
            const Center(child: CircularProgressIndicator())
          else if (_searchController.text.isNotEmpty && provider.searchedArtists.isEmpty)
            const Center(child: Text('No artists found'))
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedArtistsCount > 0) ...[
                    Text(
                      'Selected Artists (${selectedArtistsCount})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      children: provider.artists
                          .where((artist) => artist.isSelected)
                          .map((artist) {
                        return PreferenceChip(
                          label: artist.name,
                          isSelected: true,
                          onSelected: () {
                            provider.toggleArtist(artist.id);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  Text(
                    _searchController.text.isEmpty ? 'Popular Artists' : 'Search Results',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 12,
                        children: (_searchController.text.isEmpty
                                ? provider.artists.where((a) => !a.isSelected)
                                : provider.searchedArtists)
                            .map((artist) {
                          return PreferenceChip(
                            label: artist.name,
                            isSelected: artist.isSelected,
                            onSelected: () {
                              provider.toggleArtist(artist.id);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isLastPage = _currentPage == 2;
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentPage > 0
              ? TextButton.icon(
                  onPressed: _previousPage,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                )
              : const SizedBox(width: 100),
          GradientButton(
            onPressed: _nextPage,
            gradient: AppTheme.primaryGradient,
            text:
              isLastPage ? 'Finish' : 'Next',
            
          ),
        ],
      ),
    );
  }
}