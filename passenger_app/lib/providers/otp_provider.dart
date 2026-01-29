import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/otp_service.dart';

/// ============================================================================
/// OTP STATE NOTIFIER
/// ============================================================================

class OTPState {
  final bool isLoading;
  final bool isOTPSent;
  final String? phoneNumber;
  final String? message;
  final String? errorMessage;
  final int? remainingSeconds;
  final int? remainingAttempts;
  final bool isVerified;
  final String? authToken;

  const OTPState({
    this.isLoading = false,
    this.isOTPSent = false,
    this.phoneNumber,
    this.message,
    this.errorMessage,
    this.remainingSeconds,
    this.remainingAttempts,
    this.isVerified = false,
    this.authToken,
  });

  OTPState copyWith({
    bool? isLoading,
    bool? isOTPSent,
    String? phoneNumber,
    String? message,
    String? errorMessage,
    int? remainingSeconds,
    int? remainingAttempts,
    bool? isVerified,
    String? authToken,
  }) {
    return OTPState(
      isLoading: isLoading ?? this.isLoading,
      isOTPSent: isOTPSent ?? this.isOTPSent,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      remainingAttempts: remainingAttempts ?? this.remainingAttempts,
      isVerified: isVerified ?? this.isVerified,
      authToken: authToken ?? this.authToken,
    );
  }
}

/// OTP State Notifier
class OTPNotifier extends StateNotifier<OTPState> {
  OTPNotifier() : super(const OTPState());

  /// Send OTP
  Future<void> sendOTP(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await OTPService.sendOTP(phoneNumber);

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          isOTPSent: true,
          phoneNumber: phoneNumber,
          message: response.message,
          remainingSeconds: response.remainingSeconds,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isOTPSent: false,
          errorMessage: response.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isOTPSent: false,
        errorMessage: 'Failed to send OTP: ${e.toString()}',
      );
    }
  }

  /// Verify OTP
  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await OTPService.verifyOTP(phoneNumber, otp);

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          isVerified: true,
          message: response.message,
          authToken: response.token,
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          isVerified: false,
          errorMessage: response.message,
          remainingAttempts: response.remainingAttempts,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isVerified: false,
        errorMessage: 'Failed to verify OTP: ${e.toString()}',
      );
      return false;
    }
  }

  /// Resend OTP
  Future<void> resendOTP(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await OTPService.resendOTP(phoneNumber);

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          isOTPSent: true,
          message: response.message,
          remainingSeconds: response.remainingSeconds,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
          remainingSeconds: response.remainingSeconds,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to resend OTP: ${e.toString()}',
      );
    }
  }

  /// Reset state
  void reset() {
    state = const OTPState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// ============================================================================
/// OTP PROVIDERS
/// ============================================================================

final otpProvider = StateNotifierProvider<OTPNotifier, OTPState>(
  (ref) => OTPNotifier(),
);

/// Timer provider for countdown
final otpTimerProvider = StreamProvider.autoDispose<int>((ref) async* {
  final otpState = ref.watch(otpProvider);
  
  if (otpState.isOTPSent && otpState.phoneNumber != null) {
    int remaining = otpState.remainingSeconds ?? 600;
    
    while (remaining > 0) {
      yield remaining;
      remaining--;
      await Future.delayed(const Duration(seconds: 1));
    }
  }
});
