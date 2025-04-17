// lib/screens/update_location_screen.dart
import 'package:app/models/music/location.dart';
import 'package:app/providers/loc_provider.dart';
import 'package:app/widgets/auth_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import '../config/theme.dart';


class UpdateLocationScreen extends StatefulWidget {
  const UpdateLocationScreen({Key? key}) : super(key: key);

  @override
  State<UpdateLocationScreen> createState() => _UpdateLocationScreenState();
}

class _UpdateLocationScreenState extends State<UpdateLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingCurrentLocation = false;
  String? _errorMessage;
  UserLocation? _currentLocation;
  final _debounceTimer = Timer(Duration.zero, () {});

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _debounceTimer.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final location = await locationProvider.getCurrentLocation();
      
      if (location != null) {
        setState(() {
          _currentLocation = location;
          _latitudeController.text = location.latitude.toString();
          _longitudeController.text = location.longitude.toString();
          _cityController.text = location.city ?? '';
          _stateController.text = location.state ?? '';
          _countryController.text = location.country ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load your current location.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentDeviceLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable in settings.';
          _isLoadingCurrentLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions were denied.';
            _isLoadingCurrentLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied. '
              'Please enable them in app settings.';
          _isLoadingCurrentLocation = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

print("Position: ${position.latitude}, ${position.longitude}");
      // Get address from position
      // List<Placemark> placemarks = await placemarkFromCoordinates(
      //   position.latitude,
      //   position.longitude,
      // );

      // print("Placemark: ${placemarks.length}");

      // if (placemarks.isNotEmpty) {
      //   Placemark place = placemarks[0];
      //   setState(() {
      //     _latitudeController.text = position.latitude.toString();
      //     _longitudeController.text = position.longitude.toString();
        
      //     _cityController.text = place.locality ?? '';
      //     _stateController.text = place.administrativeArea ?? '';
      //     _countryController.text = place.country ?? '';
      //     _isLoadingCurrentLocation = false;
      //   });
      // } else {
        setState(() {
          _latitudeController.text = position.latitude.toString();
          _longitudeController.text = position.longitude.toString();
          _isLoadingCurrentLocation = false;
        });
      // }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get current location: ${e.toString()}';
        _isLoadingCurrentLocation = false;
      });
    }
  }

  Future<void> _updateLocation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      
      final latitude = double.parse(_latitudeController.text);
      final longitude = double.parse(_longitudeController.text);
      
      // If address fields are empty, try to get them from coordinates
      // if (_cityController.text.isEmpty || 
      //     _stateController.text.isEmpty || 
      //     _countryController.text.isEmpty) {
      //   try {
      //     List<Placemark> placemarks = await placemarkFromCoordinates(
      //       latitude,
      //       longitude,
      //     );
          
      //     if (placemarks.isNotEmpty) {
      //       Placemark place = placemarks[0];
      //       _cityController.text = place.locality ?? '';
      //       _stateController.text = place.administrativeArea ?? '';
      //       _countryController.text = place.country ?? '';
      //     }
      //   } catch (_) {
      //     // Ignore geocoding errors
      //   }
      // }
      
      final updatedLocation = await locationProvider.updateLocation(
        latitude: latitude,
        longitude: longitude,
        city: _cityController.text.isNotEmpty ? _cityController.text : null,
        state: _stateController.text.isNotEmpty ? _stateController.text : null,
        country: _countryController.text.isNotEmpty ? _countryController.text : null,
      );
      
      if (updatedLocation != null) {
        setState(() {
          _currentLocation = updatedLocation;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to update location.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating location: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _lookupAddressFromCoordinates() {
    if (_debounceTimer.isActive) {
      _debounceTimer.cancel();
    }

    // Use a debounce to avoid too many geocoding requests
    Timer(const Duration(milliseconds: 1000), () async {
      try {
        final latitude = double.tryParse(_latitudeController.text);
        final longitude = double.tryParse(_longitudeController.text);
        
        if (latitude == null || longitude == null) {
          return;
        }
        
        List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude,
          longitude,
        );
        
        if (placemarks.isNotEmpty && mounted) {
          Placemark place = placemarks[0];
          setState(() {
            _cityController.text = place.locality ?? '';
            _stateController.text = place.administrativeArea ?? '';
            _countryController.text = place.country ?? '';
          });
        }
      } catch (_) {
        // Ignore geocoding errors
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Location',style: TextStyle(color: Colors.white),),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body:  SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current location info
                  if (_currentLocation != null) _buildCurrentLocationCard(),
                  
                  const SizedBox(height: 20),
                  
                  // Get current location button
                  _buildGetCurrentLocationButton(),
                  
                  const SizedBox(height: 24),
                  
                  _buildDivider('Manual Location Update'),
                  
                  const SizedBox(height: 16),
                  
                  // Location update form
                  _buildLocationForm(),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentLocationCard() {
    return Card(
      elevation: 2,
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
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Location',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Last updated: ${_formatDate(_currentLocation!.lastUpdated)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLocationInfoRow(
              'Coordinates',
              '${_currentLocation!.latitude.toStringAsFixed(6)}, ${_currentLocation!.longitude.toStringAsFixed(6)}',
            ),
            if (_currentLocation!.city != null && _currentLocation!.city!.isNotEmpty)
              _buildLocationInfoRow('City', _currentLocation!.city!),
            if (_currentLocation!.state != null && _currentLocation!.state!.isNotEmpty)
              _buildLocationInfoRow('State/Region', _currentLocation!.state!),
            if (_currentLocation!.country != null && _currentLocation!.country!.isNotEmpty)
              _buildLocationInfoRow('Country', _currentLocation!.country!),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
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

  Widget _buildGetCurrentLocationButton() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _isLoadingCurrentLocation ? null : _getCurrentDeviceLocation,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.my_location,
                  color: AppTheme.accentPurple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Use Current Device Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Updates your location based on your device\'s GPS',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoadingCurrentLocation)
                const CircularProgressIndicator()
              else
                const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(String text) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 10.0),
            height: 1.0,
            color: Colors.grey.shade300,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 10.0),
            height: 1.0,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),
            
          // Coordinates
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    prefixIcon: Icon(Icons.public),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter latitude';
                    }
                    final latitude = double.tryParse(value);
                    if (latitude == null) {
                      return 'Invalid number';
                    }
                    if (latitude < -90 || latitude > 90) {
                      return 'Must be -90 to 90';
                    }
                    return null;
                  },
                  onChanged: (_) => _lookupAddressFromCoordinates(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _longitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    prefixIcon: Icon(Icons.public),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter longitude';
                    }
                    final longitude = double.tryParse(value);
                    if (longitude == null) {
                      return 'Invalid number';
                    }
                    if (longitude < -180 || longitude > 180) {
                      return 'Must be -180 to 180';
                    }
                    return null;
                  },
                  onChanged: (_) => _lookupAddressFromCoordinates(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Address fields
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'City',
              prefixIcon: Icon(Icons.location_city),
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _stateController,
            decoration: const InputDecoration(
              labelText: 'State/Region',
              prefixIcon: Icon(Icons.map),
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _countryController,
            decoration: const InputDecoration(
              labelText: 'Country',
              prefixIcon: Icon(Icons.flag),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              isLoading: _isLoading,
              onPressed: (){
                if (!_isLoading) {
                  _updateLocation();
                }
              },
              gradient: AppTheme.primaryGradient,
              text:"Update Location",
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}