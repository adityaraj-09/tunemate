// lib/models/music/music_preferences.dart
class MusicPreference {
  final String id;
  final String name;
  final String? imageUrl;
  bool isSelected;

  MusicPreference({
    required this.id,
    required this.name,
    this.imageUrl,
    this.isSelected = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'isSelected': isSelected,
    };
  }

  factory MusicPreference.fromJson(Map<String, dynamic> json) {
    return MusicPreference(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      isSelected: json['isSelected'] ?? false,
    );
  }
}

class MusicPreferences {
  final List<MusicPreference> languages;
  final List<MusicPreference> genres;
  final List<MusicPreference> artists;

  MusicPreferences({
    required this.languages,
    required this.genres,
    required this.artists,
  });

  Map<String, dynamic> toJson() {
    return {
      'languages': languages.where((lang) => lang.isSelected).map((lang) => lang.id).toList(),
      'genres': genres.where((genre) => genre.isSelected).map((genre) => genre.id).toList(),
      'artists': artists.where((artist) => artist.isSelected).map((artist) => artist.id).toList(),
    };
  }
}