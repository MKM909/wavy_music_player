# 🌊 Wavy Music Player

<div align="center">

![Wavy Music Player Banner](https://via.placeholder.com/800x200/FFE695/342E1B?text=🎵+Wavy+Music+Player)

**A stunning music player with wave-inspired UI and seamless Spotify integration**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Spotify](https://img.shields.io/badge/Spotify-1DB954?style=for-the-badge&logo=spotify&logoColor=white)](https://developer.spotify.com)

[Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Spotify Setup](#-spotify-integration) • [Contributing](#-contributing)

</div>

---

## ✨ Features

### 🎨 **Stunning Wave UI**
- **Organic, flowing navigation bar** with custom-painted waves and smooth animations
- **Rolling indicator** that glides across peaks and valleys as you switch tabs
- **Smooth page transitions** with swipe gestures and synchronized nav animations
- **Beautiful color palette** featuring warm cream (#FFE695) and rich dark olive (#342E1B)

### 🎵 **Powerful Playback**
- High-quality audio playback with intuitive controls
- Seek, skip, shuffle, and repeat functionality
- Real-time progress tracking with smooth animations
- Queue management and playlist support

### 🔗 **Spotify Integration**
- **Connect your Spotify account** for seamless music control
- **Add songs to playlists** directly from the app
- **Control playback** across all your devices
- **Sync your library** and access your favorite tracks
- **Real-time updates** when you play music on other devices

### 📱 **Modern User Experience**
- Smooth 60fps animations throughout
- Intuitive gesture controls
- Responsive design that adapts to any screen size
- Dark mode compatible

---

## 📸 Screenshots

<div align="center">

| Home Screen | Music Library | Search | Profile |
|------------|--------------|--------|---------|
| ![Home](https://via.placeholder.com/200x400/FFE695/342E1B?text=Home) | ![Music](https://via.placeholder.com/200x400/FFE695/342E1B?text=Music) | ![Search](https://via.placeholder.com/200x400/FFE695/342E1B?text=Search) | ![Profile](https://via.placeholder.com/200x400/FFE695/342E1B?text=Profile) |

</div>

---

## 🚀 Installation

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- A Spotify Developer account for API access

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/wavy_music_player.git
   cd wavy_music_player
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Spotify credentials** (see [Spotify Integration](#-spotify-integration))

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 🎧 Spotify Integration

### Setting Up Spotify API

1. **Create a Spotify App**
    - Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
    - Click "Create an App"
    - Fill in the app name and description
    - Note your **Client ID** and **Client Secret**

2. **Configure Redirect URI**
    - In your Spotify app settings, add redirect URI:
      ```
      myapp://callback
      ```

3. **Add credentials to the app**
    - Create a file `lib/config/spotify_config.dart`:
      ```dart
      class SpotifyConfig {
        static const String clientId = 'YOUR_CLIENT_ID';
        static const String clientSecret = 'YOUR_CLIENT_SECRET';
        static const String redirectUri = 'myapp://callback';
      }
      ```

4. **Enable required scopes**
   The app requests the following Spotify permissions:
    - `user-read-playback-state` - Read your playback state
    - `user-modify-playback-state` - Control playback
    - `playlist-modify-public` - Add to public playlists
    - `playlist-modify-private` - Add to private playlists
    - `user-library-read` - Access your saved tracks

### Features Enabled by Spotify

✅ **Play/Pause/Skip** tracks on any device  
✅ **Add songs** to your Spotify playlists  
✅ **View currently playing** track with album art  
✅ **Control volume** and playback across devices  
✅ **Browse your library** and recently played tracks

---

## 🎨 Design Philosophy

Wavy Music Player draws inspiration from organic, flowing forms found in nature. The wave-like navigation creates a sense of rhythm and movement that mirrors the musical experience itself.

### Key Design Elements

- **Custom Painters**: Hand-crafted cubic Bezier curves create smooth, natural wave forms
- **Animation Choreography**: Every transition is carefully timed for a fluid experience
- **Color Harmony**: The warm cream and dark olive palette creates a comfortable, immersive environment
- **Gestural Interface**: Swipe, tap, and hold gestures feel intuitive and responsive

---

## 🛠️ Built With

- **[Flutter](https://flutter.dev)** - UI framework
- **[Dart](https://dart.dev)** - Programming language
- **[Spotify Web API](https://developer.spotify.com/documentation/web-api)** - Music streaming integration
- **[curved_navigation_bar](https://pub.dev/packages/curved_navigation_bar)** - Curved navigation bar package
- **Custom Painters** - Hand-crafted wave animations

---

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- 🚧 Web (coming soon)
- 🚧 Desktop (coming soon)

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Flutter's [style guide](https://dart.dev/guides/language/effective-dart/style)
- Write meaningful commit messages
- Add comments for complex wave calculations and animations
- Test on both iOS and Android before submitting

---

## 📋 Roadmap

- [ ] Web platform support
- [ ] Desktop platform support (Windows, macOS, Linux)
- [ ] Custom equalizer with wave visualizations
- [ ] Lyrics display with scroll sync
- [ ] Social features (share playlists)
- [ ] Offline playback support
- [ ] Apple Music integration
- [ ] Custom wave theme editor

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Your Name**

- GitHub: [@MKM909](https://github.com/MKM909)
- LinkedIn: [@micah-okoh](https://linkedin.com/in/micah-okoh)
- Email: okohmicah00@gmail.com

---

## 🙏 Acknowledgments

- Inspiration from Dribbble : [@Nixtio](https://dribbble.com/shots/15731031-Music-Player-App-Design), [Budiarti R.](https://dribbble.com/shots/25787741-Music-Player-UI-Dark-Mode-Aesthetic)
- Flutter community for amazing packages and support
- Spotify for providing comprehensive API documentation
- All contributors who help improve this project

---

<div align="center">

**Made with 💛 and lots of ☕**

If you found this project helpful, give it a ⭐️!

</div>