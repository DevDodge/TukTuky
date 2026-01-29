import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/theme.dart';
import '../../providers/location_provider.dart';
import '../../services/places_service.dart';
import '../../widgets/location_input.dart';

class SearchLocationScreen extends ConsumerStatefulWidget {
  final String locationType;

  const SearchLocationScreen({
    Key? key,
    required this.locationType,
  }) : super(key: key);

  @override
  ConsumerState<SearchLocationScreen> createState() =>
      _SearchLocationScreenState();
}

class _SearchLocationScreenState extends ConsumerState<SearchLocationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final _searchController = TextEditingController();
  final PlacesService _placesService = PlacesService();
  
  List<PlacePrediction> _predictions = [];
  bool _isSearching = false;
  String? _errorMessage;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  /// Handle search with debouncing to avoid too many API calls
  void _handleSearch(String query) {
    // Cancel previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _predictions = [];
        _isSearching = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() => _isSearching = true);

    // Debounce for 500ms before making API call
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final predictions = await _placesService.searchPlaces(query);
        
        if (mounted) {
          setState(() {
            _predictions = predictions;
            _isSearching = false;
            _errorMessage = predictions.isEmpty ? 'No results found' : null;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _predictions = [];
            _isSearching = false;
            _errorMessage = 'Failed to search locations';
          });
        }
      }
    });
  }

  /// Select a prediction and get its coordinates
  Future<void> _selectPrediction(PlacePrediction prediction) async {
    setState(() => _isSearching = true);
    
    print('Selected prediction: ${prediction.placeId} - ${prediction.mainText}');
    
    try {
      final details = await _placesService.getPlaceDetails(prediction.placeId);
      
      print('Got details: $details');
      
      if (details != null && mounted) {
        context.pop({
          'address': prediction.mainText,
          'fullAddress': details.formattedAddress,
          'latitude': details.latitude,
          'longitude': details.longitude,
        });
      } else {
        // Fallback - use prediction data without coordinates
        if (mounted) {
          setState(() {
            _isSearching = false;
            _errorMessage = 'Could not get location details';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _errorMessage = 'Failed to get location details';
        });
      }
    }
  }

  /// Select a saved location (already has coordinates)
  void _selectSavedLocation(Map<String, dynamic> location) {
    context.pop({
      'address': location['title'],
      'latitude': location['lat'],
      'longitude': location['lng'],
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedLocations = ref.watch(savedLocationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.locationType == 'pickup' ? 'Pickup Location' : 'Dropoff Location',
          style: AppTheme.headingS,
        ),
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _handleSearch,
                autofocus: true,
                textDirection: TextDirection.rtl, // Support Arabic input
                decoration: InputDecoration(
                  hintText: 'ابحث عن موقع...', // "Search for location..." in Arabic
                  hintStyle: const TextStyle(color: AppColors.mediumGrey),
                  prefixIcon: const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _handleSearch('');
                          },
                          child: const Icon(
                            Icons.close,
                            color: AppColors.mediumGrey,
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.darkGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.mediumGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.mediumGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                style: AppTheme.bodyMedium,
                cursorColor: AppColors.primary,
              ),
            ),
            
            // Results List
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : ListView(
                      children: [
                        // Error Message
                        if (_errorMessage != null && _searchController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: AppColors.mediumGrey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _errorMessage!,
                                    style: TextStyle(color: AppColors.mediumGrey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        
                        // Google Places Search Results
                        if (_predictions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Results',
                                      style: AppTheme.labelLarge,
                                    ),
                                    const Spacer(),
                                    // Powered by Google badge
                                    Row(
                                      children: [
                                        Text(
                                          'Powered by ',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.mediumGrey,
                                          ),
                                        ),
                                        Image.asset(
                                          'assets/images/google_logo.png',
                                          height: 12,
                                          errorBuilder: (_, __, ___) => Text(
                                            'Google',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.mediumGrey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ..._predictions.map((prediction) {
                                  return LocationSearchResult(
                                    title: prediction.mainText,
                                    subtitle: prediction.secondaryText,
                                    icon: Icons.location_on,
                                    onTap: () => _selectPrediction(prediction),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        
                        // Saved Locations Section (when no search)
                        if (savedLocations.isNotEmpty && 
                            _predictions.isEmpty && 
                            _searchController.text.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Saved Locations',
                                  style: AppTheme.labelLarge,
                                ),
                                const SizedBox(height: 12),
                                ...savedLocations.map((location) {
                                  return LocationSearchResult(
                                    title: location.name,
                                    subtitle: location.address ?? '',
                                    icon: location.locationType == 'home'
                                        ? Icons.home
                                        : location.locationType == 'work'
                                            ? Icons.work
                                            : Icons.location_on,
                                    onTap: () => _selectSavedLocation({
                                      'title': location.name,
                                      'lat': location.latitude,
                                      'lng': location.longitude,
                                    }),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        
                        // Use Current Location Button
                        if (_predictions.isEmpty && _searchController.text.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GestureDetector(
                              onTap: () {
                                final position = ref.read(currentPositionProvider);
                                if (position != null) {
                                  context.pop({
                                    'address': 'Current Location',
                                    'latitude': position.latitude,
                                    'longitude': position.longitude,
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.darkGrey,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.my_location,
                                        color: AppColors.primary,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Use Current Location',
                                            style: AppTheme.bodyMedium.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            'استخدم موقعك الحالي',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.mediumGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColors.mediumGrey,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
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
