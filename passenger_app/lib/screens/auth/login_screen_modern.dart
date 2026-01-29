import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/theme.dart';
import '../../config/modern_theme.dart';
import '../../widgets/advanced_components.dart';
import '../../widgets/gesture_handlers.dart';

/// Modern Login Screen with Advanced UI/UX, Notch Support, and Animations
class LoginScreenModern extends ConsumerStatefulWidget {
  const LoginScreenModern({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreenModern> createState() => _LoginScreenModernState();
}

class _LoginScreenModernState extends ConsumerState<LoginScreenModern> {
  late TextEditingController _phoneController;
  bool _isLoading = false;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handlePhoneLogin() async {
    if (_phoneController.text.isEmpty) {
      ModernToast.error(context, 'Please enter your phone number');
      return;
    }

    setState(() => _isLoading = true);
    await ModernTheme.hapticMedium();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      context.push('/otp');
    }
  }

  void _handleSocialLogin(String provider) async {
    await ModernTheme.hapticMedium();
    ModernToast.info(context, 'Logging in with $provider...');

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      context.push('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = ModernTheme.getTopPadding(context);
    final bottomPadding = ModernTheme.getBottomPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.background,
                    AppColors.background.withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // Main content
            SingleChildScrollView(
              padding: EdgeInsets.only(
                top: topPadding + ModernTheme.spacingL,
                bottom: bottomPadding + ModernTheme.spacingL,
                left: ModernTheme.spacingM,
                right: ModernTheme.spacingM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Language toggle
                  _buildLanguageToggle(),
                  const SizedBox(height: ModernTheme.spacingXl),

                  // Logo with animation
                  _buildLogo(),
                  const SizedBox(height: ModernTheme.spacingXl),

                  // Welcome text
                  _buildWelcomeText(),
                  const SizedBox(height: ModernTheme.spacingXl),

                  // Phone input
                  _buildPhoneInput(),
                  const SizedBox(height: ModernTheme.spacingL),

                  // Login button
                  _buildLoginButton(),
                  const SizedBox(height: ModernTheme.spacingL),

                  // Divider
                  _buildDivider(),
                  const SizedBox(height: ModernTheme.spacingL),

                  // Social login buttons
                  _buildSocialLogin(),
                  const SizedBox(height: ModernTheme.spacingL),

                  // Terms and conditions
                  _buildTermsText(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Language toggle button
  Widget _buildLanguageToggle() {
    return FadeInAnimation(
      child: Align(
        alignment: Alignment.topRight,
        child: ScaleButton(
          onPressed: () async {
            await ModernTheme.hapticLight();
            setState(() {
              _selectedLanguage = _selectedLanguage == 'en' ? 'ar' : 'en';
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ModernTheme.spacingM,
              vertical: ModernTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.darkGrey,
              borderRadius: BorderRadius.circular(ModernTheme.radiusM),
              border: Border.all(color: AppColors.mediumGrey),
              boxShadow: ModernTheme.shadowS,
            ),
            child: Text(
              _selectedLanguage.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Logo with bounce animation
  Widget _buildLogo() {
    return BounceAnimation(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: ModernTheme.primaryGradient,
          borderRadius: BorderRadius.circular(ModernTheme.radiusL),
          boxShadow: ModernTheme.shadowXl,
        ),
        child: const Icon(
          Icons.local_taxi,
          color: Colors.black,
          size: 40,
        ),
      ),
    );
  }

  /// Welcome text with slide animation
  Widget _buildWelcomeText() {
    return SlideInAnimation(
      begin: const Offset(0, 0.3),
      child: Column(
        children: [
          Text(
            'Welcome to TukTuky',
            style: AppTheme.headingL.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ModernTheme.spacingM),
          Text(
            'Your ride, your way. Book now and save more!',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.mediumGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Phone input field with focus animation
  Widget _buildPhoneInput() {
    return SlideInAnimation(
      begin: const Offset(0, 0.3),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(ModernTheme.radiusL),
          border: Border.all(color: AppColors.mediumGrey),
          boxShadow: ModernTheme.shadowM,
        ),
        child: TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: '+20 100 123 4567',
            hintStyle: const TextStyle(color: AppColors.mediumGrey),
            prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
            suffixIcon: _phoneController.text.isNotEmpty
                ? ScaleButton(
                    onPressed: () {
                      _phoneController.clear();
                      setState(() {});
                    },
                    child: const Icon(Icons.close, color: AppColors.mediumGrey),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: ModernTheme.spacingM,
              vertical: ModernTheme.spacingM,
            ),
          ),
          style: const TextStyle(color: AppColors.surface),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
    );
  }

  /// Login button with loading state
  Widget _buildLoginButton() {
    return SlideInAnimation(
      begin: const Offset(0, 0.3),
      child: ScaleButton(
        onPressed: _isLoading ? null : _handlePhoneLogin,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: ModernTheme.spacingM),
          decoration: BoxDecoration(
            gradient: ModernTheme.primaryGradient,
            borderRadius: BorderRadius.circular(ModernTheme.radiusL),
            boxShadow: ModernTheme.shadowL,
          ),
          child: _isLoading
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
                      'Sending OTP...',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              : const Text(
                  'Send OTP',
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

  /// Divider with text
  Widget _buildDivider() {
    return FadeInAnimation(
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.mediumGrey.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ModernTheme.spacingM),
            child: Text(
              'or',
              style: AppTheme.bodySmall.copyWith(
                color: AppColors.mediumGrey,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.mediumGrey.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  /// Social login buttons
  Widget _buildSocialLogin() {
    final socialProviders = [
      {'icon': Icons.g_mobiledata, 'label': 'Google'},
      {'icon': Icons.apple, 'label': 'Apple'},
      {'icon': Icons.facebook, 'label': 'Facebook'},
    ];

    return SlideInAnimation(
      begin: const Offset(0, 0.3),
      child: Column(
        children: [
          Text(
            'Continue with',
            style: AppTheme.bodySmall.copyWith(
              color: AppColors.mediumGrey,
            ),
          ),
          const SizedBox(height: ModernTheme.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: socialProviders.map((provider) {
              return ScaleButton(
                onPressed: () => _handleSocialLogin(provider['label'] as String),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.darkGrey,
                    borderRadius: BorderRadius.circular(ModernTheme.radiusL),
                    border: Border.all(color: AppColors.mediumGrey),
                    boxShadow: ModernTheme.shadowS,
                  ),
                  child: Icon(
                    provider['icon'] as IconData,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Terms and conditions text
  Widget _buildTermsText() {
    return FadeInAnimation(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'By continuing, you agree to our ',
              style: AppTheme.bodySmall.copyWith(
                color: AppColors.mediumGrey,
              ),
            ),
            TextSpan(
              text: 'Terms',
              style: AppTheme.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: ' and ',
              style: AppTheme.bodySmall.copyWith(
                color: AppColors.mediumGrey,
              ),
            ),
            TextSpan(
              text: 'Privacy Policy',
              style: AppTheme.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
