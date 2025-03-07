# Insien - Music Dating App

## Overview

Insien is a dating app that connects people through their shared music tastes. The app allows users to discover potential matches based on music compatibility, listen to music directly within the app, and communicate with matches. Insien leverages music preferences as a powerful way to create meaningful connections between users.

## Key Features

### Music-Based Matching
- Algorithm that analyzes music preferences, genres, artists, and listening patterns
- Compatibility scores based on shared music tastes (35% song similarity, 25% artist similarity, 20% genre, 10% listening patterns, 10% era preferences)
- "Music Soulmates" discovery that highlights highest compatibility matches

### Integrated Music Player
- Full-featured music player with background playback capability
- Support for streaming and offline playback
- Mini-player available throughout the app
- Full-screen player with vinyl animation and waveform visualization
- Media controls in notification center

### User Profiles
- Music taste visualization with genre distribution charts
- Favorite songs showcase
- Listening history tracking
- Compatibility indicators with other users
- Customizable privacy settings

### Communication
- Real-time chat with matches
- Ability to share songs directly in conversations
- "Currently listening" status sharing

### Discovery
- Trending songs and artists
- Personalized music recommendations
- Genre-based exploration
- Community playlists

## Technical Architecture

### Frontend
- **Framework**: Flutter for cross-platform mobile development
- **State Management**: Provider pattern for UI state
- **Navigation**: Go Router for declarative routing with authentication protection
- **Dependency Injection**: GetIt for service localization
- **Networking**: Dio HTTP client with interceptors for authentication
- **Local Storage**: SharedPreferences for user settings and authentication tokens
- **Media Playback**: just_audio and audio_service for background music playback

### Backend (Microservices)
- **Authentication Service**: User registration, login, and token management
- **User Profile Service**: Profile management and preferences
- **Music Service**: Integration with Jio Saavn API for music data and playback
- **Matching Service**: Compatibility algorithm and match discovery
- **Chat Service**: Real-time messaging with Socket.IO
- **Analytics Service**: User behavior tracking and insights

### Database
- **PostgreSQL**: Primary database for user data, matches, and music preferences
- **Redis**: Used for caching and pub/sub for real-time features
- **BullMQ**: Background job processing for match calculations and recommendations

## App Workflow

1. **User Onboarding**:
- User creates an account or logs in
- User completes a music taste profile by selecting favorite genres, artists, and songs
- Music listening history can be imported from popular streaming services

2. **Discovery**:
- User browses potential matches sorted by music compatibility
- Each profile shows music taste overlap and compatibility score
- User can play songs directly from potential match profiles

3. **Matching**:
- User indicates interest in potential matches
- When mutual interest is shown, a match is created
- Match notification includes a song recommendation based on shared tastes

4. **Communication**:
- Users can chat with matches
- Music sharing is integrated directly into the chat interface
- Real-time "currently playing" status can be shared

5. **Music Exploration**:
- User can explore trending music, new releases, and personalized recommendations
- Each interaction with music refines the user's taste profile
- Listening history is tracked to improve matching algorithm

## Future Enhancements

- **Collaborative Playlists**: Create and share playlists with matches
- **Music Events**: Discover concerts and music events based on shared tastes
- **Voice Notes**: Send audio messages with song snippets
- **Video Chat**: Music-themed video chat with shared playback control
- **Group Matching**: Create groups based on shared music interests
- **AI Music Recommendations**: Machine learning for more accurate matching

## Privacy and Data Usage

Insien takes user privacy seriously:
- User can control profile visibility (Public, Matches Only, Private)
- Granular control over what listening data is shared
- Option to pause matching visibility
- All personal data is encrypted and securely stored
- Users can export or delete their data at any time

## Acknowledgments

- Jio Saavn API for music data
- Flutter team for the amazing framework
- Our beta testers for valuable feedback

---

Insien: Find love through music. ♫❤️