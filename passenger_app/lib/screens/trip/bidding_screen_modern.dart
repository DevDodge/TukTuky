import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/theme.dart';
import '../../config/modern_theme.dart';
import '../../widgets/advanced_components.dart';
import '../../widgets/gesture_handlers.dart';
import '../../widgets/sos_button.dart';

/// Modern Bidding Screen with Real-Time Animations and Advanced UI/UX
class BiddingScreenModern extends ConsumerStatefulWidget {
  const BiddingScreenModern({Key? key}) : super(key: key);

  @override
  ConsumerState<BiddingScreenModern> createState() => _BiddingScreenModernState();
}

class _BiddingScreenModernState extends ConsumerState<BiddingScreenModern>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _countdownController;
  int _offerCount = 3;
  int _selectedOfferIndex = 0;
  int _countdownSeconds = 60;

  final List<Map<String, dynamic>> _driverOffers = [
    {
      'driverId': 1,
      'name': 'Ahmed Hassan',
      'rating': 4.8,
      'reviews': 245,
      'price': 45,
      'eta': 5,
      'distance': 2.3,
      'carType': 'TukTuk Standard',
      'carColor': 'White',
      'avatar': '👨',
    },
    {
      'driverId': 2,
      'name': 'Mohamed Ali',
      'rating': 4.9,
      'reviews': 312,
      'price': 42,
      'eta': 3,
      'distance': 1.8,
      'carType': 'TukTuk Plus',
      'carColor': 'Blue',
      'avatar': '👨',
    },
    {
      'driverId': 3,
      'name': 'Karim Ibrahim',
      'rating': 4.7,
      'reviews': 189,
      'price': 50,
      'eta': 8,
      'distance': 3.1,
      'carType': 'TukTuk Standard',
      'carColor': 'Yellow',
      'avatar': '👨',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _countdownController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..forward();

    _countdownController.addListener(() {
      setState(() {
        _countdownSeconds = (60 * (1 - _countdownController.value)).toInt();
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownController.dispose();
    super.dispose();
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
            // Main content
            SingleChildScrollView(
              padding: EdgeInsets.only(
                top: topPadding + ModernTheme.spacingM,
                bottom: bottomPadding + ModernTheme.spacingXl,
                left: ModernTheme.spacingM,
                right: ModernTheme.spacingM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context),
                  const SizedBox(height: ModernTheme.spacingL),

                  // Trip summary
                  _buildTripSummary(),
                  const SizedBox(height: ModernTheme.spacingL),

                  // Countdown timer
                  _buildCountdownTimer(),
                  const SizedBox(height: ModernTheme.spacingL),

                  // Offers count
                  _buildOffersCount(),
                  const SizedBox(height: ModernTheme.spacingM),

                  // Driver offers list
                  _buildDriverOffers(),
                  const SizedBox(height: ModernTheme.spacingL),

                  // Best offer badge
                  _buildBestOfferBadge(),
                ],
              ),
            ),

            // SOS Button
            Positioned(
              bottom: bottomPadding + ModernTheme.spacingM,
              right: ModernTheme.spacingM,
              child: const SOSButton(),
            ),

            // Cancel button
            Positioned(
              bottom: bottomPadding + ModernTheme.spacingM,
              left: ModernTheme.spacingM,
              child: ScaleButton(
                onPressed: () {
                  ModernDialog.show(
                    context,
                    title: 'Cancel Trip?',
                    message: 'Are you sure you want to cancel this trip request?',
                    confirmLabel: 'Cancel Trip',
                    cancelLabel: 'Keep Waiting',
                    isDestructive: true,
                    onConfirm: () {
                      context.pop();
                    },
                  );
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(ModernTheme.radiusL),
                    border: Border.all(color: Colors.red),
                    boxShadow: ModernTheme.shadowM,
                  ),
                  child: const Icon(Icons.close, color: Colors.red),
                ),
              ),
            ),
          ],
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
                  'Waiting for Offers',
                  style: AppTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Drivers are responding...',
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

  /// Trip summary card
  Widget _buildTripSummary() {
    return SlideInAnimation(
      begin: const Offset(0, 0.2),
      child: Container(
        padding: const EdgeInsets.all(ModernTheme.spacingM),
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(ModernTheme.radiusL),
          border: Border.all(color: AppColors.mediumGrey),
          boxShadow: ModernTheme.shadowM,
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
              child: const Icon(Icons.location_on, color: AppColors.primary),
            ),
            const SizedBox(width: ModernTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Downtown Cairo', style: AppTheme.labelSmall),
                  const SizedBox(height: 4),
                  Text(
                    '2.5 km away',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ModernTheme.spacingM,
                vertical: ModernTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ModernTheme.radiusM),
              ),
              child: Text(
                'Your Price: 50 EGP',
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

  /// Countdown timer with animation
  Widget _buildCountdownTimer() {
    return SlideInAnimation(
      begin: const Offset(0, 0.2),
      child: Container(
        padding: const EdgeInsets.all(ModernTheme.spacingM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.highlight.withOpacity(0.2),
              AppColors.highlight.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(ModernTheme.radiusL),
          border: Border.all(color: AppColors.highlight.withOpacity(0.3)),
          boxShadow: ModernTheme.shadowS,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offer expires in',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppColors.mediumGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_countdownSeconds seconds',
                  style: AppTheme.headingS.copyWith(
                    color: AppColors.highlight,
                  ),
                ),
              ],
            ),
            PulsingAnimation(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.highlight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(ModernTheme.radiusL),
                ),
                child: Icon(
                  Icons.schedule,
                  color: AppColors.highlight,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Offers count display
  Widget _buildOffersCount() {
    return FadeInAnimation(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available Offers', style: AppTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                '$_offerCount drivers responding',
                style: AppTheme.bodySmall.copyWith(
                  color: AppColors.mediumGrey,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ModernTheme.spacingM,
              vertical: ModernTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ModernTheme.radiusM),
            ),
            child: Text(
              '$_offerCount',
              style: AppTheme.headingS.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Driver offers list with animations
  Widget _buildDriverOffers() {
    return Column(
      children: _driverOffers.asMap().entries.map((entry) {
        final index = entry.key;
        final offer = entry.value;
        final isSelected = _selectedOfferIndex == index;
        final isBestPrice = offer['price'] == _driverOffers.reduce((a, b) => a['price'] < b['price'] ? a : b)['price'];

        return Padding(
          padding: const EdgeInsets.only(bottom: ModernTheme.spacingM),
          child: SlideInAnimation(
            begin: Offset(0, 0.2 + (index * 0.1)),
            child: ScaleButton(
              onPressed: () async {
                await ModernTheme.hapticMedium();
                setState(() => _selectedOfferIndex = index);
              },
              child: Container(
                padding: const EdgeInsets.all(ModernTheme.spacingM),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.darkGrey,
                  borderRadius: BorderRadius.circular(ModernTheme.radiusL),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.mediumGrey,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? ModernTheme.shadowM : ModernTheme.shadowS,
                ),
                child: Column(
                  children: [
                    // Driver info
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: ModernTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(ModernTheme.radiusL),
                            boxShadow: ModernTheme.shadowS,
                          ),
                          child: Center(
                            child: Text(offer['avatar'], style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: ModernTheme.spacingM),
                        // Driver details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(offer['name'], style: AppTheme.labelSmall),
                                  if (isBestPrice)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: ModernTheme.spacingS,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.acceptGreen.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(ModernTheme.radiusS),
                                      ),
                                      child: Text(
                                        'Best Price',
                                        style: AppTheme.bodySmall.copyWith(
                                          color: AppColors.acceptGreen,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star, color: AppColors.primary, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${offer['rating']} (${offer['reviews']})',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppColors.mediumGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ModernTheme.spacingM),
                    // Trip details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailItem('ETA', '${offer['eta']} min'),
                        _buildDetailItem('Distance', '${offer['distance']} km'),
                        _buildDetailItem('Car', offer['carType']),
                      ],
                    ),
                    const SizedBox(height: ModernTheme.spacingM),
                    // Price and accept button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Offered Price',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppColors.mediumGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${offer['price']} EGP',
                              style: AppTheme.headingS.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        ScaleButton(
                          onPressed: () async {
                            await ModernTheme.hapticMedium();
                            ModernToast.success(context, 'Trip accepted with ${offer['name']}');
                            await Future.delayed(const Duration(seconds: 1));
                            if (mounted) {
                              context.push('/driver-arriving');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ModernTheme.spacingL,
                              vertical: ModernTheme.spacingM,
                            ),
                            decoration: BoxDecoration(
                              gradient: ModernTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(ModernTheme.radiusM),
                              boxShadow: ModernTheme.shadowM,
                            ),
                            child: const Text(
                              'Accept',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Detail item widget
  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppColors.mediumGrey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.labelSmall,
        ),
      ],
    );
  }

  /// Best offer badge
  Widget _buildBestOfferBadge() {
    final bestOffer = _driverOffers.reduce((a, b) => a['price'] < b['price'] ? a : b);

    return FadeInAnimation(
      child: Container(
        padding: const EdgeInsets.all(ModernTheme.spacingM),
        decoration: BoxDecoration(
          gradient: ModernTheme.successGradient,
          borderRadius: BorderRadius.circular(ModernTheme.radiusL),
          boxShadow: ModernTheme.shadowL,
        ),
        child: Row(
          children: [
            const Icon(Icons.thumb_up, color: Colors.white),
            const SizedBox(width: ModernTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Best Offer Found',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${bestOffer['name']} - ${bestOffer['price']} EGP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
