// lib/screens/location_settings_screen.dart
import 'package:app/providers/loc_provider.dart';
import 'package:app/screens/map_loc_screen.dart';
import 'package:app/screens/update_loc.dart';
import 'package:app/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';


class LocationSettingsScreen extends StatelessWidget {
  const LocationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final currentLocation = locationProvider.currentLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Settings'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location info card
            _buildLocationInfoCard(context, currentLocation),

            const SizedBox(height: 24),

            // Update location options
            Text(
              'Update Your Location',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Option cards
            _buildOptionCard(
              context,
              icon: Icons.my_location,
              title: 'Use Current Device Location',
              description: 'Automatically detect your location using GPS',
              iconColor: AppTheme.accentPurple,
              onTap: () => _updateWithCurrentLocation(context),
            ),

            const SizedBox(height: 12),

            _buildOptionCard(
              context,
              icon: Icons.map,
              title: 'Pick on Map',
              description: 'Select your location by tapping on a map',
              iconColor: AppTheme.accentBlue,
              onTap: () => _navigateToMap(context),
            ),

            const SizedBox(height: 12),

            _buildOptionCard(
              context,
              icon: Icons.edit_location_alt,
              title: 'Enter Manually',
              description: 'Provide coordinates and address details manually',
              iconColor: AppTheme.accentTeal,
              onTap: () => _navigateToManualEntry(context),
            ),

            const SizedBox(height: 24),

            // Privacy settings
            Text(
              'Location Privacy',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Privacy card
            _buildPrivacyCard(context),

            const SizedBox(height: 24),

            // Delete location button
            if (currentLocation != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline,
                      color: AppTheme.errorColor),
                  label: const Text('Delete Location Data'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: const BorderSide(color: AppTheme.errorColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _confirmDeleteLocation(context),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfoCard(BuildContext context, dynamic currentLocation) {
    if (currentLocation == null) {
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.location_off,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No Location Set',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Set your location to find music lovers near you',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GradientButton(
                onPressed: () => _updateWithCurrentLocation(context),
                gradient: AppTheme.primaryGradient,
                text: 'Set Location',
              ),
            ],
          ),
        ),
      );
    }

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
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Location',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getLocationDisplayText(currentLocation),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Coordinates',
                        style: TextStyle(
                          color: AppTheme.mutedGrey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currentLocation.latitude.toStringAsFixed(6)}, ${currentLocation.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    final coordsText =
                        '${currentLocation.latitude.toStringAsFixed(6)}, ${currentLocation.longitude.toStringAsFixed(6)}';
                    // Copy to clipboard
                  },
                  tooltip: 'Copy coordinates',
                ),
              ],
            ),
            if (currentLocation.city != null ||
                currentLocation.state != null ||
                currentLocation.country != null) ...[
              const SizedBox(height: 12),
              if (currentLocation.city != null &&
                  currentLocation.city!.isNotEmpty)
                _buildLocationDetailItem('City', currentLocation.city!),
              if (currentLocation.state != null &&
                  currentLocation.state!.isNotEmpty)
                _buildLocationDetailItem(
                    'State/Region', currentLocation.state!),
              if (currentLocation.country != null &&
                  currentLocation.country!.isNotEmpty)
                _buildLocationDetailItem('Country', currentLocation.country!),
            ],
            const SizedBox(height: 16),
            Text(
              'Last updated: ${_formatDateTime(currentLocation.lastUpdated)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.mutedGrey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.mutedGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.visibility,
                    color: AppTheme.accentPink,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Location Visibility',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Control who can see your location and how precise it is.',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            // Distance visibility toggle
            SwitchListTile(
              title: const Text('Show distance to others'),
              subtitle: const Text('Allow others to see how far away you are'),
              value: true, // Connect to actual setting
              onChanged: (value) {
                // Update setting
              },
              contentPadding: EdgeInsets.zero,
            ),

            // Approximate location toggle
            SwitchListTile(
              title: const Text('Use approximate location'),
              subtitle: const Text(
                  'Show only general area instead of exact location'),
              value: false, // Connect to actual setting
              onChanged: (value) {
                // Update setting
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateWithCurrentLocation(BuildContext context) async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    if (!locationProvider.locationPermissionGranted) {
      final granted = await locationProvider.requestLocationPermission();
      if (!granted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Location permission is required to update your location'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    if (context.mounted) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Updating location...'),
            ],
          ),
        ),
      );

      try {
        final location =
            await locationProvider.updateWithCurrentDevicePosition();

        if (context.mounted) {
          // Close dialog
          Navigator.pop(context);

          if (location != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(locationProvider.error ?? 'Failed to update location'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          // Close dialog
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating location: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _navigateToMap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapLocationScreen()),
    );
  }

  void _navigateToManualEntry(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UpdateLocationScreen()),
    );
  }

  Future<void> _confirmDeleteLocation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location Data'),
        content: const Text(
          'Are you sure you want to delete your location data? '
          'This will affect your ability to match with nearby users.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Deleting location data...'),
            ],
          ),
        ),
      );

      try {
        final success = await locationProvider.deleteLocation();

        if (context.mounted) {
          // Close dialog
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Location data deleted successfully'
                    : 'Failed to delete location data',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          // Close dialog
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting location: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _getLocationDisplayText(dynamic location) {
    List<String> parts = [];

    if (location.city != null && location.city!.isNotEmpty) {
      parts.add(location.city!);
    }

    if (location.state != null && location.state!.isNotEmpty) {
      parts.add(location.state!);
    }

    if (location.country != null && location.country!.isNotEmpty) {
      parts.add(location.country!);
    }

    if (parts.isEmpty) {
      return 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}';
    }

    return parts.join(', ');
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        final minutes = difference.inMinutes;
        return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
      }
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }
}
