# TukTuky Passenger App - Complete Integration Guide

## 🎯 **Overview**

This guide covers the complete integration of the TukTuky Passenger App with:
- ✅ Modern UI/UX design with notch support
- ✅ Complete internationalization (i18n) - English & Arabic
- ✅ Global font family (Poppins for EN, Cairo for AR)
- ✅ OTP verification via Zentramsg API
- ✅ All buttons, screens, and components connected

---

## 📱 **Project Structure**

```
passenger_app/
├── lib/
│   ├── config/
│   │   ├── colors.dart              # Color system
│   │   ├── theme.dart               # Original theme
│   │   ├── theme_global.dart        # Global theme with fonts
│   │   ├── modern_theme.dart        # Modern design system
│   │   ├── constants.dart           # App constants
│   │   └── router.dart              # Navigation routes
│   ├── models/
│   │   └── models.dart              # Data models
│   ├── providers/
│   │   ├── auth_provider.dart       # Authentication
│   │   ├── otp_provider.dart        # OTP state management
│   │   ├── trip_provider.dart       # Trip management
│   │   ├── wallet_provider.dart     # Wallet management
│   │   ├── location_provider.dart   # Location management
│   │   ├── user_provider.dart       # User profile
│   │   └── localization_provider.dart # i18n management
│   ├── services/
│   │   ├── supabase_service.dart    # Supabase backend
│   │   ├── notification_service.dart # Push notifications
│   │   └── otp_service.dart         # OTP via Zentramsg API
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen_modern.dart
│   │   │   ├── otp_screen_modern.dart
│   │   │   └── splash_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen_modern.dart
│   │   │   └── search_location_screen.dart
│   │   ├── trip/
│   │   │   ├── trip_booking_screen.dart
│   │   │   ├── bidding_screen_modern.dart
│   │   │   ├── driver_arriving_screen.dart
│   │   │   ├── trip_in_progress_screen.dart
│   │   │   └── trip_completed_screen.dart
│   │   └── profile/
│   │       ├── profile_screen.dart
│   │       ├── saved_locations_screen.dart
│   │       ├── emergency_contacts_screen.dart
│   │       ├── wallet_screen.dart
│   │       └── support_screen.dart
│   ├── widgets/
│   │   ├── advanced_components.dart # Skeleton, Toast, Dialog, etc.
│   │   ├── gesture_handlers.dart    # Swipe, Scale, Animations
│   │   ├── golden_button.dart       # Golden button widget
│   │   ├── glass_card.dart          # Glassmorphism card
│   │   ├── sos_button.dart          # SOS emergency button
│   │   ├── rating_stars.dart        # Rating widget
│   │   ├── driver_offer_card.dart   # Driver offer card
│   │   ├── location_input.dart      # Location input
│   │   └── payment_method_selector.dart # Payment selector
│   ├── main_modern.dart             # Main app with i18n
│   └── main.dart                    # Original main
├── assets/
│   ├── translations/
│   │   ├── en.json                  # English strings (150+ keys)
│   │   └── ar.json                  # Arabic strings (150+ keys)
│   └── fonts/
│       ├── Poppins/                 # English font
│       └── Cairo/                   # Arabic font
├── pubspec.yaml                     # Dependencies
└── README.md
```

---

## 🚀 **Getting Started**

### **1. Setup Dependencies**

Update `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  go_router: ^11.0.0
  http: ^1.1.0
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  google_maps_flutter: ^2.5.0
  firebase_core: ^2.24.0
  firebase_messaging: ^14.6.0
  shimmer: ^3.0.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
```

### **2. Add Font Families**

Add to `pubspec.yaml`:

```yaml
fonts:
  - family: Poppins
    fonts:
      - asset: assets/fonts/Poppins/Poppins-Regular.ttf
        weight: 400
      - asset: assets/fonts/Poppins/Poppins-Medium.ttf
        weight: 500
      - asset: assets/fonts/Poppins/Poppins-SemiBold.ttf
        weight: 600
      - asset: assets/fonts/Poppins/Poppins-Bold.ttf
        weight: 700
  
  - family: Cairo
    fonts:
      - asset: assets/fonts/Cairo/Cairo-Regular.ttf
        weight: 400
      - asset: assets/fonts/Cairo/Cairo-Medium.ttf
        weight: 500
      - asset: assets/fonts/Cairo/Cairo-SemiBold.ttf
        weight: 600
      - asset: assets/fonts/Cairo/Cairo-Bold.ttf
        weight: 700
```

### **3. Add Translation Files**

Create `assets/translations/en.json` and `assets/translations/ar.json` with all translation keys.

### **4. Update Main App**

Replace `lib/main.dart` with `lib/main_modern.dart`:

```dart
import 'main_modern.dart' as app;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(const ProviderScope(child: TukTukyApp()));
}
```

---

## 🌍 **Internationalization (i18n) Usage**

### **In Widgets**

```dart
// Using extension method
Text(context.l10n.welcome)  // "Welcome to TukTuky" or "مرحبا بك في توكتوكي"

// Using translation key
Text(context.t('welcome'))

// With parameters
Text(context.tParams('hello_name', {'name': 'Ahmed'}))
```

### **Check Language**

```dart
// Check if RTL (Arabic)
if (context.isRTL) {
  // Arabic layout
} else {
  // English layout
}

// Get current locale
final locale = context.currentLocale;  // Locale('en') or Locale('ar')
```

### **Change Language**

```dart
// In any widget
final localizationNotifier = ref.read(localizationProvider.notifier);
await localizationNotifier.setLocale('ar');  // Switch to Arabic
await localizationNotifier.toggleLanguage();  // Toggle EN/AR
```

---

## 🎨 **Modern Design System Usage**

### **Safe Area & Notch Support**

```dart
final topPadding = ModernTheme.getTopPadding(context);
final bottomPadding = ModernTheme.getBottomPadding(context);

Scaffold(
  body: SafeArea(
    top: false,
    bottom: false,
    child: SingleChildScrollView(
      padding: EdgeInsets.only(
        top: topPadding + ModernTheme.spacingM,
        bottom: bottomPadding + ModernTheme.spacingL,
      ),
      child: Column(...),
    ),
  ),
)
```

### **Global Font Family**

All text automatically uses:
- **English**: Poppins
- **Arabic**: Cairo

No need to specify font family in TextStyle!

```dart
Text(
  'Hello World',
  style: Theme.of(context).textTheme.bodyMedium,  // Uses Poppins
)
```

### **Modern Components**

```dart
// Toast notification
ModernToast.success(context, 'Success message');
ModernToast.error(context, 'Error message');

// Dialog
ModernDialog.show(
  context,
  title: 'Confirm',
  message: 'Are you sure?',
  onConfirm: () {},
);

// Loading overlay
ModernLoadingOverlay.show(context, message: 'Loading...');
ModernLoadingOverlay.hide(context);

// Scale button with haptic
ScaleButton(
  onPressed: () {},
  enableHaptic: true,
  child: Container(...),
)

// Animations
SlideInAnimation(child: Widget())
FadeInAnimation(child: Widget())
BounceAnimation(child: Widget())
PulsingAnimation(child: Widget())
```

---

## 🔐 **OTP Integration**

### **Send OTP**

```dart
final otpNotifier = ref.read(otpProvider.notifier);
await otpNotifier.sendOTP('+201066183456');
```

### **Verify OTP**

```dart
final success = await otpNotifier.verifyOTP('+201066183456', '123456');
if (success) {
  // User verified
}
```

### **Resend OTP**

```dart
await otpNotifier.resendOTP('+201066183456');
```

### **OTP State**

```dart
final otpState = ref.watch(otpProvider);

// Access properties
otpState.isLoading          // Loading state
otpState.isOTPSent          // OTP sent successfully
otpState.errorMessage       // Error message
otpState.remainingSeconds   // Countdown timer
otpState.remainingAttempts  // Attempts left
otpState.isVerified         // OTP verified
otpState.authToken          // Auth token after verification
```

### **OTP Screen Integration**

```dart
// Navigate to OTP screen
context.push('/otp', extra: phoneNumber);

// In OTP screen
class OTPScreenModern extends ConsumerStatefulWidget {
  final String phoneNumber;
  
  const OTPScreenModern({required this.phoneNumber});
  
  @override
  ConsumerState<OTPScreenModern> createState() => _OTPScreenModernState();
}
```

---

## 🎯 **Navigation Setup**

Update `lib/config/router.dart`:

```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreenModern(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreenModern(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => OTPScreenModern(
        phoneNumber: state.extra as String,
      ),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreenModern(),
    ),
    // ... other routes
  ],
);
```

---

## 📝 **Translation Keys Reference**

### **Common Keys**
- `app_name` - App name
- `welcome` - Welcome message
- `login` - Login button
- `phone_number` - Phone number label
- `verify_otp` - OTP verification
- `enter_otp` - Enter OTP prompt

### **Trip Keys**
- `request_trip` - Request trip button
- `waiting_for_offers` - Waiting for offers
- `accept_offer` - Accept offer button
- `decline_offer` - Decline offer button
- `trip_in_progress` - Trip in progress
- `trip_completed` - Trip completed

### **Payment Keys**
- `payment_method` - Payment method
- `wallet` - Wallet
- `add_promo_code` - Add promo code
- `total_fare` - Total fare

### **Profile Keys**
- `profile` - Profile screen
- `edit_profile` - Edit profile
- `saved_locations` - Saved locations
- `emergency_contacts` - Emergency contacts

---

## 🔧 **Configuration**

### **OTP API Credentials**

In `lib/services/otp_service.dart`:

```dart
static const String apiBaseUrl = 'https://api.zentramsg.com/v1';
static const String deviceUUID = '50b7cfc0-d89a-4f40-8dec-67e3ade8f2dc';
static const String apiToken = '725ad3ae-65f2-4f8c-a819-d5b18166ef2f';
```

### **OTP Settings**

```dart
static const int otpLength = 6;              // 6-digit OTP
static const int otpExpiryMinutes = 10;      // 10 minutes validity
static const int maxRetries = 3;             // 3 attempts
static const int resendDelaySeconds = 60;    // 60 seconds between resends
```

---

## 🎨 **Customization**

### **Change Primary Color**

Update `lib/config/colors.dart`:

```dart
static const Color primary = Color(0xFFFFC107);  // Golden
```

### **Change Font Family**

Update `lib/config/theme_global.dart`:

```dart
static const String fontFamilyEnglish = 'Poppins';
static const String fontFamilyArabic = 'Cairo';
```

### **Change Theme Colors**

All colors in `AppColors` class:

```dart
static const Color background = Color(0xFF0F0F0F);
static const Color darkGrey = Color(0xFF1A1A1A);
static const Color mediumGrey = Color(0xFF4A4A4A);
static const Color surface = Color(0xFFFFFFFF);
static const Color primary = Color(0xFFFFC107);
static const Color highlight = Color(0xFFFF9800);
static const Color acceptGreen = Color(0xFF4CAF50);
```

---

## 🧪 **Testing**

### **Test OTP Flow**

```dart
// In test file
test('OTP verification', () async {
  final response = await OTPService.sendOTP('+201066183456');
  expect(response.success, true);
  
  final verifyResponse = await OTPService.verifyOTP(
    '+201066183456',
    '123456',
  );
  expect(verifyResponse.success, true);
});
```

### **Test Localization**

```dart
test('Localization', () {
  final locale = Locale('ar');
  final localizations = AppLocalizations(locale);
  expect(localizations.translate('welcome'), contains('مرحبا'));
});
```

---

## 📦 **Build & Deploy**

### **Build APK**

```bash
flutter build apk --release
```

### **Build iOS**

```bash
flutter build ios --release
```

### **Build Web**

```bash
flutter build web --release
```

---

## 🐛 **Troubleshooting**

### **Fonts Not Loading**

1. Ensure fonts are in `assets/fonts/`
2. Run `flutter pub get`
3. Check `pubspec.yaml` font paths

### **i18n Not Working**

1. Verify JSON files in `assets/translations/`
2. Check locale is set in `MaterialApp`
3. Ensure `AppLocalizationsDelegate` is in `localizationsDelegates`

### **OTP Not Sending**

1. Check API credentials in `otp_service.dart`
2. Verify phone number format (include country code)
3. Check internet connection
4. Review Zentramsg API documentation

### **Modern Design Not Applying**

1. Use `main_modern.dart` instead of `main.dart`
2. Ensure `AppThemeGlobal.buildThemeData()` is used
3. Check `SafeArea` configuration in screens

---

## 📚 **Additional Resources**

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Go Router Documentation](https://pub.dev/packages/go_router)
- [Zentramsg API Documentation](https://api.zentramsg.com)
- [Material Design 3](https://m3.material.io)

---

## ✅ **Checklist**

- ✅ All dependencies installed
- ✅ Font files added
- ✅ Translation files created
- ✅ OTP API credentials configured
- ✅ Main app updated to `main_modern.dart`
- ✅ Routes configured
- ✅ Screens connected
- ✅ i18n working (EN/AR)
- ✅ Modern design applied
- ✅ Notch support enabled
- ✅ OTP integration complete
- ✅ All buttons connected
- ✅ Global font family applied

---

**Status**: ✅ **COMPLETE & READY FOR DEVELOPMENT**

**Last Updated**: January 29, 2026

The TukTuky Passenger App is now fully integrated with modern design, complete i18n support, and OTP verification!
