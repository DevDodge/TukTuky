import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/theme.dart';
import '../../widgets/golden_button.dart';
import '../../widgets/rating_stars.dart';

class TripCompletedScreen extends ConsumerStatefulWidget {
  const TripCompletedScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TripCompletedScreen> createState() =>
      _TripCompletedScreenState();
}

class _TripCompletedScreenState extends ConsumerState<TripCompletedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _celebrateController;
  late Animation<double> _scaleAnimation;
  double _userRating = 0;
  String _userReview = '';
  double _tipAmount = 0;

  @override
  void initState() {
    super.initState();
    _celebrateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _celebrateController, curve: Curves.elasticOut),
    );
    _celebrateController.forward();
  }

  @override
  void dispose() {
    _celebrateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.acceptGreen.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.acceptGreen,
                  size: 80,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Trip Completed!', style: AppTheme.headingM),
            const SizedBox(height: 8),
            Text(
              'Thank you for choosing TukTuky',
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.mediumGrey,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mediumGrey),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: const NetworkImage(
                          'https://via.placeholder.com/64',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ahmed Hassan', style: AppTheme.labelLarge),
                            RatingDisplay(
                              rating: 4.8,
                              reviewCount: 342,
                              starSize: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: AppColors.mediumGrey,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Trip Fare'),
                      Text('EGP 45', style: AppTheme.labelLarge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Discount'),
                      Text('- EGP 10', style: AppTheme.labelSmall.copyWith(color: AppColors.highlight)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Paid'),
                      Text('EGP 35', style: AppTheme.headingS.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mediumGrey),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rate Your Trip', style: AppTheme.labelLarge),
                  const SizedBox(height: 16),
                  Center(
                    child: RatingStars(
                      initialRating: _userRating,
                      onRatingChanged: (rating) {
                        setState(() => _userRating = rating);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    maxLines: 2,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: 'Share your experience',
                      hintStyle: const TextStyle(color: AppColors.mediumGrey),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.mediumGrey),
                      ),
                    ),
                    style: const TextStyle(color: AppColors.surface),
                    onChanged: (value) => _userReview = value,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mediumGrey),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Tip (Optional)', style: AppTheme.labelLarge),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTipButton(5),
                      _buildTipButton(10),
                      _buildTipButton(20),
                      _buildTipButton(50),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: GoldenButton(
                label: 'Done',
                onPressed: () => context.go('/home'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTipButton(double amount) {
    final isSelected = _tipAmount == amount;
    return GestureDetector(
      onTap: () => setState(() => _tipAmount = amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.mediumGrey,
          ),
        ),
        child: Text(
          'EGP $amount',
          style: TextStyle(
            color: isSelected ? AppColors.background : AppColors.surface,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
