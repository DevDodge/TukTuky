import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

// Wallet state class
class WalletState {
  final Wallet? wallet;
  final List<Map<String, dynamic>> transactions;
  final bool isLoading;
  final String? error;

  WalletState({
    this.wallet,
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  WalletState copyWith({
    Wallet? wallet,
    List<Map<String, dynamic>>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Wallet notifier
class WalletNotifier extends StateNotifier<WalletState> {
  final SupabaseService _supabaseService;
  final int userId;

  WalletNotifier(this._supabaseService, this.userId)
      : super(WalletState()) {
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    state = state.copyWith(isLoading: true);
    try {
      final wallet = await _supabaseService.getWallet(userId);
      if (wallet != null) {
        state = state.copyWith(
          wallet: wallet,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void watchWallet() {
    _supabaseService.watchWallet(userId).listen((wallet) {
      state = state.copyWith(wallet: wallet);
    });
  }

  Future<void> topUpWallet(double amount, String paymentMethod) async {
    try {
      // This would typically call a backend endpoint
      // For now, we'll just update the local state
      if (state.wallet != null) {
        final updatedWallet = state.wallet!.copyWith(
          balance: state.wallet!.balance + amount,
        );
        state = state.copyWith(wallet: updatedWallet);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deductFromWallet(double amount, String reason) async {
    try {
      if (state.wallet != null && state.wallet!.balance >= amount) {
        final updatedWallet = state.wallet!.copyWith(
          balance: state.wallet!.balance - amount,
        );
        state = state.copyWith(wallet: updatedWallet);
      } else {
        throw Exception('Insufficient wallet balance');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) {
    return WalletNotifier(supabaseService, 0);
  }

  final notifier = WalletNotifier(supabaseService, currentUser.id);
  notifier.watchWallet();
  return notifier;
});

final walletBalanceProvider = Provider<double>((ref) {
  return ref.watch(walletProvider).wallet?.balance ?? 0.0;
});

final walletTransactionsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(walletProvider).transactions;
});

final isWalletLoadingProvider = Provider<bool>((ref) {
  return ref.watch(walletProvider).isLoading;
});
