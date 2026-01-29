import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/colors.dart';
import '../../config/theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/sos_button.dart';

class TripInProgressScreen extends ConsumerStatefulWidget {
  const TripInProgressScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TripInProgressScreen> createState() =>
      _TripInProgressScreenState();
}

class _TripInProgressScreenState extends ConsumerState<TripInProgressScreen> {
  late GoogleMapController _mapController;
  bool _showDetails = true;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(30.0444, 31.2357),
              zoom: 15,
            ),
            myLocationEnabled: true,
            compassEnabled: true,
            zoomControlsEnabled: false,
          ),
          if (_showDetails)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 12,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Trip in Progress', style: AppTheme.labelLarge),
                        GestureDetector(
                          onTap: () => setState(() => _showDetails = false),
                          child: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Time Remaining'),
                              Text('8 min', style: AppTheme.labelSmall),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Distance'),
                              Text('3.2 km', style: AppTheme.labelSmall),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Current Fare'),
                              Text('EGP 42', style: AppTheme.labelSmall.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.phone, size: 18),
                                SizedBox(width: 8),
                                Text('Call'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.message, size: 18),
                                SizedBox(width: 8),
                                Text('Message'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 24,
            right: 24,
            child: SOSButton(onPressed: () {}),
          ),
        ],
      ),
    );
  }
}
