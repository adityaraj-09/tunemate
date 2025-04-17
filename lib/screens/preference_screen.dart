// lib/screens/preference_screen.dart
import 'package:app/models/music/user_pref.dart';
import 'package:app/providers/pref_provider.dart';
import 'package:app/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';


class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({Key? key}) : super(key: key);

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  // Selected values for the form
  GenderPreference? _selectedGender;
  String? _customGender;
  RangeValues _ageRange = const RangeValues(18, 40);
  double _maxDistance = 50;
  bool _isVisible = true;
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeValues();
    });
  }
  
  // Initialize form values from provider
  void _initializeValues() {
    final provider = Provider.of<UserPreferenceProvider>(context, listen: false);
    final preferences = provider.preferences;
    
    if (preferences != null) {
      setState(() {
        _selectedGender = preferences.preferredGender;
        _customGender = preferences.customGenderPreference;
        _ageRange = RangeValues(
          preferences.minAge?.toDouble() ?? 18,
          preferences.maxAge?.toDouble() ?? 40,
        );
        _maxDistance = preferences.maxDistance?.toDouble() ?? 50;
        _isVisible = preferences.isVisible;
      });
    }
  }
  
  // Save preferences
  Future<void> _savePreferences() async {
    final provider = Provider.of<UserPreferenceProvider>(context, listen: false);
    
    try {
      await provider.updatePreferences(
        preferredGender: _selectedGender,
        customGenderPreference: _selectedGender == GenderPreference.custom ? _customGender : null,
        minAge: _ageRange.start.round(),
        maxAge: _ageRange.end.round(),
        maxDistance: _maxDistance.round(),
        isVisible: _isVisible,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved successfully'))
        );
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preferences: $e'))
        );
      }
    }
  }
  
  // Reset preferences to defaults
  Future<void> _resetPreferences() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Preferences'),
        content: const Text('Are you sure you want to reset all preferences to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      final provider = Provider.of<UserPreferenceProvider>(context, listen: false);
      
      try {
        await provider.resetPreferences();
        _initializeValues();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preferences reset to defaults'))
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error resetting preferences: $e'))
          );
        }
      }
    }
  }
  
  // Load AI recommendations
  Future<void> _loadRecommendations() async {
    final provider = Provider.of<UserPreferenceProvider>(context, listen: false);
    
    try {
      await provider.loadRecommendations();
      
      if (provider.recommendations != null && mounted) {
        _showRecommendationsDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recommendations: $e'))
        );
      }
    }
  }
  
  // Show dialog with recommendations
  void _showRecommendationsDialog() {
    final provider = Provider.of<UserPreferenceProvider>(context, listen: false);
    final recommendations = provider.recommendations;
    
    if (recommendations == null || recommendations['recommendations'] == null) {
      return;
    }
    
    final recommendedPrefs = recommendations['recommendations'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Music Preference Match'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Based on your music taste, we recommend:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              _buildRecommendationItem(
                'Age Range', 
                '${recommendedPrefs['minAge']} - ${recommendedPrefs['maxAge']} years'
              ),
              _buildRecommendationItem(
                'Max Distance', 
                '${recommendedPrefs['maxDistance']} km'
              ),
              const SizedBox(height: 16),
              Text(
                recommendations['explanation'] ?? 'Our AI analyzed your music preferences and found these settings might help you find more compatible matches.',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ignore'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.applyRecommendations();
              _initializeValues();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecommendationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferenceProvider>(
      builder: (context, provider, child) {
        final preferences = provider.preferences;
        final isLoading = provider.isLoading;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Matching Preferences',style: TextStyle(color: Colors.white),),
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
            ),
            actions: [
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset to defaults',
                  onPressed: _resetPreferences,
                ),
              IconButton(
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                tooltip: _isEditing ? 'Save changes' : 'Edit preferences',
                onPressed: () {
                  if (_isEditing) {
                    _savePreferences();
                  } else {
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
              ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI Recommendation button
                      if (!_isEditing)
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentPurple.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.music_note,
                                        color: AppTheme.accentPurple,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Music-Based Recommendations',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Let our AI suggest matching preferences based on your music taste',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                GradientButton(
                                  onPressed: _loadRecommendations,
                                  gradient: AppTheme.secondaryGradient,
                                  text: 'Get Music-Based Recommendations',
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (!_isEditing && preferences != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Current Preferences',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildPreferencesSummary(context, preferences),
                      ] else ...[
                        const SizedBox(height: 24),
                        Text(
                          'I want to see:',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildGenderPreferenceSelector(),
                        
                        const SizedBox(height: 24),
                        Text(
                          'Age Range',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        _buildAgeRangeSelector(),
                        
                        const SizedBox(height: 24),
                        Text(
                          'Maximum Distance',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        _buildDistanceSelector(),
                        
                        const SizedBox(height: 24),
                        Text(
                          'Privacy',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        _buildPrivacySettings(),
                        
                        const SizedBox(height: 24),
                        GradientButton(
                          onPressed: _savePreferences,
                          gradient: AppTheme.primaryGradient,
                          text:'Save Preferences',
                        ),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }
  
  // Build summary card for non-editing mode
  Widget _buildPreferencesSummary(BuildContext context, UserPreference preferences) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: AppTheme.primaryColor),
              title: const Text('Looking for'),
              subtitle: Text(
                preferences.getGenderPreferenceDisplay(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              dense: true,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cake, color: AppTheme.accentBlue),
              title: const Text('Age Range'),
              subtitle: Text(
                preferences.getAgeRangeDisplay(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              dense: true,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.place, color: AppTheme.accentTeal),
              title: const Text('Distance'),
              subtitle: Text(
                preferences.getDistanceDisplay(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              dense: true,
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                preferences.isVisible ? Icons.visibility : Icons.visibility_off,
                color: preferences.isVisible ? AppTheme.accentPurple : Colors.grey,
              ),
              title: const Text('Profile Visibility'),
              subtitle: Text(
                preferences.isVisible ? 'Visible to others' : 'Hidden from others',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              dense: true,
            ),
          ],
        ),
      ),
    );
  }
  
  // Build gender preference selector
  Widget _buildGenderPreferenceSelector() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGenderOption(GenderPreference.male, 'Men'),
            _buildGenderOption(GenderPreference.female, 'Women'),
            _buildGenderOption(GenderPreference.nonBinary, 'Non-binary People'),
            _buildGenderOption(GenderPreference.any, 'Everyone'),
            _buildGenderOption(GenderPreference.custom, 'Custom'),
            
            if (_selectedGender == GenderPreference.custom)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Specify gender preferences',
                    hintText: 'e.g. Genderfluid, Bigender',
                    border: OutlineInputBorder(),
                  ),
                
                  onChanged: (value) {
                    setState(() {
                      _customGender = value;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Build individual gender option
  Widget _buildGenderOption(GenderPreference preference, String label) {
    return RadioListTile<GenderPreference>(
      title: Text(label),
      value: preference,
      groupValue: _selectedGender,
      activeColor: AppTheme.primaryColor,
      onChanged: (GenderPreference? value) {
        setState(() {
          _selectedGender = value;
        });
      },
    );
  }
  
  // Build age range selector
  Widget _buildAgeRangeSelector() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_ageRange.start.round()} years',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_ageRange.end.round()} years',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RangeSlider(
              values: _ageRange,
              min: 18,
              max: 100,
              divisions: 82,
              labels: RangeLabels(
                _ageRange.start.round().toString(),
                _ageRange.end.round().toString(),
              ),
              activeColor: AppTheme.primaryColor,
              inactiveColor: Colors.grey[300],
              onChanged: (RangeValues values) {
                setState(() {
                  _ageRange = values;
                });
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('18'),
                Text('100'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Build distance selector
  Widget _buildDistanceSelector() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Within ${_maxDistance.round()} kilometers',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _maxDistance,
              min: 1,
              max: 300,
              divisions: 29,
              label: _maxDistance.round().toString(),
              activeColor: AppTheme.primaryColor,
              inactiveColor: Colors.grey[300],
              onChanged: (double value) {
                setState(() {
                  _maxDistance = value;
                });
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('1 km'),
                Text('300 km'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Build privacy settings
  Widget _buildPrivacySettings() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Profile Visibility'),
              subtitle: const Text(
                'When disabled, your profile won\'t be shown to other users',
              ),
              value: _isVisible,
              activeColor: AppTheme.primaryColor,
              onChanged: (bool value) {
                setState(() {
                  _isVisible = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}