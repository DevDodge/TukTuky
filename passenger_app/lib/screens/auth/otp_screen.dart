import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/theme.dart';
import '../../widgets/golden_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;

  const OtpScreen({
    Key? key,
    required this.phone,
  }) : super(key: key);

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  int _secondsRemaining = 60;
  late AnimationController _timerController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();

    _timerController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
    _startTimer();
  }

  void _startTimer() {
    _timerController.forward();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _secondsRemaining--;
          if (_secondsRemaining > 0) {
            _startTimer();
          }
        });
      }
    });
  }

  void _handleOtpInput(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _verifyOtp() {
    final otpCode = _getOtpCode();
    if (otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete OTP')),
      );
      return;
    }

    // TODO: Verify OTP with backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Verifying OTP: $otpCode')),
    );

    // Navigate to home on success
    Future.delayed(const Duration(milliseconds: 500), () {
      context.go('/home');
    });
  }

  void _resendOtp() {
    if (_secondsRemaining <= 0) {
      setState(() {
        _secondsRemaining = 60;
      });
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully')),
      );
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _timerController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Verify Your Phone',
                  style: AppTheme.headingM,
                ),
                const SizedBox(height: 8),
                // Subtitle
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'We sent a code to ',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                      ),
                      TextSpan(
                        text: widget.phone,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 50,
                      height: 60,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        onChanged: (value) => _handleOtpInput(value, index),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.mediumGrey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.mediumGrey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.darkGrey,
                        ),
                        style: AppTheme.headingS.copyWith(
                          color: AppColors.primary,
                        ),
                        cursorColor: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Resend Section
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Didn\'t receive code?',
                        style: AppTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _secondsRemaining <= 0 ? _resendOtp : null,
                        child: Text(
                          _secondsRemaining > 0
                              ? 'Resend in ${_secondsRemaining}s'
                              : 'Resend Code',
                          style: AppTheme.labelLarge.copyWith(
                            color: _secondsRemaining > 0
                                ? AppColors.mediumGrey
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // Verify Button
                SizedBox(
                  width: double.infinity,
                  child: GoldenButton(
                    label: 'Verify',
                    onPressed: _verifyOtp,
                  ),
                ),
                const SizedBox(height: 16),
                // Change Number Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.mediumGrey,
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Change Number',
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
