import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/theme.dart';
import '../../config/modern_theme.dart';
import '../../widgets/advanced_components.dart';
import '../../widgets/gesture_handlers.dart';
import '../../providers/otp_provider.dart';

/// Modern OTP Verification Screen with Complete Integration
class OTPScreenModern extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OTPScreenModern({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  ConsumerState<OTPScreenModern> createState() => _OTPScreenModernState();
}

class _OTPScreenModernState extends ConsumerState<OTPScreenModern>
    with TickerProviderStateMixin {
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _focusNodes;
  late AnimationController _shakeController;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _initializeControllers() {
    _otpControllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  String _getOTPValue() {
    return _otpControllers.map((c) => c.text).join();
  }

  void _handleOTPInput(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _handleBackspace(int index, String value) {
    if (value.isEmpty && index > 0) {
      _otpControllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _getOTPValue();

    if (otp.length != 6) {
      ModernToast.error(context, 'Please enter all 6 digits');
      return;
    }

    setState(() => _isVerifying = true);
    await ModernTheme.hapticMedium();

    final notifier = ref.read(otpProvider.notifier);
    final success = await notifier.verifyOTP(widget.phoneNumber, otp);

    if (mounted) {
      setState(() => _isVerifying = false);

      if (success) {
        ModernToast.success(context, 'OTP verified successfully!');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.push('/home');
        }
      } else {
        await ModernTheme.hapticHeavy();
        _shakeController.forward().then((_) {
          _shakeController.reverse();
        });
        ModernToast.error(context, 'Invalid OTP. Please try again.');
      }
    }
  }

  Future<void> _resendOTP() async {
    await ModernTheme.hapticMedium();
    final notifier = ref.read(otpProvider.notifier);
    await notifier.resendOTP(widget.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = ModernTheme.getTopPadding(context);
    final bottomPadding = ModernTheme.getBottomPadding(context);
    final otpState = ref.watch(otpProvider);
    final timerValue = ref.watch(otpTimerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: topPadding + ModernTheme.spacingL,
            bottom: bottomPadding + ModernTheme.spacingL,
            left: ModernTheme.spacingM,
            right: ModernTheme.spacingM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: ModernTheme.spacingXl),

              // Phone number display
              _buildPhoneDisplay(),
              const SizedBox(height: ModernTheme.spacingL),

              // OTP input fields
              _buildOTPInput(),
              const SizedBox(height: ModernTheme.spacingL),

              // Error message
              if (otpState.errorMessage != null) _buildErrorMessage(),
              const SizedBox(height: ModernTheme.spacingL),

              // Remaining attempts
              if (otpState.remainingAttempts != null)
                _buildRemainingAttempts(otpState.remainingAttempts!),
              const SizedBox(height: ModernTheme.spacingL),

              // Verify button
              _buildVerifyButton(),
              const SizedBox(height: ModernTheme.spacingL),

              // Resend OTP section
              _buildResendSection(timerValue, otpState),
              const SizedBox(height: ModernTheme.spacingL),

              // Help text
              _buildHelpText(),
            ],
          ),
        ),
      ),
    );
  }

  /// Header with back button
  Widget _buildHeader(BuildContext context) {
    return FadeInAnimation(
      child: Row(
        children: [
          ScaleButton(
            onPressed: () => context.pop(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.circular(ModernTheme.radiusL),
                border: Border.all(color: AppColors.mediumGrey),
                boxShadow: ModernTheme.shadowS,
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: ModernTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify Your Number',
                  style: AppTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter the 6-digit code sent to your phone',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Phone number display
  Widget _buildPhoneDisplay() {
    return SlideInAnimation(
      begin: const Offset(0, 0.2),
      child: Container(
        padding: const EdgeInsets.all(ModernTheme.spacingM),
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(ModernTheme.radiusL),
          border: Border.all(color: AppColors.mediumGrey),
          boxShadow: ModernTheme.shadowS,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ModernTheme.radiusM),
              ),
              child: const Icon(Icons.phone, color: AppColors.primary),
            ),
            const SizedBox(width: ModernTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verification Code Sent To',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.mediumGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.phoneNumber,
                    style: AppTheme.labelSmall,
                  ),
                ],
              ),
            ),
            ScaleButton(
              onPressed: () => context.pop(),
              child: Text(
                'Change',
                style: AppTheme.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// OTP input fields
  Widget _buildOTPInput() {
    return SlideInAnimation(
      begin: const Offset(0, 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter 6-Digit Code',
            style: AppTheme.labelLarge,
          ),
          const SizedBox(height: ModernTheme.spacingM),
          AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final shake = Tween<Offset>(
                begin: const Offset(-10, 0),
                end: const Offset(10, 0),
              ).evaluate(CurvedAnimation(
                parent: _shakeController,
                curve: Curves.elasticIn,
              ));

              return Transform.translate(
                offset: shake,
                child: child,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return _buildOTPField(index);
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Single OTP field
  Widget _buildOTPField(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(ModernTheme.radiusM),
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? AppColors.primary
              : AppColors.mediumGrey,
          width: _focusNodes[index].hasFocus ? 2 : 1,
        ),
        boxShadow: _focusNodes[index].hasFocus
            ? ModernTheme.shadowM
            : ModernTheme.shadowS,
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        enabled: !_isVerifying,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        style: AppTheme.headingM.copyWith(
          color: AppColors.surface,
        ),
        onChanged: (value) {
          if (value.isEmpty) {
            _handleBackspace(index, value);
          } else {
            _handleOTPInput(index, value);
          }
        },
      ),
    );
  }

  /// Error message display
  Widget _buildErrorMessage() {
    return FadeInAnimation(
      child: Container(
        padding: const EdgeInsets.all(ModernTheme.spacingM),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ModernTheme.radiusM),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: ModernTheme.spacingM),
            Expanded(
              child: Text(
                ref.watch(otpProvider).errorMessage ?? '',
                style: AppTheme.bodySmall.copyWith(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Remaining attempts display
  Widget _buildRemainingAttempts(int remaining) {
    return FadeInAnimation(
      child: Container(
        padding: const EdgeInsets.all(ModernTheme.spacingM),
        decoration: BoxDecoration(
          color: AppColors.highlight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ModernTheme.radiusM),
          border: Border.all(color: AppColors.highlight.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.highlight, size: 20),
            const SizedBox(width: ModernTheme.spacingM),
            Expanded(
              child: Text(
                'You have $remaining attempts remaining',
                style: AppTheme.bodySmall.copyWith(
                  color: AppColors.highlight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Verify button
  Widget _buildVerifyButton() {
    return SlideInAnimation(
      begin: const Offset(0, 0.2),
      child: ScaleButton(
        onPressed: _isVerifying ? null : _verifyOTP,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: ModernTheme.spacingM),
          decoration: BoxDecoration(
            gradient: ModernTheme.primaryGradient,
            borderRadius: BorderRadius.circular(ModernTheme.radiusL),
            boxShadow: ModernTheme.shadowL,
          ),
          child: _isVerifying
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.black.withOpacity(0.7),
                        ),
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: ModernTheme.spacingM),
                    const Text(
                      'Verifying...',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              : const Text(
                  'Verify OTP',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  /// Resend OTP section
  Widget _buildResendSection(AsyncValue<int> timerValue, OTPState otpState) {
    return FadeInAnimation(
      child: Column(
        children: [
          Text(
            'Didn\'t receive the code?',
            style: AppTheme.bodySmall.copyWith(
              color: AppColors.mediumGrey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ModernTheme.spacingM),
          timerValue.when(
            data: (remaining) {
              if (remaining > 0) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ModernTheme.spacingM,
                    vertical: ModernTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.highlight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ModernTheme.radiusM),
                  ),
                  child: Text(
                    'Resend in ${remaining}s',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppColors.highlight,
                    ),
                  ),
                );
              } else {
                return ScaleButton(
                  onPressed: _resendOTP,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ModernTheme.spacingM,
                      vertical: ModernTheme.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ModernTheme.radiusM),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Text(
                      'Resend Code',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              }
            },
            loading: () => const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            error: (error, _) => ScaleButton(
              onPressed: _resendOTP,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ModernTheme.spacingM,
                  vertical: ModernTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ModernTheme.radiusM),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Text(
                  'Resend Code',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Help text
  Widget _buildHelpText() {
    return FadeInAnimation(
      child: Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Need help? ',
                style: AppTheme.bodySmall.copyWith(
                  color: AppColors.mediumGrey,
                ),
              ),
              TextSpan(
                text: 'Contact Support',
                style: AppTheme.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Import for input formatter
import 'package:flutter/services.dart';
