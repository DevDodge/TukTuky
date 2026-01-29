import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

// Location state class
class LocationState {
  final Position? currentPosition;
  final List<SavedLocation> savedLocations;
  final bool isLoading;
  final bool isGettingLocation;
  final String? error;

  LocationState({
    this.currentPosition,
    this.savedLocations = const [],
    this.isLoading = false,
    this.isGettingLocation = false,
    this.error,
  });

  LocationState copyWith({
    Position? currentPosition,
    List<SavedLocation>? savedLocations,
    bool? isLoading,
    bool? isGettingLocation,
    String? error,
  }) {
    return LocationState(
      currentPosition: currentPosition ?? this.currentPosition,
      savedLocations: savedLocations ?? this.savedLocations,
      isLoading: isLoading ?? this.isLoading,
      isGettingLocation: isGettingLocation ?? this.isGettingLocation,
      error: error ?? this.error,
    );
  }
}

// Location notifier
class LocationNotifier extends StateNotifier<LocationState> {
  final SupabaseService _supabaseService;
  final int userId;

  LocationNotifier(this._supabaseService, this.userId)
      : super(LocationState()) {
    _loadSavedLocations();
    _getCurrentLocation();
  }

  Future<void> _loadSavedLocations() async {
    state = state.copyWith(isLoading: true);
    try {
      final locations = await _supabaseService.getSavedLocations(userId);
      state = state.copyWith(
        savedLocations: locations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    state = state.copyWith(isGettingLocation: true);
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      state = state.copyWith(
        currentPosition: position,
        isGettingLocation: false,
      );
    } catch (e) {
      state = state.copyWith(
        isGettingLocation: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshCurrentLocation() async {
    await _getCurrentLocation();
  }

  Future<void> addSavedLocation(
    String name,
    String address,
    double latitude,
    double longitude,
    String type,
  ) async {
    try {
      final location = await _supabaseService.createSavedLocation(
        userId,
        {
          'name': name,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'location_type': type,
          'is_default': false,
        },
      );

      state = state.copyWith(
        savedLocations: [...state.savedLocations, location],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateSavedLocation(
    int locationId,
    String name,
    String address,
    double latitude,
    double longitude,
    String type,
  ) async {
    try {
      final updatedLocation = await _supabaseService.updateSavedLocation(
        locationId,
        {
          'name': name,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'location_type': type,
        },
      );

      state = state.copyWith(
        savedLocations: state.savedLocations
            .map((loc) => loc.id == locationId ? updatedLocation : loc)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteSavedLocation(int locationId) async {
    try {
      await _supabaseService.deleteSavedLocation(locationId);
      state = state.copyWith(
        savedLocations: state.savedLocations
            .where((loc) => loc.id != locationId)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  SavedLocation? getSavedLocationByType(String type) {
    try {
      return state.savedLocations.firstWhere(
        (loc) => loc.locationType == type,
      );
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) {
    return LocationNotifier(supabaseService, 0);
  }

  return LocationNotifier(supabaseService, currentUser.id);
});

final currentPositionProvider = Provider<Position?>((ref) {
  return ref.watch(locationProvider).currentPosition;
});

final savedLocationsProvider = Provider<List<SavedLocation>>((ref) {
  return ref.watch(locationProvider).savedLocations;
});

final homeLocationProvider = Provider<SavedLocation?>((ref) {
  final locations = ref.watch(savedLocationsProvider);
  try {
    return locations.firstWhere((loc) => loc.locationType == 'home');
  } catch (e) {
    return null;
  }
});

final workLocationProvider = Provider<SavedLocation?>((ref) {
  final locations = ref.watch(savedLocationsProvider);
  try {
    return locations.firstWhere((loc) => loc.locationType == 'work');
  } catch (e) {
    return null;
  }
});

final isLocationLoadingProvider = Provider<bool>((ref) {
  return ref.watch(locationProvider).isLoading ||
      ref.watch(locationProvider).isGettingLocation;
});
