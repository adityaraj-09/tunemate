// lib/models/user_location.dart
import 'package:equatable/equatable.dart';

/// Model representing a user's geographical location
class UserLocation extends Equatable {
  /// Unique identifier for this location entry
  final String id;
  
  /// ID of the user this location belongs to
  final String userId;
  
  /// Latitude coordinate
  final double latitude;
  
  /// Longitude coordinate
  final double longitude;
  
  /// City name (optional)
  final String? city;
  
  /// State or province name (optional)
  final String? state;
  
  /// Country name (optional)
  final String? country;
  
  /// When this location was last updated
  final DateTime lastUpdated;

  /// Constructor
  const UserLocation({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.city,
    this.state,
    this.country,
    required this.lastUpdated,
  });

  /// Create a UserLocation from JSON data
  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      id: json['id'] ?? json['location_id'],
      userId: json['userId'] ?? json['user_id'],
      latitude: (json['latitude'] is String) 
          ? double.parse(json['latitude']) 
          : json['latitude'].toDouble(),
      longitude: (json['longitude'] is String) 
          ? double.parse(json['longitude']) 
          : json['longitude'].toDouble(),
      city: json['city'],
      state: json['state'],
      country: json['country'],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : json['last_updated'] != null
              ? DateTime.parse(json['last_updated'])
              : DateTime.now(),
    );
  }

  /// Convert this UserLocation to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'country': country,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
  
  /// Create a copy of this UserLocation with some fields replaced
  UserLocation copyWith({
    String? id,
    String? userId,
    double? latitude,
    double? longitude,
    String? city,
    String? state,
    String? country,
    DateTime? lastUpdated,
  }) {
    return UserLocation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
    id, 
    userId, 
    latitude, 
    longitude, 
    city, 
    state, 
    country, 
    lastUpdated
  ];
}

/// Model representing a nearby user with distance information
class NearbyUser extends Equatable {
  /// ID of the user
  final String userId;
  
  /// Username
  final String username;
  
  /// First name
  final String firstName;
  
  /// Last name
  final String? lastName;
  
  /// Profile picture URL
  final String? profilePicture;
  
  /// User's location
  final UserLocationBasic location;
  
  /// Distance from current user in kilometers
  final double distance;

  /// Constructor
  const NearbyUser({
    required this.userId,
    required this.username,
    required this.firstName,
    this.lastName,
    this.profilePicture,
    required this.location,
    required this.distance,
  });

  /// Create a NearbyUser from JSON data
  factory NearbyUser.fromJson(Map<String, dynamic> json) {
    return NearbyUser(
      userId: json['userId'] ?? json['user_id'],
      username: json['username'],
      firstName: json['firstName'] ?? json['first_name'],
      lastName: json['lastName'] ?? json['last_name'],
      profilePicture: json['profilePicture'] ?? json['profile_picture'],
      location: UserLocationBasic.fromJson(json['location']),
      distance: (json['distance'] is String) 
          ? double.parse(json['distance']) 
          : json['distance'].toDouble(),
    );
  }
  
  /// Display name (first name + last name)
  String get displayName {
    if (lastName != null && lastName!.isNotEmpty) {
      return '$firstName $lastName';
    }
    return firstName;
  }

  @override
  List<Object?> get props => [
    userId, 
    username, 
    firstName, 
    lastName, 
    profilePicture, 
    location, 
    distance
  ];
}

/// Simplified location model with only coordinates
class UserLocationBasic extends Equatable {
  /// Latitude coordinate
  final double latitude;
  
  /// Longitude coordinate
  final double longitude;

  /// Constructor
  const UserLocationBasic({
    required this.latitude,
    required this.longitude,
  });

  /// Create from JSON
  factory UserLocationBasic.fromJson(Map<String, dynamic> json) {
    return UserLocationBasic(
      latitude: (json['latitude'] is String) 
          ? double.parse(json['latitude']) 
          : json['latitude'].toDouble(),
      longitude: (json['longitude'] is String) 
          ? double.parse(json['longitude']) 
          : json['longitude'].toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  List<Object> get props => [latitude, longitude];
}