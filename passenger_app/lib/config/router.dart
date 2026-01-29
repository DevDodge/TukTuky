import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/search_location_screen.dart';
import '../screens/trip/trip_booking_screen.dart';
import '../screens/trip/bidding_screen.dart';
import '../screens/trip/driver_arriving_screen.dart';
import '../screens/trip/trip_in_progress_screen.dart';
import '../screens/trip/trip_completed_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/saved_locations_screen.dart';
import '../screens/profile/emergency_contacts_screen.dart';
import '../screens/support/support_screen.dart';

class AppRoutes {
  // Route paths
  static const String splash = '/splash';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String searchLocation = '/search-location';
  static const String tripBooking = '/booking';
  static const String bidding = '/bidding';
  static const String driverArriving = '/driver-arriving';
  static const String tripInProgress = '/trip-in-progress';
  static const String tripCompleted = '/trip-completed';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
  static const String savedLocations = '/saved-locations';
  static const String emergencyContacts = '/emergency-contacts';
  static const String support = '/support';
}

final router = GoRouter(
  initialLocation: AppRoutes.splash,
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Page not found'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Go to Home'),
          ),
        ],
      ),
    ),
  ),
  routes: [
    // Splash Screen
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Authentication Routes
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: AppRoutes.otp,
      name: 'otp',
      builder: (context, state) {
        final phone = state.extra as String?;
        return OtpScreen(phone: phone ?? '');
      },
    ),

    // Home Routes
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: AppRoutes.searchLocation,
      name: 'searchLocation',
      builder: (context, state) {
        final locationType = state.extra as String?;
        return SearchLocationScreen(locationType: locationType ?? 'pickup');
      },
    ),

    // Trip Routes
    GoRoute(
      path: AppRoutes.tripBooking,
      name: 'tripBooking',
      builder: (context, state) {
        final params = state.extra as Map<String, dynamic>?;
        return TripBookingScreen(
          pickupLat: params?['pickupLat'] ?? 0.0,
          pickupLng: params?['pickupLng'] ?? 0.0,
          pickupAddress: params?['pickupAddress'] ?? '',
          dropoffLat: params?['dropoffLat'] ?? 0.0,
          dropoffLng: params?['dropoffLng'] ?? 0.0,
          dropoffAddress: params?['dropoffAddress'] ?? '',
        );
      },
    ),

    GoRoute(
      path: '${AppRoutes.bidding}/:tripId',
      name: 'bidding',
      builder: (context, state) => const BiddingScreen(),
    ),

    GoRoute(
      path: '${AppRoutes.driverArriving}/:tripId',
      name: 'driverArriving',
      builder: (context, state) => const DriverArrivingScreen(),
    ),

    GoRoute(
      path: '${AppRoutes.tripInProgress}/:tripId',
      name: 'tripInProgress',
      builder: (context, state) => const TripInProgressScreen(),
    ),

    GoRoute(
      path: '${AppRoutes.tripCompleted}/:tripId',
      name: 'tripCompleted',
      builder: (context, state) => const TripCompletedScreen(),
    ),

    // Wallet Routes
    GoRoute(
      path: AppRoutes.wallet,
      name: 'wallet',
      builder: (context, state) => const WalletScreen(),
    ),

    // Profile Routes
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),

    GoRoute(
      path: AppRoutes.savedLocations,
      name: 'savedLocations',
      builder: (context, state) => const SavedLocationsScreen(),
    ),

    GoRoute(
      path: AppRoutes.emergencyContacts,
      name: 'emergencyContacts',
      builder: (context, state) => const EmergencyContactsScreen(),
    ),

    // Support Routes
    GoRoute(
      path: AppRoutes.support,
      name: 'support',
      builder: (context, state) => const SupportScreen(),
    ),
  ],
);
