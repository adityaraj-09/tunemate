import 'package:flutter/material.dart';

class LyricsDisplay extends StatelessWidget {
  final String lyrics;

  const LyricsDisplay({Key? key, required this.lyrics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace <br> tags with actual newline characters
    final processedLyrics = lyrics.replaceAll('<br>', '\n');
    
    // Split lyrics into lines
    final lines = processedLyrics.split('\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: lines.map((line) {
        // Check if line is empty for verse separation
        if (line.trim().isEmpty) {
          return const SizedBox(height: 24);
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            line.trim(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.5,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );
  }
}