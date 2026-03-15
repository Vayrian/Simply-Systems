# Simply Systems – Flutter Client

A mobile app (web, iOS & Android) for plural systems to manage system members (alters), track fronting history, communicate internally via real-time chat, and more.

Built with **Flutter** and connects to a **Python/Flask** backend (https://github.com/Vayrian/Simply-systems-api).

**Current focus**: Online-first experience with real-time sync via Socket.IO. All data is stored on the server (SQLite/PostgreSQL).

## Current Features

- **User authentication**  
  Register / login with JWT tokens

- **Member (alter) profiles**  
  Create, edit, delete alters with name, pronouns, description, color

- **Fronting tracker**  
  Set current fronter, view fronting history list, real-time timer on Members screen

- **Internal system chat**  
  Real-time group chat between alters (Socket.IO), persistent message history

## Tech Stack (Frontend)

- Flutter 3.x (Dart)
- State management: Provider
- Networking: http
- Real-time: socket_io_client
- Authentication: JWT tokens
- UI: Material 3 + Google Fonts (Inter)
- Charts: fl_chart (used in front history)


### Prerequisites

- Flutter SDK (3.24+ recommended): https://flutter.dev
- Android Studio / Xcode (for emulators)
- Git
- Backend running locally (see backend repo)

### Setup

1. Clone the repo:
   ```bash
   git clone https://github.com/Vayrian/simply-systems.git
   cd simply-systems


2. Install dependencies:
   ```bash
   flutter pub get
   Run on emulator/device:Bashflutter run -d edge   # browser emulator
   flutter run -d <device-id> # Physical device


3. Connect to backend:
Local dev: http://10.0.2.2:5000 (Android emulator) or http://localhost:5000 (desktop/web)
Deployed: Update ApiService.baseUrl to your production URL


### Important Commands

- Clean & rebuild
  ```bash
  flutter clean && flutter pub get 

- Run in release mode:
  ```bash
  flutter run --release
- Build APK (Android):
  ```bash
  flutter build apk --release
- Build iOS (macOS only):
  ```bash
  flutter build ios --release


### Current Roadmap (Future Ideas)

- Offline support with Hive (local-first storage + server sync)
- Polls / voting inside system chat
- Friend sharing (front status, chat access)
- More member fields (birthday, age, role, etc.)
- Fronting history graphs & stats
- Notifications (push or in-app)
- Custom themes / accessibility options
- Memory notes shared between members

### Contributing

- Fork the repo
- Create feature branch (git checkout -b feature/add-polls)
- Commit changes (git commit -m 'Add polls feature')
- Push (git push origin feature/add-polls)
- Open Pull Request

### License
AGPL-3.0 License (see LICENSE file)


Made with ♥ for plural systems.