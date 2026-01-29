class AppConstants {
  // API Configuration
  static const String supabaseUrl = 'https://ruxygwkcpyhcekkgytmp.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_KW8ZbblignMjnqhKWuh35Q_qtgpFfcJ';
  static const String googleMapsApiKey = 'AIzaSyBy_Ee_CKO3CrMF7TLofcLPT4ANvm9NVR8';
  static const String firebaseProjectId = 'dk-tuktuky';
  
  // Payment Gateway Keys
  static const String paymobApiKey = 'YOUR_PAYMOB_API_KEY';
  static const String fawryMerchantCode = 'YOUR_FAWRY_MERCHANT_CODE';
  
  // App Configuration
  static const String appName = 'TukTuky';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration locationTimeout = Duration(seconds: 15);
  static const Duration otpTimeout = Duration(seconds: 60);
  static const Duration tripTimeout = Duration(minutes: 5);
  
  // Limits
  static const int maxEmergencyContacts = 3;
  static const int maxSavedLocations = 10;
  static const int maxPromoCodesPerTrip = 1;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int otpLength = 6;
  
  // Pricing
  static const double minimumFare = 10.0;
  static const double baseFare = 10.0;
  static const double perKmRate = 2.5;
  static const double perMinuteRate = 0.5;
  static const double cancellationFeePassenger = 5.0;
  static const double cancellationFeeDriver = 2.0;
  static const int freeCancellationMinutes = 2;
  
  // Trip Status
  static const String tripStatusRequested = 'requested';
  static const String tripStatusBidding = 'bidding';
  static const String tripStatusSearching = 'searching';
  static const String tripStatusDriverAssigned = 'driver_assigned';
  static const String tripStatusDriverArrived = 'driver_arrived';
  static const String tripStatusInTrip = 'in_trip';
  static const String tripStatusCompleted = 'completed';
  static const String tripStatusCancelledByPassenger = 'cancelled_by_passenger';
  static const String tripStatusCancelledByDriver = 'cancelled_by_driver';
  static const String tripStatusCancelledTimeout = 'cancelled_timeout';
  
  // Payment Methods
  static const String paymentMethodCash = 'cash';
  static const String paymentMethodWallet = 'wallet';
  static const String paymentMethodCard = 'card';
  static const String paymentMethodMobileWallet = 'mobile_wallet';
  
  // Payment Status
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusAuthorized = 'authorized';
  static const String paymentStatusCaptured = 'captured';
  static const String paymentStatusFailed = 'failed';
  static const String paymentStatusRefunded = 'refunded';
  
  // User Roles
  static const String rolePassenger = 'passenger';
  static const String roleDriver = 'driver';
  static const String roleAdmin = 'admin';
  
  // Languages
  static const String languageArabic = 'ar';
  static const String languageEnglish = 'en';
  
  // Location Types
  static const String locationTypeHome = 'home';
  static const String locationTypeWork = 'work';
  static const String locationTypeOther = 'other';
  
  // Discount Types
  static const String discountTypePercentage = 'percentage';
  static const String discountTypeFixed = 'fixed';
  
  // Offer Status
  static const String offerStatusPending = 'pending';
  static const String offerStatusAccepted = 'accepted';
  static const String offerStatusRejected = 'rejected';
  static const String offerStatusWithdrawn = 'withdrawn';
  static const String offerStatusExpired = 'expired';
  
  // Rating Limits
  static const double minRating = 1.0;
  static const double maxRating = 5.0;
  
  // Map Configuration
  static const double defaultMapZoom = 15.0;
  static const double pickupMarkerZoom = 17.0;
  static const double defaultLocationAccuracy = 100.0;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Refresh Intervals
  static const Duration locationRefreshInterval = Duration(seconds: 5);
  static const Duration tripStatusRefreshInterval = Duration(seconds: 3);
  static const Duration walletRefreshInterval = Duration(seconds: 10);
  
  // Regex Patterns
  static const String phonePattern = r'^\+20[0-9]{9}$';
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String referralCodePattern = r'^[A-Z0-9]{6,10}$';
  
  // Error Messages
  static const String errorNetworkConnection = 'No internet connection';
  static const String errorServerError = 'Server error occurred';
  static const String errorInvalidCredentials = 'Invalid credentials';
  static const String errorUserNotFound = 'User not found';
  static const String errorLocationPermission = 'Location permission denied';
  static const String errorCameraPermission = 'Camera permission denied';
  
  // Success Messages
  static const String successLoginMessage = 'Login successful';
  static const String successLogoutMessage = 'Logout successful';
  static const String successTripBooked = 'Trip booked successfully';
  static const String successOfferAccepted = 'Offer accepted';
  static const String successProfileUpdated = 'Profile updated';
  static const String successLocationSaved = 'Location saved';
  
  // Empty State Messages
  static const String emptyTripsMessage = 'No trips yet';
  static const String emptyOffersMessage = 'No offers received';
  static const String emptyLocationsMessage = 'No saved locations';
  static const String emptyContactsMessage = 'No emergency contacts';
  
  // Validation Messages
  static const String validationPhoneRequired = 'Phone number is required';
  static const String validationPhoneInvalid = 'Invalid phone number';
  static const String validationPasswordRequired = 'Password is required';
  static const String validationPasswordTooShort = 'Password must be at least 8 characters';
  static const String validationEmailInvalid = 'Invalid email address';
  
  // Share Messages
  static const String shareReferralMessage = 'Join TukTuky and get EGP 50 credit! Use my code: ';
  static const String shareTripMessage = 'I\'m on my way with TukTuky. Track my live location: ';
  
  // URLs
  static const String privacyPolicyUrl = 'https://tuktuk.com/privacy';
  static const String termsOfServiceUrl = 'https://tuktuk.com/terms';
  static const String supportUrl = 'https://support.tuktuk.com';
  static const String websiteUrl = 'https://tuktuk.com';
}
