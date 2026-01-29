import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

/// ============================================================================
/// OTP SERVICE - ZENTRAMSG API INTEGRATION
/// ============================================================================

class OTPService {
  // API Configuration
  static const String apiBaseUrl = 'https://api.zentramsg.com/v1';
  static const String deviceUUID = '50b7cfc0-d89a-4f40-8dec-67e3ade8f2dc';
  static const String apiToken = '725ad3ae-65f2-4f8c-a819-d5b18166ef2f';

  // OTP Configuration
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 10;
  static const int maxRetries = 3;
  static const int resendDelaySeconds = 60;

  // In-memory OTP storage (in production, use secure storage)
  static final Map<String, OTPData> _otpCache = {};

  /// OTP Data Model
  class OTPData {
    final String otp;
    final DateTime expiryTime;
    final int attempts;
    final DateTime createdAt;

    OTPData({
      required this.otp,
      required this.expiryTime,
      required this.attempts,
      required this.createdAt,
    });

    bool get isExpired => DateTime.now().isAfter(expiryTime);
    int get remainingSeconds => expiryTime.difference(DateTime.now()).inSeconds;
  }

  /// Generate random OTP
  static String _generateOTP() {
    final random = Random();
    String otp = '';
    for (int i = 0; i < otpLength; i++) {
      otp += random.nextInt(10).toString();
    }
    return otp;
  }

  /// Send OTP via SMS using Zentramsg API
  static Future<OTPResponse> sendOTP(String phoneNumber) async {
    try {
      // Validate phone number
      if (phoneNumber.isEmpty) {
        return OTPResponse(
          success: false,
          message: 'Phone number is required',
          errorCode: 'INVALID_PHONE',
        );
      }

      // Generate OTP
      final otp = _generateOTP();
      final expiryTime = DateTime.now().add(
        const Duration(minutes: otpExpiryMinutes),
      );

      // Store OTP
      _otpCache[phoneNumber] = OTPData(
        otp: otp,
        expiryTime: expiryTime,
        attempts: 0,
        createdAt: DateTime.now(),
      );

      // Prepare message
      final message = 'Your TukTuky verification code is: $otp. Valid for $otpExpiryMinutes minutes.';

      // Send SMS
      final response = await _sendSMS(phoneNumber, message);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OTPResponse(
          success: true,
          message: 'OTP sent successfully',
          phoneNumber: phoneNumber,
          expiryTime: expiryTime,
          remainingSeconds: otpExpiryMinutes * 60,
        );
      } else {
        return OTPResponse(
          success: false,
          message: 'Failed to send OTP',
          errorCode: 'SMS_SEND_FAILED',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return OTPResponse(
        success: false,
        message: 'Error: ${e.toString()}',
        errorCode: 'SEND_OTP_ERROR',
      );
    }
  }

  /// Send SMS via Zentramsg API
  static Future<http.Response> _sendSMS(String phoneNumber, String message) async {
    try {
      // Format phone number (ensure it starts with country code)
      String formattedPhone = phoneNumber;
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+$formattedPhone';
      }
      // Remove + for API
      formattedPhone = formattedPhone.replaceAll('+', '');

      final uri = Uri.parse('$apiBaseUrl/messages');
      
      var request = http.MultipartRequest('POST', uri);
      request.headers['x-api-token'] = apiToken;
      request.headers['accept'] = '*/*';

      request.fields['device_uuid'] = deviceUUID;
      request.fields['text_message'] = message;
      request.fields['type_message'] = 'text';
      request.fields['type_contact'] = 'numbers';
      request.fields['ids'] = formattedPhone;

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception('SMS sending failed: ${e.toString()}');
    }
  }

  /// Verify OTP
  static Future<OTPResponse> verifyOTP(String phoneNumber, String enteredOTP) async {
    try {
      // Check if OTP exists
      if (!_otpCache.containsKey(phoneNumber)) {
        return OTPResponse(
          success: false,
          message: 'No OTP found for this phone number',
          errorCode: 'NO_OTP_FOUND',
        );
      }

      final otpData = _otpCache[phoneNumber]!;

      // Check if OTP is expired
      if (otpData.isExpired) {
        _otpCache.remove(phoneNumber);
        return OTPResponse(
          success: false,
          message: 'OTP has expired. Please request a new one.',
          errorCode: 'OTP_EXPIRED',
        );
      }

      // Check attempts
      if (otpData.attempts >= maxRetries) {
        _otpCache.remove(phoneNumber);
        return OTPResponse(
          success: false,
          message: 'Maximum attempts exceeded. Please request a new OTP.',
          errorCode: 'MAX_ATTEMPTS_EXCEEDED',
        );
      }

      // Verify OTP
      if (otpData.otp == enteredOTP) {
        // OTP verified successfully
        _otpCache.remove(phoneNumber);
        return OTPResponse(
          success: true,
          message: 'OTP verified successfully',
          phoneNumber: phoneNumber,
          token: _generateAuthToken(phoneNumber),
        );
      } else {
        // Increment attempts
        _otpCache[phoneNumber] = OTPData(
          otp: otpData.otp,
          expiryTime: otpData.expiryTime,
          attempts: otpData.attempts + 1,
          createdAt: otpData.createdAt,
        );

        final remainingAttempts = maxRetries - (otpData.attempts + 1);
        return OTPResponse(
          success: false,
          message: 'Invalid OTP. $remainingAttempts attempts remaining.',
          errorCode: 'INVALID_OTP',
          remainingAttempts: remainingAttempts,
        );
      }
    } catch (e) {
      return OTPResponse(
        success: false,
        message: 'Error: ${e.toString()}',
        errorCode: 'VERIFY_OTP_ERROR',
      );
    }
  }

  /// Resend OTP
  static Future<OTPResponse> resendOTP(String phoneNumber) async {
    try {
      // Check if OTP exists and is not expired
      if (_otpCache.containsKey(phoneNumber)) {
        final otpData = _otpCache[phoneNumber]!;
        if (!otpData.isExpired) {
          // Check if enough time has passed since last send
          final timeSinceCreation = DateTime.now().difference(otpData.createdAt).inSeconds;
          if (timeSinceCreation < resendDelaySeconds) {
            final waitTime = resendDelaySeconds - timeSinceCreation;
            return OTPResponse(
              success: false,
              message: 'Please wait $waitTime seconds before resending OTP',
              errorCode: 'RESEND_COOLDOWN',
              remainingSeconds: waitTime,
            );
          }
        }
      }

      // Send new OTP
      return await sendOTP(phoneNumber);
    } catch (e) {
      return OTPResponse(
        success: false,
        message: 'Error: ${e.toString()}',
        errorCode: 'RESEND_OTP_ERROR',
      );
    }
  }

  /// Generate auth token (mock implementation)
  static String _generateAuthToken(String phoneNumber) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random();
    final randomPart = List.generate(16, (_) => random.nextInt(256)).join();
    return 'auth_${phoneNumber}_${timestamp}_$randomPart';
  }

  /// Get remaining time for OTP
  static int? getRemainingSeconds(String phoneNumber) {
    if (_otpCache.containsKey(phoneNumber)) {
      final otpData = _otpCache[phoneNumber]!;
      if (!otpData.isExpired) {
        return otpData.remainingSeconds;
      }
    }
    return null;
  }

  /// Clear OTP
  static void clearOTP(String phoneNumber) {
    _otpCache.remove(phoneNumber);
  }

  /// Clear all OTPs
  static void clearAllOTPs() {
    _otpCache.clear();
  }
}

/// ============================================================================
/// OTP RESPONSE MODEL
/// ============================================================================

class OTPResponse {
  final bool success;
  final String message;
  final String? phoneNumber;
  final String? token;
  final String? errorCode;
  final DateTime? expiryTime;
  final int? remainingSeconds;
  final int? remainingAttempts;
  final int? statusCode;

  OTPResponse({
    required this.success,
    required this.message,
    this.phoneNumber,
    this.token,
    this.errorCode,
    this.expiryTime,
    this.remainingSeconds,
    this.remainingAttempts,
    this.statusCode,
  });

  @override
  String toString() {
    return 'OTPResponse(success: $success, message: $message, errorCode: $errorCode)';
  }
}
