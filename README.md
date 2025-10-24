# Camalig Fitness Gym Mobile App

A Flutter mobile application for Camalig Fitness Gym with Android and iOS support.

## Features

- ✅ User Authentication (Login & Registration)
- ✅ Multi-step Registration Form
- ✅ Profile Photo Upload
- ✅ Remember Me Functionality
- ✅ Forgot Password with OTP
- ✅ Form Validation
- ✅ Responsive UI Design

## Project Structure

```
gym_project/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── screens/
│   │   ├── login_screen.dart     # Login interface
│   │   └── register_screen.dart  # Registration interface (2 steps)
│   ├── models/
│   │   └── user_model.dart       # User data model
│   ├── services/
│   │   ├── api_service.dart      # API communication
│   │   └── auth_service.dart     # Authentication service
│   ├── utils/
│   │   ├── constants.dart        # App constants & configuration
│   │   └── validators.dart       # Form validators
│   └── widgets/                  # Reusable widgets
├── assets/
│   └── images/                   # App images
└── pubspec.yaml                  # Dependencies
```

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Xcode (for iOS development on macOS)

## Installation

### 1. Install Flutter Dependencies

```powershell
cd gym_project
flutter pub get
```

### 2. Copy Image Assets

Copy the following images from `others/images/` to `gym_project/assets/images/`:
- logo.png
- login.jpg (used as design reference)
- forgot-password.jpg
- signup-1.jpg (Step 1 design reference)
- signup-2.jpg (Step 2 design reference)

### 3. Configure API Endpoint

Update the base URL in `lib/utils/constants.dart`:

```dart
static const String baseUrl = 'http://YOUR_SERVER_IP/camalig/web/mobile/';
```

For local development:
- Android Emulator: Use `http://10.0.2.2/camalig/web/mobile/`
- iOS Simulator: Use `http://localhost/camalig/web/mobile/`
- Physical Device: Use your computer's IP address

## Running the App

### Android

```powershell
flutter run
```

### iOS (macOS only)

```powershell
flutter run -d ios
```

### Build APK (Android)

```powershell
flutter build apk --release
```

The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

### Build iOS

```powershell
flutter build ios --release
```

## API Integration

The app integrates with the existing PHP backend:

### Login Endpoint
- **URL**: `app.login.php`
- **Method**: POST
- **Parameters**: 
  - `ftr`: "100-0"
  - `token`: "_jE@20RIC!25$$"
  - `un`: username
  - `pw`: password

### Registration Endpoint
- **URL**: `app.registration.php`
- **Method**: POST
- **Parameters**:
  - `ftr`: "100-1"
  - `token`: "_jE@20RIC!25$$"
  - `fn`, `mn`, `ln`: Name fields
  - `gender`: "1" (Male) or "2" (Female)
  - `dob`: Birthday (MM-DD-YYYY)
  - `address`, `company`, `email`, `phone`, `phone2`
  - `un`, `pw`: Credentials
  - `profile`: Base64 encoded image

### Forgot Password Endpoint
- **URL**: `app.login.php`
- **Method**: POST
- **Parameters**:
  - `ftr`: "110-0"
  - `token`: "_jE@20RIC!25$$"
  - `email`: User's email

## Design Reference

The UI design is based on the reference images:

### Login Screen (login.jpg)
- Clean modern design with gradient background
- Logo at top center
- Card-based form layout
- Username and password fields
- Remember me checkbox
- Forgot password link
- Login button
- Register link at bottom

### Registration Screen
**Step 1 (signup-1.jpg):**
- Personal information section
- Fields: First Name, Middle Name, Last Name
- Gender selection (Radio buttons)
- Birthday picker
- Phone numbers (primary & alternate)
- Email address
- Progress indicator at top
- Next button

**Step 2 (signup-2.jpg):**
- Account setup section
- Profile photo upload (optional)
- Address field
- Company/School field
- Username field
- Password fields with visibility toggle
- Confirm password
- Back and Register buttons

## Color Scheme

- **Primary**: Deep Blue (#1E3A8A)
- **Accent**: Red (#EF4444)
- **Background**: Light Gray (#F3F4F6)
- **Text Primary**: Dark Gray (#1F2937)
- **Text Secondary**: Medium Gray (#6B7280)

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  http: ^1.1.0              # API requests
  shared_preferences: ^2.2.2 # Local storage
  provider: ^6.1.1          # State management
  image_picker: ^1.0.7      # Photo capture/upload
  intl: ^0.19.0             # Date formatting
  flutter_svg: ^2.0.9       # SVG support
```

## Database Schema

The app uses the following database tables:
- **clients**: User accounts
- **branches**: Gym locations
- **clients_enrolled**: Membership enrollments

See `others/db/gym_camalig.sql` for complete schema.

## Testing

### Test Accounts
Use existing test data from the database or create new accounts through registration.

### Test on Physical Device
1. Enable USB debugging on Android device
2. Connect via USB
3. Run: `flutter devices` to verify connection
4. Run: `flutter run`

## Troubleshooting

### Package Not Found
```powershell
flutter clean
flutter pub get
```

### Build Errors
```powershell
flutter doctor
flutter upgrade
```

### API Connection Issues
- Check your computer's IP address
- Ensure XAMPP is running
- Verify API endpoint in constants.dart
- Check firewall settings

## Future Features

- [ ] Dashboard
- [ ] Enrollment/Program Selection
- [ ] Time In/Out (DTR)
- [ ] Payment History
- [ ] Notifications
- [ ] Profile Management
- [ ] QR Code Scanner
- [ ] Workout Calendar
- [ ] Branch Selection

## Support

For issues or questions, contact the development team.

## License

Proprietary - Camalig Fitness Gym
