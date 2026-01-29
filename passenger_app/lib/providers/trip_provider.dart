import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

// Trip state class
class TripState {
  final Trip? currentTrip;
  final List<Trip> recentTrips;
  final List<DriverOffer> offers;
  final int viewsCount;
  final int offersCount;
  final bool isLoading;
  final String? error;

  TripState({
    this.currentTrip,
    this.recentTrips = const [],
    this.offers = const [],
    this.viewsCount = 0,
    this.offersCount = 0,
    this.isLoading = false,
    this.error,
  });

  TripState copyWith({
    Trip? currentTrip,
    List<Trip>? recentTrips,
    List<DriverOffer>? offers,
    int? viewsCount,
    int? offersCount,
    bool? isLoading,
    String? error,
  }) {
    return TripState(
      currentTrip: currentTrip ?? this.currentTrip,
      recentTrips: recentTrips ?? this.recentTrips,
      offers: offers ?? this.offers,
      viewsCount: viewsCount ?? this.viewsCount,
      offersCount: offersCount ?? this.offersCount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Trip notifier
class TripNotifier extends StateNotifier<TripState> {
  final SupabaseService _supabaseService;
  final String userId;

  TripNotifier(this._supabaseService, this.userId)
      : super(TripState()) {
    _loadRecentTrips();
  }

  Future<void> _loadRecentTrips() async {
    state = state.copyWith(isLoading: true);
    try {
      final trips = await _supabaseService.getUserTrips(
        int.parse(userId),
        limit: 10,
      );
      state = state.copyWith(
        recentTrips: trips,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createTrip({
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffAddress,
    required double offeredFare,
    required String paymentMethod,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final trip = await _supabaseService.createTrip({
        'passenger_id': int.parse(userId),
        'status': 'requested',
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'pickup_address': pickupAddress,
        'dropoff_lat': dropoffLat,
        'dropoff_lng': dropoffLng,
        'dropoff_address': dropoffAddress,
        'passenger_offered_fare': offeredFare,
        'payment_method': paymentMethod,
        'payment_status': 'pending',
      });

      state = state.copyWith(
        currentTrip: trip,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateTripStatus(int tripId, String status) async {
    try {
      final trip = await _supabaseService.updateTripStatus(tripId, status);
      state = state.copyWith(currentTrip: trip);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> cancelTrip(int tripId, String reason) async {
    try {
      await _supabaseService.cancelTrip(tripId, reason);
      state = state.copyWith(currentTrip: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> acceptOffer(int offerId) async {
    try {
      await _supabaseService.acceptOffer(offerId);
      // Update current trip status
      if (state.currentTrip != null) {
        await updateTripStatus(state.currentTrip!.id, 'driver_assigned');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> rejectOffer(int offerId) async {
    try {
      await _supabaseService.rejectOffer(offerId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void watchTripOffers(int tripId) {
    _supabaseService.watchTripOffers(tripId).listen((offers) {
      state = state.copyWith(
        offers: offers,
        offersCount: offers.length,
      );
    });
  }

  void clearCurrentTrip() {
    state = state.copyWith(currentTrip: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final tripProvider = StateNotifierProvider<TripNotifier, TripState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) {
    return TripNotifier(supabaseService, '0');
  }

  return TripNotifier(supabaseService, currentUser.id.toString());
});

final currentTripProvider = Provider<Trip?>((ref) {
  return ref.watch(tripProvider).currentTrip;
});

final recentTripsProvider = Provider<List<Trip>>((ref) {
  return ref.watch(tripProvider).recentTrips;
});

final tripOffersProvider = Provider<List<DriverOffer>>((ref) {
  return ref.watch(tripProvider).offers;
});

final tripOffersCountProvider = Provider<int>((ref) {
  return ref.watch(tripProvider).offersCount;
});

final tripViewsCountProvider = Provider<int>((ref) {
  return ref.watch(tripProvider).viewsCount;
});
