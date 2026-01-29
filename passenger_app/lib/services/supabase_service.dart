import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../models/models.dart' as models;

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient _client;
  final logger = Logger();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  Future<void> initialize(String url, String anonKey) async {
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      _client = Supabase.instance.client;
      logger.i('Supabase initialized successfully');
    } catch (e) {
      logger.e('Failed to initialize Supabase: $e');
      rethrow;
    }
  }

  SupabaseClient get client => _client;

  // ==================== USER OPERATIONS ====================

  Future<models.User?> getCurrentUser() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) return null;

      final response = await _client
          .from('users')
          .select()
          .eq('open_id', session.user.id)
          .single();

      return User.fromJson(response);
    } catch (e) {
      logger.e('Error getting current user: $e');
      return null;
    }
  }

  Future<models.User> updateUserProfile(int userId, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('users')
          .update(data)
          .eq('id', userId)
          .select()
          .single();

      return User.fromJson(response);
    } catch (e) {
      logger.e('Error updating user profile: $e');
      rethrow;
    }
  }

  // ==================== TRIP OPERATIONS ====================

  Future<models.Trip> createTrip(Map<String, dynamic> tripData) async {
    try {
      final response = await _client
          .from('trips')
          .insert(tripData)
          .select()
          .single();

      return Trip.fromJson(response);
    } catch (e) {
      logger.e('Error creating trip: $e');
      rethrow;
    }
  }

  Future<models.Trip?> getTrip(int tripId) async {
    try {
      final response = await _client
          .from('trips')
          .select()
          .eq('id', tripId)
          .single();

      return Trip.fromJson(response);
    } catch (e) {
      logger.e('Error getting trip: $e');
      return null;
    }
  }

  Future<List<models.Trip>> getUserTrips(int userId, {int limit = 10, int offset = 0}) async {
    try {
      final response = await _client
          .from('trips')
          .select()
          .eq('passenger_id', userId)
          .order('requested_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((trip) => Trip.fromJson(trip))
          .toList();
    } catch (e) {
      logger.e('Error getting user trips: $e');
      return [];
    }
  }

  Future<models.Trip> updateTripStatus(int tripId, String status) async {
    try {
      final response = await _client
          .from('trips')
          .update({'status': status})
          .eq('id', tripId)
          .select()
          .single();

      return Trip.fromJson(response);
    } catch (e) {
      logger.e('Error updating trip status: $e');
      rethrow;
    }
  }

  Future<void> cancelTrip(int tripId, String reason) async {
    try {
      await _client
          .from('trips')
          .update({
            'status': 'cancelled_by_passenger',
            'cancellation_reason': reason,
          })
          .eq('id', tripId);
    } catch (e) {
      logger.e('Error cancelling trip: $e');
      rethrow;
    }
  }

  // ==================== DRIVER OFFERS ====================

  Stream<List<models.DriverOffer>> watchTripOffers(int tripId) {
    return _client
        .from('driver_offers')
        .stream(primaryKey: ['id'])
        .eq('trip_id', tripId)
        .map((offers) => (offers as List)
            .map((offer) => DriverOffer.fromJson(offer))
            .toList());
  }

  Future<models.DriverOffer?> acceptOffer(int offerId) async {
    try {
      final response = await _client
          .from('driver_offers')
          .update({'status': 'accepted'})
          .eq('id', offerId)
          .select()
          .single();

      return DriverOffer.fromJson(response);
    } catch (e) {
      logger.e('Error accepting offer: $e');
      return null;
    }
  }

  Future<void> rejectOffer(int offerId) async {
    try {
      await _client
          .from('driver_offers')
          .update({'status': 'rejected'})
          .eq('id', offerId);
    } catch (e) {
      logger.e('Error rejecting offer: $e');
      rethrow;
    }
  }

  // ==================== WALLET OPERATIONS ====================

  Future<models.Wallet?> getWallet(int userId) async {
    try {
      final response = await _client
          .from('wallets')
          .select()
          .eq('user_id', userId)
          .single();

      return Wallet.fromJson(response);
    } catch (e) {
      logger.e('Error getting wallet: $e');
      return null;
    }
  }

  Stream<models.Wallet?> watchWallet(int userId) {
    return _client
        .from('wallets')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((wallets) => wallets.isNotEmpty ? Wallet.fromJson(wallets[0]) : null);
  }

  // ==================== SAVED LOCATIONS ====================

  Future<List<models.SavedLocation>> getSavedLocations(int userId) async {
    try {
      final response = await _client
          .from('saved_locations')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false);

      return (response as List)
          .map((location) => SavedLocation.fromJson(location))
          .toList();
    } catch (e) {
      logger.e('Error getting saved locations: $e');
      return [];
    }
  }

  Future<models.SavedLocation> createSavedLocation(
      int userId, Map<String, dynamic> locationData) async {
    try {
      locationData['user_id'] = userId;
      final response = await _client
          .from('saved_locations')
          .insert(locationData)
          .select()
          .single();

      return SavedLocation.fromJson(response);
    } catch (e) {
      logger.e('Error creating saved location: $e');
      rethrow;
    }
  }

  Future<void> deleteSavedLocation(int locationId) async {
    try {
      await _client
          .from('saved_locations')
          .delete()
          .eq('id', locationId);
    } catch (e) {
      logger.e('Error deleting saved location: $e');
      rethrow;
    }
  }

  // ==================== RATINGS ====================

  Future<void> submitRating(Map<String, dynamic> ratingData) async {
    try {
      await _client.from('ratings').insert(ratingData);
    } catch (e) {
      logger.e('Error submitting rating: $e');
      rethrow;
    }
  }

  // ==================== PROMO CODES ====================

  Future<List<models.PromoCode>> getAvailablePromoCodes() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _client
          .from('promo_codes')
          .select()
          .eq('is_active', true)
          .gt('valid_until', now)
          .lt('valid_from', now);

      return (response as List)
          .map((code) => PromoCode.fromJson(code))
          .toList();
    } catch (e) {
      logger.e('Error getting promo codes: $e');
      return [];
    }
  }

  Future<models.PromoCode?> validatePromoCode(String code) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _client
          .from('promo_codes')
          .select()
          .eq('code', code)
          .eq('is_active', true)
          .gt('valid_until', now)
          .lt('valid_from', now)
          .single();

      return PromoCode.fromJson(response);
    } catch (e) {
      logger.e('Error validating promo code: $e');
      return null;
    }
  }

  // ==================== SUPPORT TICKETS ====================

  Future<void> createSupportTicket(Map<String, dynamic> ticketData) async {
    try {
      await _client.from('support_tickets').insert(ticketData);
    } catch (e) {
      logger.e('Error creating support ticket: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSupportTickets(int userId) async {
    try {
      final response = await _client
          .from('support_tickets')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      logger.e('Error getting support tickets: $e');
      return [];
    }
  }

  Future<void> addTicketMessage(int ticketId, String message) async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) throw Exception('User not authenticated');

      final user = await getCurrentUser();
      if (user == null) throw Exception('User not found');

      await _client.from('ticket_messages').insert({
        'ticket_id': ticketId,
        'sender_id': user.id,
        'message': message,
        'is_staff': false,
      });
    } catch (e) {
      logger.e('Error adding ticket message: $e');
      rethrow;
    }
  }

  // ==================== EMERGENCY CONTACTS ====================

  Future<List<Map<String, dynamic>>> getEmergencyContacts(int userId) async {
    try {
      final response = await _client
          .from('emergency_contacts')
          .select()
          .eq('user_id', userId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      logger.e('Error getting emergency contacts: $e');
      return [];
    }
  }

  Future<void> createEmergencyContact(
      int userId, Map<String, dynamic> contactData) async {
    try {
      contactData['user_id'] = userId;
      await _client.from('emergency_contacts').insert(contactData);
    } catch (e) {
      logger.e('Error creating emergency contact: $e');
      rethrow;
    }
  }

  // ==================== SOS ALERTS ====================

  Future<void> triggerSOS(int tripId, double lat, double lng) async {
    try {
      final user = await getCurrentUser();
      if (user == null) throw Exception('User not found');

      await _client.from('sos_alerts').insert({
        'trip_id': tripId,
        'triggered_by': user.id,
        'latitude': lat,
        'longitude': lng,
        'status': 'active',
      });
    } catch (e) {
      logger.e('Error triggering SOS: $e');
      rethrow;
    }
  }

  // ==================== NOTIFICATIONS ====================

  Stream<List<Map<String, dynamic>>> watchNotifications(int userId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((notifications) => List<Map<String, dynamic>>.from(notifications));
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      logger.e('Error marking notification as read: $e');
      rethrow;
    }
  }

  // ==================== TRIP TRACKING ====================

  Future<void> recordTripLocation(
      int tripId, double lat, double lng, double? speed, double? heading) async {
    try {
      await _client.from('trip_tracking').insert({
        'trip_id': tripId,
        'latitude': lat,
        'longitude': lng,
        'speed': speed,
        'heading': heading,
      });
    } catch (e) {
      logger.e('Error recording trip location: $e');
      // Don't rethrow - location tracking should not block trip
    }
  }

  // ==================== PRICING CONFIG ====================

  Future<Map<String, dynamic>?> getPricingConfig() async {
    try {
      final response = await _client
          .from('pricing_config')
          .select()
          .eq('is_active', true)
          .single();

      return response;
    } catch (e) {
      logger.e('Error getting pricing config: $e');
      return null;
    }
  }

  // ==================== ZONES ====================

  Future<List<Map<String, dynamic>>> getZones() async {
    try {
      final response = await _client
          .from('zones')
          .select()
          .eq('is_active', true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      logger.e('Error getting zones: $e');
      return [];
    }
  }

  // ==================== AUTHENTICATION ====================

  Future<AuthResponse> signInWithGoogle(String idToken) async {
    try {
      return await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } catch (e) {
      logger.e('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signInWithApple(String idToken) async {
    try {
      return await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );
    } catch (e) {
      logger.e('Error signing in with Apple: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      logger.e('Error signing out: $e');
      rethrow;
    }
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  models.User? get currentUser {
    final session = _client.auth.currentSession;
    return session != null ? models.User(
      id: 0,
      openId: session.user.id,
      email: session.user.email,
      phone: session.user.phone,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastSignedIn: DateTime.now(),
    ) : null;
  }
}
