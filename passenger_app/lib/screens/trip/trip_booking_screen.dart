import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/theme.dart';
import '../../widgets/golden_button.dart';
import '../../widgets/location_input.dart';
import '../../widgets/payment_method_selector.dart';
import '../../providers/trip_provider.dart';
import '../../providers/wallet_provider.dart';

class TripBookingScreen extends ConsumerStatefulWidget {
  final double? pickupLat;
  final double? pickupLng;
  final String? pickupAddress;
  final double? dropoffLat;
  final double? dropoffLng;
  final String? dropoffAddress;

  const TripBookingScreen({
    Key? key,
    this.pickupLat,
    this.pickupLng,
    this.pickupAddress,
    this.dropoffLat,
    this.dropoffLng,
    this.dropoffAddress,
  }) : super(key: key);

  @override
  ConsumerState<TripBookingScreen> createState() => _TripBookingScreenState();
}

class _TripBookingScreenState extends ConsumerState<TripBookingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late TextEditingController _pickupController;
  late TextEditingController _dropoffController;
  late TextEditingController _fareController;
  String _selectedPayment = 'wallet';
  String? _appliedPromo;
  double _estimatedFare = 45.0;
  double _discount = 0.0;

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

    _pickupController = TextEditingController(text: widget.pickupAddress);
    _dropoffController = TextEditingController(text: widget.dropoffAddress);
    _fareController = TextEditingController(text: _estimatedFare.toString());
  }

  void _applyPromoCode(String code) {
    setState(() {
      _appliedPromo = code;
      _discount = 10.0;
    });
  }

  void _removePromoCode() {
    setState(() {
      _appliedPromo = null;
      _discount = 0.0;
    });
  }

  void _requestTrip() {
    final fare = double.tryParse(_fareController.text) ?? _estimatedFare;
    
    ref.read(tripProvider.notifier).createTrip(
      pickupLat: widget.pickupLat ?? 30.0444,
      pickupLng: widget.pickupLng ?? 31.2357,
      pickupAddress: _pickupController.text,
      dropoffLat: widget.dropoffLat ?? 30.0444,
      dropoffLng: widget.dropoffLng ?? 31.2357,
      dropoffAddress: _dropoffController.text,
      offeredFare: fare,
      paymentMethod: _selectedPayment,
    );

    context.go('/bidding');
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pickupController.dispose();
    _dropoffController.dispose();
    _fareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletBalance = ref.watch(walletBalanceProvider);
    final totalFare = _estimatedFare - _discount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Confirm Trip', style: AppTheme.headingS),
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pickup', style: AppTheme.labelSmall),
                              Text(_pickupController.text, style: AppTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1, color: AppColors.mediumGrey, margin: const EdgeInsets.symmetric(horizontal: 20)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.highlight.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.location_on, color: AppColors.highlight),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dropoff', style: AppTheme.labelSmall),
                              Text(_dropoffController.text, style: AppTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Your Offer', style: AppTheme.labelLarge),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.darkGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mediumGrey),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Base Fare', style: AppTheme.bodyMedium),
                        Text('EGP ${_estimatedFare.toStringAsFixed(0)}', style: AppTheme.bodyMedium),
                      ],
                    ),
                    if (_discount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Discount', style: AppTheme.bodySmall.copyWith(color: AppColors.highlight)),
                          Text('- EGP ${_discount.toStringAsFixed(0)}', style: AppTheme.bodySmall.copyWith(color: AppColors.highlight)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Container(height: 1, color: AppColors.mediumGrey),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: AppTheme.headingS),
                        Text('EGP ${totalFare.toStringAsFixed(0)}', style: AppTheme.headingS.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PromoCodeInput(
                appliedCode: _appliedPromo,
                onApply: _applyPromoCode,
                onRemove: _removePromoCode,
              ),
              const SizedBox(height: 24),
              PaymentMethodSelector(
                selectedMethod: _selectedPayment,
                onMethodChanged: (method) => setState(() => _selectedPayment = method),
                methods: [
                  PaymentMethodOption(
                    id: 'wallet',
                    name: 'Wallet',
                    icon: Icons.account_balance_wallet,
                    description: 'Balance: EGP ${walletBalance.toStringAsFixed(0)}',
                  ),
                  PaymentMethodOption(
                    id: 'card',
                    name: 'Credit Card',
                    icon: Icons.credit_card,
                    description: 'Visa ending in 4242',
                  ),
                  PaymentMethodOption(
                    id: 'cash',
                    name: 'Cash',
                    icon: Icons.money,
                    description: 'Pay driver directly',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: GoldenButton(
                  label: 'Request Trip',
                  onPressed: _requestTrip,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
