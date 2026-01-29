import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/theme.dart';
import '../../widgets/driver_offer_card.dart';
import '../../widgets/sos_button.dart';
import '../../providers/trip_provider.dart';

class BiddingScreen extends ConsumerStatefulWidget {
  const BiddingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BiddingScreen> createState() => _BiddingScreenState();
}

class _BiddingScreenState extends ConsumerState<BiddingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripProvider);
    final offers = ref.watch(tripOffersProvider);
    final viewsCount = ref.watch(tripViewsCountProvider);
    final offersCount = ref.watch(tripOffersCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Waiting for Offers', style: AppTheme.headingS),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                '${offers.length} offers',
                style: AppTheme.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  OfferCounter(
                    viewsCount: viewsCount,
                    offersCount: offersCount,
                  ),
                  const SizedBox(height: 24),
                  if (offers.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Column(
                          children: [
                            Icon(
                              Icons.hourglass_empty,
                              size: 64,
                              color: AppColors.mediumGrey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Waiting for drivers...',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppColors.mediumGrey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Drivers are reviewing your offer',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppColors.mediumGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: offers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final offer = offers[index];
                        return DriverOfferCard(
                          driverName: offer.driverName,
                          driverImage: offer.driverImage,
                          driverRating: offer.driverRating,
                          reviewCount: offer.reviewCount,
                          offeredFare: offer.offeredFare,
                          yourFare: offer.yourFare,
                          eta: offer.eta,
                          distance: offer.distance,
                          message: offer.message,
                          isHighlighted: index == 0,
                          onAccept: () {
                            ref.read(tripProvider.notifier).acceptOffer(offer.id);
                            context.go('/driver-arriving');
                          },
                          onDecline: () {
                            ref.read(tripProvider.notifier).rejectOffer(offer.id);
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: SOSButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.darkGrey,
                      title: const Text('Emergency Alert'),
                      content: const Text(
                        'Emergency services have been notified. Your location has been shared.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.darkGrey,
                      title: const Text('Cancel Trip?'),
                      content: const Text(
                        'Are you sure you want to cancel this trip?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.go('/home');
                          },
                          child: const Text('Yes, Cancel'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.darkGrey,
                    border: Border.all(color: AppColors.mediumGrey, width: 2),
                    boxShadow: AppColors.elevatedShadow,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.mediumGrey,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
