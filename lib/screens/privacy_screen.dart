// lib/screens/profile/privacy_settings_screen.dart
import 'package:app/services/api/settings_api.dart';
import 'package:app/widgets/common/error_widgey.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';


class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  _PrivacySettingsScreenState createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _privacySettings = {};
  bool _isUpdating = false;
  
  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }
  
  Future<void> _loadPrivacySettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final settingsApi = Provider.of<SettingsApiService>(context, listen: false);
      final settings = await settingsApi.getPrivacySettings();
      
      setState(() {
        _privacySettings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _updatePrivacySetting(String key, dynamic value) async {
    setState(() {
      _isUpdating = true;
    });
    
    try {
      final settingsApi = Provider.of<SettingsApiService>(context, listen: false);
      await settingsApi.updatePrivacySetting(key, value);
      
      setState(() {
        _privacySettings[key] = value;
        _isUpdating = false;
      });
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating privacy settings: ${e.toString()}')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorView(
                  error: _error!,
                  onRetry: _loadPrivacySettings,
                )
              : _buildPrivacySettingsList(),
    );
  }
  
  Widget _buildPrivacySettingsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Control your privacy settings',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        
        const SizedBox(height: 24),
        
        _buildSwitchTile(
          title: 'Show Last Active Status',
          subtitle: 'Allow others to see when you were last active',
          value: _privacySettings['showLastActive'] ?? true,
          onChanged: (value) => _updatePrivacySetting('showLastActive', value),
        ),
        
        _buildSwitchTile(
          title: 'Show Currently Playing',
          subtitle: 'Allow others to see what you\'re currently listening to',
          value: _privacySettings['showCurrentlyPlaying'] ?? true,
          onChanged: (value) => _updatePrivacySetting('showCurrentlyPlaying', value),
        ),
        
        _buildSwitchTile(
          title: 'Allow Messaging',
          subtitle: 'Allow matches to send you messages',
          value: _privacySettings['allowMessaging'] ?? true,
          onChanged: (value) => _updatePrivacySetting('allowMessaging', value),
        ),
        
        _buildSwitchTile(
          title: 'Show in Discovery',
          subtitle: 'Allow others to discover your profile for matching',
          value: _privacySettings['showInDiscovery'] ?? true,
          onChanged: (value) => _updatePrivacySetting('showInDiscovery', value),
        ),
        
        _buildSwitchTile(
          title: 'Share Listening History',
          subtitle: 'Share your listening history with matches',
          value: _privacySettings['shareListeningHistory'] ?? true,
          onChanged: (value) => _updatePrivacySetting('shareListeningHistory', value),
        ),
        
        const SizedBox(height: 24),
        
        // Blocked users
        ListTile(
          title: const Text('Blocked Users'),
          subtitle: const Text('Manage your blocked users list'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to blocked users screen
            _navigateToBlockedUsers();
          },
        ),
        
        const SizedBox(height: 8),
        
        // Data and privacy
        ListTile(
          title: const Text('Data and Privacy'),
          subtitle: const Text('Manage your data and download a copy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to data and privacy screen
            _navigateToDataPrivacy();
          },
        ),
      ],
    );
  }
  
  void _navigateToBlockedUsers() {
    // Code to navigate to blocked users screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Blocked Users screen coming soon')),
    );
  }

  void _navigateToDataPrivacy() {
    // Code to navigate to data and privacy screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data and Privacy screen coming soon')),
    );
  }
  
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
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
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppTheme.mutedGrey,
            fontSize: 14,
          ),
        ),
        value: value,
        onChanged: _isUpdating ? null : onChanged,
        activeColor: AppTheme.primaryColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }
}