// lib/screens/profile/settings_screen.dart
import 'package:app/screens/privacy_screen.dart';
import 'package:app/screens/signup_screen.dart';
import 'package:app/services/api/settings_api.dart';
import 'package:app/services/di/service_locator.dart';
import 'package:app/widgets/auth_widgets.dart';
import 'package:app/widgets/common/error_widgey.dart';
import 'package:app/widgets/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _settings = {};
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final settingsApi = getIt<SettingsApiService>();
      final settings = await settingsApi.getSettings();

      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final settingsApi = getIt<SettingsApiService>();
      await settingsApi.updateSetting(key, value);

      setState(() {
        _settings[key] = value;
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings updated successfully')),
      );
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating settings: ${e.toString()}')),
      );
    }
  }

  Future<void> _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();

    // Navigate to login screen
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: _buildSettingsList(),
    );
  }

  Widget _buildLoadingView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading(height: 24, width: 150),
          const SizedBox(height: 16),
          ...List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ShimmerLoading(
                height: 60,
                borderRadius: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const ShimmerLoading(height: 24, width: 180),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ShimmerLoading(
                height: 60,
                borderRadius: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return AnimationLimiter(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: [
            // Account section
            _buildSectionHeader('Account'),

            _buildSettingCard(
              title: 'Update Location',
              subtitle: 'Find matches near you',
              onTap: (){
                context.go("/location");
              }
            ),   _buildSettingCard(
              title: 'Update Preferences',
              subtitle: 'Find matches near you',
              onTap: (){
                context.go("/preferences");
              }
            ),  _buildSettingCard(
              title: 'Email Notifications',
              subtitle: 'Receive email updates and notifications',
              trailing: Switch(
                value: _settings['emailNotifications'] ?? true,
                onChanged: (value) =>
                    _updateSetting('emailNotifications', value),
                activeColor: AppTheme.primaryColor,
              ),
            ),

            _buildSettingCard(
              title: 'Push Notifications',
              subtitle: 'Receive push notifications on this device',
              trailing: Switch(
                value: _settings['pushNotifications'] ?? true,
                onChanged: (value) =>
                    _updateSetting('pushNotifications', value),
                activeColor: AppTheme.primaryColor,
              ),
            ),

            _buildSettingCard(
              title: 'Profile Visibility',
              subtitle: 'Control who can see your profile',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to profile visibility settings
                _showVisibilityOptions();
              },
            ),

            _buildSettingCard(
              title: 'Account Privacy',
              subtitle: 'Manage your account privacy settings',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to account privacy settings
                _showPrivacyOptions();
              },
            ),

            // Music section
            _buildSectionHeader('Music'),

            _buildSettingCard(
              title: 'Audio Quality',
              subtitle: 'Set streaming and download quality',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show audio quality options
                _showAudioQualityOptions();
              },
            ),

            _buildSettingCard(
              title: 'Download Over Wi-Fi Only',
              subtitle: 'Only download music when connected to Wi-Fi',
              trailing: Switch(
                value: _settings['downloadOverWifiOnly'] ?? true,
                onChanged: (value) =>
                    _updateSetting('downloadOverWifiOnly', value),
                activeColor: AppTheme.primaryColor,
              ),
            ),

            _buildSettingCard(
              title: 'Normalize Volume',
              subtitle: 'Maintain consistent volume across tracks',
              trailing: Switch(
                value: _settings['normalizeVolume'] ?? true,
                onChanged: (value) => _updateSetting('normalizeVolume', value),
                activeColor: AppTheme.primaryColor,
              ),
            ),

            _buildSettingCard(
              title: 'Equalizer',
              subtitle: 'Customize your sound',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to equalizer
              },
            ),

            // Matching section
            _buildSectionHeader('Matching'),

            _buildSettingCard(
              title: 'Matching Preferences',
              subtitle: 'Set your music matching preferences',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to matching preferences
              },
            ),

            _buildSettingCard(
              title: 'Location',
              subtitle: 'Set location preferences for matching',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to location settings
              },
            ),

            // App section
            _buildSectionHeader('App'),

            _buildSettingCard(
              title: 'Theme',
              subtitle: 'Change app appearance',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show theme options
                _showThemeOptions();
              },
            ),

            _buildSettingCard(
              title: 'Language',
              subtitle: 'Change app language',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show language options
                _showLanguageOptions();
              },
            ),

            _buildSettingCard(
              title: 'Clear Cache',
              subtitle: 'Free up storage space',
              trailing: const Icon(Icons.cleaning_services),
              onTap: () {
                // Show clear cache confirmation
                _showClearCacheConfirmation();
              },
            ),

            // About section
            _buildSectionHeader('About'),

            _buildSettingCard(
              title: 'Terms of Service',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to terms of service
              },
            ),

            _buildSettingCard(
              title: 'Privacy Policy',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to privacy policy
              },
            ),

            _buildSettingCard(
              title: 'App Version',
              subtitle: 'v1.0.0 (Build 100)',
              trailing: null,
            ),

            const SizedBox(height: 24),

            // Logout button
            GradientButton(
              onPressed: () {
                _showSignOutConfirmation();
              },
              gradient: LinearGradient(
                colors: [Colors.grey.shade400, Colors.grey.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              text: 'Sign Out',
            ),

            const SizedBox(height: 16),

            // Delete account button
            OutlinedButton(
              onPressed: () {
                _showDeleteAccountConfirmation();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Delete Account'),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  // lib/screens/profile/settings_screen.dart - Fix for the subtitle text part

  Widget _buildSettingCard({
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: AppTheme.mutedGrey,
                  fontSize: 14,
                ),
              )
            : null,
        trailing: _isUpdating
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : trailing,
        onTap: onTap,
      ),
    );
  }

  // lib/screens/profile/settings_screen.dart - Completing the methods

  // These methods need to be added to complete the SettingsScreen class

  void _showVisibilityOptions() {
    final currentVisibility = _settings['profileVisibility'] ?? 'public';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Profile Visibility',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Choose who can see your profile and music taste',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.mutedGrey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildRadioTile(
              title: 'Public',
              subtitle: 'Everyone can see your profile',
              value: 'public',
              groupValue: currentVisibility,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  _updateSetting('profileVisibility', value);
                }
              },
            ),
            _buildRadioTile(
              title: 'Matches Only',
              subtitle: 'Only your matches can see your full profile',
              value: 'matches',
              groupValue: currentVisibility,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  _updateSetting('profileVisibility', value);
                }
              },
            ),
            _buildRadioTile(
              title: 'Private',
              subtitle: 'Only you can see your profile',
              value: 'private',
              groupValue: currentVisibility,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  _updateSetting('profileVisibility', value);
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showPrivacyOptions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacySettingsScreen(),
      ),
    );
  }

  void _showAudioQualityOptions() {
    final currentQuality = _settings['audioQuality'] ?? 'auto';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Audio Quality',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Higher quality uses more data and storage',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.mutedGrey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildRadioTile(
              title: 'Auto',
              subtitle: 'Adjusts based on your network connection',
              value: 'auto',
              groupValue: currentQuality,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  _updateSetting('audioQuality', value);
                }
              },
            ),
            _buildRadioTile(
              title: 'Low (96 kbps)',
              subtitle: 'Uses less data',
              value: 'low',
              groupValue: currentQuality,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  _updateSetting('audioQuality', value);
                }
              },
            ),
            _buildRadioTile(
              title: 'Medium (160 kbps)',
              subtitle: 'Balanced quality and data usage',
              value: 'medium',
              groupValue: currentQuality,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  _updateSetting('audioQuality', value);
                }
              },
            ),
            _buildRadioTile(
              title: 'High (320 kbps)',
              subtitle: 'Best quality, uses more data',
              value: 'high',
              groupValue: currentQuality,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  _updateSetting('audioQuality', value);
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showThemeOptions() {
    final currentTheme = _settings['theme'] ?? 'system';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Theme',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRadioTile(
              title: 'System',
              subtitle: 'Follows your device theme',
              value: 'system',
              groupValue: currentTheme,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  _updateSetting('theme', value);
                }
              },
            ),
            _buildRadioTile(
              title: 'Light',
              subtitle: 'Light theme',
              value: 'light',
              groupValue: currentTheme,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  _updateSetting('theme', value);
                }
              },
            ),
            _buildRadioTile(
              title: 'Dark',
              subtitle: 'Dark theme',
              value: 'dark',
              groupValue: currentTheme,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  _updateSetting('theme', value);
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showLanguageOptions() {
    final currentLanguage = _settings['language'] ?? 'en';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildRadioTile(
                    title: 'English',
                    value: 'en',
                    groupValue: currentLanguage,
                    onChanged: (value) {
                      Navigator.pop(context);
                      if (value != null) {
                        _updateSetting('language', value);
                      }
                    },
                  ),
                  _buildRadioTile(
                    title: 'Spanish',
                    value: 'es',
                    groupValue: currentLanguage,
                    onChanged: (value) {
                      Navigator.pop(context);
                      if (value != null) {
                        _updateSetting('language', value);
                      }
                    },
                  ),
                  _buildRadioTile(
                    title: 'French',
                    value: 'fr',
                    groupValue: currentLanguage,
                    onChanged: (value) {
                      Navigator.pop(context);
                      if (value != null) {
                        _updateSetting('language', value);
                      }
                    },
                  ),
                  _buildRadioTile(
                    title: 'German',
                    value: 'de',
                    groupValue: currentLanguage,
                    onChanged: (value) {
                      Navigator.pop(context);
                      if (value != null) {
                        _updateSetting('language', value);
                      }
                    },
                  ),
                  _buildRadioTile(
                    title: 'Japanese',
                    value: 'ja',
                    groupValue: currentLanguage,
                    onChanged: (value) {
                      Navigator.pop(context);
                      if (value != null) {
                        _updateSetting('language', value);
                      }
                    },
                  ),
                  _buildRadioTile(
                    title: 'Korean',
                    value: 'ko',
                    groupValue: currentLanguage,
                    onChanged: (value) {
                      Navigator.pop(context);
                      if (value != null) {
                        _updateSetting('language', value);
                      }
                    },
                  ),
                  _buildRadioTile(
                    title: 'Portuguese',
                    value: 'pt',
                    groupValue: currentLanguage,
                    onChanged: (value) {
                      Navigator.pop(context);
                      if (value != null) {
                        _updateSetting('language', value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
            'This will clear all cached data. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear cache logic
              _updateSetting('clearCache', true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all your data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              // Delete account logic
              _deleteAccount();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final settingsApi =
          Provider.of<SettingsApiService>(context, listen: false);
      await settingsApi.deleteAccount();

      // Sign out
      await _signOut();
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: ${e.toString()}')),
      );
    }
  }

  Widget _buildRadioTile({
    required String title,
    String? subtitle,
    required String value,
    required String groupValue,
    required Function(String?) onChanged,
  }) {
    return RadioListTile<String>(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
