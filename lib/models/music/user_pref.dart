// lib/models/user_preference.dart
import 'package:equatable/equatable.dart';

/// Enum representing gender preference options
enum GenderPreference {
  /// Preference for male users
  male,
  
  /// Preference for female users
  female,
  
  /// No specific gender preference
  any,
  
  /// Preference for non-binary users
  nonBinary,
  
  /// Custom gender preference (can be a comma-separated list)
  custom
}

/// Model representing a user's matching preferences
class UserPreference extends Equatable {
  /// Unique identifier for this preference record
  final String id;
  
  /// ID of the user this preference belongs to
  final String userId;
  
  /// Gender preference (who the user wants to match with)
  final GenderPreference? preferredGender;
  
  /// Custom gender preference string (used when preferredGender is custom)
  final String? customGenderPreference;
  
  /// Minimum age for matches
  final int? minAge;
  
  /// Maximum age for matches
  final int? maxAge;
  
  /// Maximum distance for matches (in kilometers)
  final int? maxDistance;
  
  /// Whether the user is visible in searches/matching
  final bool isVisible;
  
  /// When these preferences were created
  final DateTime createdAt;
  
  /// When these preferences were last updated
  final DateTime updatedAt;

  /// Constructor
  const UserPreference({
    required this.id,
    required this.userId,
    this.preferredGender,
    this.customGenderPreference,
    this.minAge,
    this.maxAge,
    this.maxDistance,
    this.isVisible = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a UserPreference from JSON data
  factory UserPreference.fromJson(Map<String, dynamic> json) {
    GenderPreference? genderPref;
    String? customGender;
    
    if (json['preferredGender'] != null || json['preferred_gender'] != null) {
      final prefGender = json['preferredGender'] ?? json['preferred_gender'];
      
      // Handle different formats of gender preference
      if (prefGender is String) {
        switch (prefGender.toLowerCase()) {
          case 'male':
            genderPref = GenderPreference.male;
            break;
          case 'female':
            genderPref = GenderPreference.female;
            break;
          case 'any':
            genderPref = GenderPreference.any;
            break;
          case 'non-binary':
          case 'nonbinary':
            genderPref = GenderPreference.nonBinary;
            break;
          default:
            genderPref = GenderPreference.custom;
            customGender = prefGender;
        }
      }
    }
    
    return UserPreference(
      id: json['id'] ?? json['preference_id'],
      userId: json['userId'] ?? json['user_id'],
      preferredGender: genderPref,
      customGenderPreference: customGender ?? json['customGenderPreference'] ?? json['custom_gender_preference'],
      minAge: json['minAge'] ?? json['min_age'],
      maxAge: json['maxAge'] ?? json['max_age'],
      maxDistance: json['maxDistance'] ?? json['max_distance'],
      isVisible: json['isVisible'] ?? json['is_visible'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : json['created_at'] != null 
              ? DateTime.parse(json['created_at']) 
              : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : json['updated_at'] != null 
              ? DateTime.parse(json['updated_at']) 
              : DateTime.now(),
    );
  }

  /// Convert this UserPreference to JSON
  Map<String, dynamic> toJson() {
    String? preferredGenderString;
    
    if (preferredGender != null) {
      switch (preferredGender) {
        case GenderPreference.male:
          preferredGenderString = 'male';
          break;
        case GenderPreference.female:
          preferredGenderString = 'female';
          break;
        case GenderPreference.any:
          preferredGenderString = 'any';
          break;
        case GenderPreference.nonBinary:
          preferredGenderString = 'non-binary';
          break;
        case GenderPreference.custom:
          preferredGenderString = customGenderPreference;
          break;
        default:
          preferredGenderString = null;
      }
    }
    
    return {
      'id': id,
      'userId': userId,
      'preferredGender': preferredGenderString,
      'customGenderPreference': customGenderPreference,
      'minAge': minAge,
      'maxAge': maxAge,
      'maxDistance': maxDistance,
      'isVisible': isVisible,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  /// Format to match API request format
  Map<String, dynamic> toApiJson() {
    final Map<String, dynamic> data = {};
    
    String? preferredGenderString;
    
    if (preferredGender != null) {
      switch (preferredGender) {
        case GenderPreference.male:
          preferredGenderString = 'male';
          break;
        case GenderPreference.female:
          preferredGenderString = 'female';
          break;
        case GenderPreference.any:
          preferredGenderString = 'any';
          break;
        case GenderPreference.nonBinary:
          preferredGenderString = 'non-binary';
          break;
        case GenderPreference.custom:
          preferredGenderString = customGenderPreference;
          break;
        default:
          preferredGenderString = null;
      }
    }
    
    if (preferredGenderString != null) {
      data['preferredGender'] = preferredGenderString;
    }
    
    if (minAge != null) {
      data['minAge'] = minAge;
    }
    
    if (maxAge != null) {
      data['maxAge'] = maxAge;
    }
    
    if (maxDistance != null) {
      data['maxDistance'] = maxDistance;
    }
    
    data['isVisible'] = isVisible;
    
    return data;
  }
  
  /// Create a copy of this UserPreference with some fields replaced
  UserPreference copyWith({
    String? id,
    String? userId,
    GenderPreference? preferredGender,
    String? customGenderPreference,
    int? minAge,
    int? maxAge,
    int? maxDistance,
    bool? isVisible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreference(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      preferredGender: preferredGender ?? this.preferredGender,
      customGenderPreference: customGenderPreference ?? this.customGenderPreference,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      maxDistance: maxDistance ?? this.maxDistance,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Get a user-friendly display of age preferences
  String getAgeRangeDisplay() {
    if (minAge != null && maxAge != null) {
      return '$minAge-$maxAge years';
    } else if (minAge != null) {
      return '$minAge+ years';
    } else if (maxAge != null) {
      return 'Up to $maxAge years';
    } else {
      return 'Any age';
    }
  }
  
  /// Get a user-friendly display of distance preference
  String getDistanceDisplay() {
    if (maxDistance != null) {
      return 'Within $maxDistance km';
    } else {
      return 'Any distance';
    }
  }
  
  /// Get a user-friendly display of gender preference
  String getGenderPreferenceDisplay() {
    if (preferredGender == null) {
      return 'Any gender';
    }
    
    switch (preferredGender) {
      case GenderPreference.male:
        return 'Men';
      case GenderPreference.female:
        return 'Women';
      case GenderPreference.any:
        return 'Everyone';
      case GenderPreference.nonBinary:
        return 'Non-binary people';
      case GenderPreference.custom:
        return customGenderPreference ?? 'Custom';
      default:
        return 'Any gender';
    }
  }

  @override
  List<Object?> get props => [
    id, 
    userId, 
    preferredGender, 
    customGenderPreference,
    minAge, 
    maxAge, 
    maxDistance, 
    isVisible, 
    createdAt, 
    updatedAt
  ];
}