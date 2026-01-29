# TukTuky Passenger App - Setup and Run Guide

## Prerequisites

Before running the app, ensure you have the following installed and configured:

### 1. Development Environment
- Flutter SDK (3.0.0 or higher)
- Dart SDK (included with Flutter)
- Android Studio or Xcode (for iOS)
- Android device/emulator or iOS simulator

### 2. API Keys and Services

You need to configure the following services:

#### Supabase (Database & Authentication)
1. Create a Supabase project at https://supabase.com
2. Run the database schema from `database/schema.sql`
3. Get your Supabase URL and Anon Key from Project Settings → API
4. Update `lib/config/constants.dart`:
   ```dart
   static const String supabaseUrl = 'https://your-project.supabase.co';
   static const String supabaseAnonKey = 'your-anon-key-here';
   ```

#### Google Maps API
1. Create a Google Cloud project at https://console.cloud.google.com
2. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
   - Places API (optional, for address search)
3. Create an API key
4. Update `lib/config/constants.dart`:
   ```dart
   static const String googleMapsApiKey = 'your-google-maps-api-key';
   ```
5. Configure API key in platform-specific files:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<manifest>
  <application>
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
  </application>
</manifest>
```

**iOS** (`ios/Runner/AppDelegate.swift`):
```swift
import GoogleMaps

GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

#### Firebase (Push Notifications & Analytics)
1. Create a Firebase project at https://console.firebase.google.com
2. Add Android and iOS apps to your Firebase project
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place them in the correct directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

---

## Installation Steps

### 1. Clone the Repository (Already Done)
```bash
cd /home/ubuntu/TukTuky
git checkout DodgeM
```

### 2. Install Dependencies
```bash
cd passenger_app
flutter pub get
```

### 3. Configure API Keys
Edit `lib/config/constants.dart` and replace placeholder values:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
```

### 4. Setup Database
1. Open your Supabase project dashboard
2. Go to SQL Editor
3. Copy and paste the entire content of `database/schema.sql`
4. Execute the SQL to create all tables and seed data

### 5. Configure Permissions

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby drivers and track your trip</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to provide ride services</string>
```

---

## Running the App

### Check Connected Devices
```bash
flutter devices
```

### Run on Android
```bash
flutter run -d android
```

### Run on iOS
```bash
flutter run -d ios
```

### Run on Specific Device
```bash
flutter run -d <device_id>
```

### Run in Release Mode
```bash
flutter run --release
```

---

## Testing the Saved Locations Module

### 1. Initial Setup
1. Launch the app
2. Complete the login/registration process
3. Navigate to Profile → Saved Locations

### 2. Test Add Location
1. Tap "Add Location" button
2. Allow location permissions when prompted
3. Wait for map to load with current location
4. Tap on the map to select a different location
5. Select location type (Home/Work/Other)
6. Enter a name (e.g., "My Home")
7. Verify address is auto-filled
8. Tap "Save Location"
9. Verify success message and location appears in list

### 3. Test Edit Location
1. Tap menu (⋮) on any saved location
2. Select "Edit"
3. Modify the name or location
4. Tap "Update Location"
5. Verify changes are saved

### 4. Test Delete Location
1. Tap menu (⋮) on any saved location
2. Select "Delete"
3. Confirm deletion
4. Verify location is removed

---

## Troubleshooting

### Issue: "Supabase not initialized"
**Solution**: Ensure Supabase credentials are correct in `constants.dart` and the service is initialized in the app.

### Issue: Map not showing
**Solution**: 
- Check Google Maps API key is configured correctly
- Verify Maps SDK is enabled in Google Cloud Console
- Check API key restrictions (should allow your app's package name)

### Issue: Location permission denied
**Solution**:
- Grant location permission in device settings
- Restart the app
- Check permission declarations in AndroidManifest.xml / Info.plist

### Issue: Database errors
**Solution**:
- Verify database schema is created in Supabase
- Check Supabase project is active
- Verify Row Level Security policies allow operations

### Issue: Build errors
**Solution**:
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

---

## Development Workflow

### 1. Make Changes
Edit files in `lib/` directory

### 2. Hot Reload
Press `r` in the terminal where `flutter run` is active

### 3. Hot Restart
Press `R` in the terminal for a full restart

### 4. Check for Errors
```bash
flutter analyze
```

### 5. Format Code
```bash
flutter format lib/
```

---

## Project Structure

```
passenger_app/
├── lib/
│   ├── config/           # App configuration (colors, theme, constants)
│   ├── models/           # Data models (User, Trip, SavedLocation, etc.)
│   ├── providers/        # State management (Riverpod providers)
│   ├── screens/          # UI screens
│   │   ├── auth/         # Login, OTP screens
│   │   ├── home/         # Home screen
│   │   ├── profile/      # Profile, saved locations, emergency contacts
│   │   ├── trip/         # Trip booking, bidding, tracking
│   │   ├── wallet/       # Wallet screen
│   │   └── support/      # Support screen
│   ├── services/         # Backend services (Supabase, Places, etc.)
│   ├── widgets/          # Reusable UI components
│   └── main.dart         # App entry point
├── android/              # Android-specific files
├── ios/                  # iOS-specific files
├── assets/               # Images, fonts, translations
└── pubspec.yaml          # Dependencies
```

---

## Next Steps After Testing

1. **Fix Bugs**: Address any issues found during testing
2. **Replace Original Screen**: Update `saved_locations_screen.dart` with the complete version
3. **Commit Changes**: 
   ```bash
   git add .
   git commit -m "Complete Saved Locations module implementation"
   git push origin DodgeM
   ```
4. **Move to Next Module**: Emergency Contacts or User Profile Edit

---

## Module Status

| Module | Status | Notes |
|--------|--------|-------|
| User Authentication | ✅ Complete | Login/Register working |
| Saved Locations | ✅ Complete | Full CRUD with map picker |
| Emergency Contacts | 🔄 Partial | Screen exists, needs implementation |
| User Profile Edit | 🔄 Partial | Basic screen exists |
| Wallet | 🔄 Partial | View balance, needs topup |
| Trip Booking | 🔄 Partial | UI exists, needs backend integration |
| Trip History | ❌ Not Started | - |
| Ratings & Reviews | ❌ Not Started | - |
| Support Tickets | 🔄 Partial | Basic screen exists |
| Notifications | ❌ Not Started | - |

---

## Important Notes

1. **API Keys**: Never commit real API keys to version control. Use environment variables or secure storage.

2. **Database Security**: Configure Row Level Security (RLS) policies in Supabase to protect user data.

3. **Testing**: Always test on real devices, not just emulators, especially for location features.

4. **Performance**: Monitor app performance and optimize as needed, especially for map rendering.

5. **Error Handling**: All API calls should have proper error handling and user feedback.

---

## Support

For issues or questions:
- Check the documentation files in the repository
- Review the database schema in `database/schema.sql`
- Check the testing guide in `SAVED_LOCATIONS_TESTING.md`
- Review module analysis in `MODULE_ANALYSIS.md`
