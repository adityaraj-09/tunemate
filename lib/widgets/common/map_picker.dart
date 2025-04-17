// lib/widgets/location_map_picker.dart
import 'package:app/models/music/location.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app/config/theme.dart';

class LocationMapPicker extends StatefulWidget {
  final UserLocation? initialLocation;
  final Function(double latitude, double longitude, String? city, String? state, String? country) onLocationSelected;

  const LocationMapPicker({
    Key? key,
    this.initialLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<LocationMapPicker> createState() => _LocationMapPickerState();
}

class _LocationMapPickerState extends State<LocationMapPicker> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  LatLng? _initialLocation;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Location details
  String? _city;
  String? _state;
  String? _country;
  
  // Marker set
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    
    // Set initial location if provided
    if (widget.initialLocation != null) {
      _initialLocation = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _selectedLocation = _initialLocation;
      _city = widget.initialLocation!.city;
      _state = widget.initialLocation!.state;
      _country = widget.initialLocation!.country;
      
      _updateMarker();
    } else {
      // Otherwise try to get current location
      _getCurrentLocation();
    }
  }

  void _updateMarker() {
    if (_selectedLocation == null) return;
    
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation!,
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet: _getLocationSnippet(),
          ),
        ),
      );
    });
  }

  String _getLocationSnippet() {
    List<String> parts = [];
    if (_city != null && _city!.isNotEmpty) parts.add(_city!);
    if (_state != null && _state!.isNotEmpty) parts.add(_state!);
    if (_country != null && _country!.isNotEmpty) parts.add(_country!);
    
    if (parts.isEmpty) {
      return '${_selectedLocation!.latitude.toStringAsFixed(6)}, '
             '${_selectedLocation!.longitude.toStringAsFixed(6)}';
    }
    
    return parts.join(', ');
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled.';
          _isLoading = false;
        });
        return;
      }

      // Check for permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are denied.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied.';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition();
      
      // Get location details
      await _getAddressFromCoordinates(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _initialLocation = _selectedLocation;
        _isLoading = false;
      });
      
      _updateMarker();
      
      // Move camera to current location
      _animateToLocation(_selectedLocation!);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get current location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _city = place.locality;
          _state = place.administrativeArea;
          _country = place.country;
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      // Don't set error state, just leave address fields empty
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Apply custom map style if needed
    // _mapController!.setMapStyle(_mapStyle);
    
    if (_selectedLocation != null) {
      _animateToLocation(_selectedLocation!);
    }
  }

  void _animateToLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 15.0,
        ),
      ),
    );
  }

  void _onMapTap(LatLng location) async {
    setState(() {
      _selectedLocation = location;
      _isLoading = true;
      _city = null;
      _state = null;
      _country = null;
    });
    
    // Update marker immediately
    _updateMarker();
    
    // Get address details
    await _getAddressFromCoordinates(location.latitude, location.longitude);
    
    setState(() {
      _isLoading = false;
    });
    
    // Call the callback
    widget.onLocationSelected(
      location.latitude,
      location.longitude,
      _city,
      _state,
      _country,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map
        _buildMap(),
        
        // Loading indicator
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
        
        // Error message
        if (_errorMessage != null)
          _buildErrorMessage(),
        
        // Current location button
        _buildMyLocationButton(),
        
        // Info panel at bottom
        if (_selectedLocation != null)
          _buildLocationInfoPanel(),
      ],
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _initialLocation ?? const LatLng(0, 0),
        zoom: _initialLocation != null ? 15.0 : 2.0,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      compassEnabled: true,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      onTap: _onMapTap,
    );
  }

  Widget _buildErrorMessage() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMyLocationButton() {
    return Positioned(
      right: 16,
      bottom: _selectedLocation != null ? 160 : 16,
      child: FloatingActionButton(
        heroTag: 'my_location_button',
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        mini: true,
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildLocationInfoPanel() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Selected Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Coordinates: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Getting address...'),
              )
            else ...[
              if (_city != null && _city!.isNotEmpty)
                Text('City: $_city', style: const TextStyle(fontSize: 14)),
              if (_state != null && _state!.isNotEmpty)
                Text('State: $_state', style: const TextStyle(fontSize: 14)),
              if (_country != null && _country!.isNotEmpty)
                Text('Country: $_country', style: const TextStyle(fontSize: 14)),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedLocation != null) {
                    widget.onLocationSelected(
                      _selectedLocation!.latitude,
                      _selectedLocation!.longitude,
                      _city,
                      _state,
                      _country,
                    );
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Confirm Location'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}