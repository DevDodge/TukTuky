import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '../models/models.dart' hide User;
import '../models/models.dart' as models;
import '../services/supabase_service.dart';

// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<models.User?>> {
  final SupabaseService _supabaseService;

  AuthNotifier(this._supabaseService) : super(const AsyncValue.loading()) {
    _initializeAuth();
  }

  void _initializeAuth() async {
    try {
      // Check if user is already logged in
      var user = await _supabaseService.getCurrentUser();
      
      // If auth session exists but no user record, try to create one
      if (user == null && _supabaseService.client.auth.currentSession != null) {
        // User is authenticated but has no database record - ensure one exists
        user = await _supabaseService.ensureUserRecordExists();
      }
      
      if (user != null) {
        state = AsyncValue.data(user);
      } else {
        state = const AsyncValue.data(null);
      }

      // Listen to auth state changes
      _supabaseService.authStateChanges.listen((authState) {
        if (authState.session != null) {
          _loadUser();
        } else {
          state = const AsyncValue.data(null);
        }
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _loadUser() async {
    try {
      var user = await _supabaseService.getCurrentUser();
      
      // If auth session exists but no user record, create one
      if (user == null && _supabaseService.client.auth.currentSession != null) {
        user = await _supabaseService.ensureUserRecordExists();
      }
      
      if (user != null) {
        state = AsyncValue.data(user);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle(String idToken) async {
    state = const AsyncValue.loading();
    try {
      await _supabaseService.signInWithGoogle(idToken);
      await _loadUser();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithApple(String idToken) async {
    state = const AsyncValue.loading();
    try {
      await _supabaseService.signInWithApple(idToken);
      await _loadUser();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final currentUser = state.maybeWhen(
      data: (user) => user,
      orElse: () => null,
    );

    if (currentUser == null) return;

    try {
      final updatedUser = await _supabaseService.updateUserProfile(
        currentUser.id,
        data,
      );
      state = AsyncValue.data(updatedUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Providers
final supabaseServiceProvider = Provider<SupabaseService>((ref) => SupabaseService());

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<models.User?>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthNotifier(supabaseService);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );
});

final currentUserProvider = Provider<models.User?>((ref) {
  return ref.watch(authProvider).maybeWhen(
        data: (user) => user,
        orElse: () => null,
      );
});
