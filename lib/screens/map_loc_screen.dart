// lib/screens/map_location_screen.dart
import 'package:app/providers/loc_provider.dart';
import 'package:app/widgets/common/map_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';


class MapLocationScreen extends StatefulWidget {
  const MapLocationScreen({Key? key}) : super(key: key);

  @override
  State<MapLocationScreen> createState() => _MapLocationScreenState();
}

class _MapLocationScreenState extends State<MapLocationScreen> {
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final currentLocation = locationProvider.currentLocation;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location on Map'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body: Column(
        children: [
          // Info bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey[100],
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppTheme.mutedGrey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap on the map to set your location. This helps us find music lovers near you.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Map takes remaining space
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : LocationMapPicker(
                    initialLocation: currentLocation,
                    onLocationSelected: _handleLocationSelected,
                  ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _handleLocationSelected(
    double latitude,
    double longitude,
    String? city,
    String? state,
    String? country,
  ) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      
      final updatedLocation = await locationProvider.updateLocation(
        latitude: latitude,
        longitude: longitude,
        city: city,
        state: state,
        country: country,
      );
      
      if (updatedLocation != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating location: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}