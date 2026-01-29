import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/theme.dart';
import '../../widgets/golden_button.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  String _selectedLanguage = 'ar';
  final _phoneController = TextEditingController();

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
  }

  @override
  void dispose() {
    _slideController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() {
    // TODO: Implement Google Sign In
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Sign In - Coming Soon')),
    );
  }

  void _handleAppleSignIn() {
    // TODO: Implement Apple Sign In
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple Sign In - Coming Soon')),
    );
  }

  void _handlePhoneSignIn() {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }
    context.push('/otp', extra: _phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Language Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48),
                    Text(
                      'TukTuky',
                      style: AppTheme.headingL.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLanguage =
                              _selectedLanguage == 'ar' ? 'en' : 'ar';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkGrey,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Text(
                          _selectedLanguage.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                // Welcome Text
                Text(
                  _selectedLanguage == 'ar'
                      ? 'أهلا وسهلا'
                      : 'Welcome Back',
                  style: AppTheme.headingM,
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedLanguage == 'ar'
                      ? 'اختر طريقة الدخول المفضلة لديك'
                      : 'Choose your preferred sign-in method',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.mediumGrey,
                  ),
                ),
                const SizedBox(height: 48),
                // Social Login Buttons
                SocialLoginButton(
                  label: _selectedLanguage == 'ar' ? 'جوجل' : 'Google',
                  icon: Icons.g_mobiledata,
                  onPressed: _handleGoogleSignIn,
                  backgroundColor: AppColors.surface,
                  borderColor: AppColors.mediumGrey,
                ),
                const SizedBox(height: 12),
                SocialLoginButton(
                  label: _selectedLanguage == 'ar' ? 'أبل' : 'Apple',
                  icon: Icons.apple,
                  onPressed: _handleAppleSignIn,
                  backgroundColor: AppColors.surface,
                  borderColor: AppColors.mediumGrey,
                ),
                const SizedBox(height: 12),
                SocialLoginButton(
                  label: _selectedLanguage == 'ar' ? 'فيسبوك' : 'Facebook',
                  icon: Icons.facebook,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Facebook Sign In - Coming Soon'),
                      ),
                    );
                  },
                  backgroundColor: AppColors.surface,
                  borderColor: AppColors.mediumGrey,
                ),
                const SizedBox(height: 32),
                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _selectedLanguage == 'ar' ? 'أو' : 'OR',
                        style: AppTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Phone Number Input
                Text(
                  _selectedLanguage == 'ar'
                      ? 'رقم الهاتف'
                      : 'Phone Number',
                  style: AppTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.mediumGrey),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            const Text(
                              '🇪🇬',
                              style: TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+20',
                              style: AppTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: _selectedLanguage == 'ar'
                                ? 'أدخل رقمك'
                                : 'Enter your number',
                            hintStyle:
                                const TextStyle(color: AppColors.mediumGrey),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                          style: AppTheme.bodyMedium,
                          cursorColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: GoldenButton(
                    label: _selectedLanguage == 'ar' ? 'متابعة' : 'Continue',
                    onPressed: _handlePhoneSignIn,
                  ),
                ),
                const SizedBox(height: 24),
                // Terms Text
                Center(
                  child: Text(
                    _selectedLanguage == 'ar'
                        ? 'بالمتابعة، أنت توافق على شروطنا'
                        : 'By continuing, you agree to our terms',
                    style: AppTheme.bodySmall,
                    textAlign: TextAlign.center,
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
