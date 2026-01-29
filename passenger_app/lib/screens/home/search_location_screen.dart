import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/theme.dart';
import '../../providers/location_provider.dart';
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
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

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

  void _handleSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // Simulate API call to Google Places
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _searchResults = [
          {
            'title': 'Downtown Cairo',
            'subtitle': 'Cairo, Egypt',
            'lat': 30.0444,
            'lng': 31.2357,
          },
          {
            'title': 'Giza Plateau',
            'subtitle': 'Giza, Egypt',
            'lat': 30.0088,
            'lng': 31.2087,
          },
          {
            'title': 'Helwan',
            'subtitle': 'Helwan, Egypt',
            'lat': 29.8626,
            'lng': 31.3341,
          },
          {
            'title': 'New Cairo',
            'subtitle': 'New Cairo, Egypt',
            'lat': 29.9774,
            'lng': 31.4867,
          },
        ].where((result) {
          return result['title']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              result['subtitle']
                  .toLowerCase()
                  .contains(query.toLowerCase());
        }).toList();
        _isSearching = false;
      });
    });
  }

  void _selectLocation(Map<String, dynamic> location) {
    context.pop({
      'address': location['title'],
      'latitude': location['lat'],
      'longitude': location['lng'],
    });
  }

  @override
  void dispose() {
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
                decoration: InputDecoration(
                  hintText: 'Search location...',
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
                        // Saved Locations Section
                        if (savedLocations.isNotEmpty && _searchResults.isEmpty)
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
                                    subtitle: location.address,
                                    icon: location.locationType == 'home'
                                        ? Icons.home
                                        : location.locationType == 'work'
                                            ? Icons.work
                                            : Icons.location_on,
                                    onTap: () => _selectLocation({
                                      'title': location.name,
                                      'lat': location.latitude,
                                      'lng': location.longitude,
                                    }),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        // Search Results Section
                        if (_searchResults.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Results',
                                  style: AppTheme.labelLarge,
                                ),
                                const SizedBox(height: 12),
                                ...(_searchResults).map((result) {
                                  return LocationSearchResult(
                                    title: result['title'],
                                    subtitle: result['subtitle'],
                                    icon: Icons.location_on,
                                    onTap: () => _selectLocation(result),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        // Recent Searches
                        if (_searchResults.isEmpty &&
                            _searchController.text.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recent Searches',
                                  style: AppTheme.labelLarge,
                                ),
                                const SizedBox(height: 12),
                                LocationSearchResult(
                                  title: 'Tahrir Square',
                                  subtitle: 'Cairo, Egypt',
                                  icon: Icons.history,
                                  onTap: () => _selectLocation({
                                    'title': 'Tahrir Square',
                                    'lat': 30.0329,
                                    'lng': 31.2361,
                                  }),
                                ),
                                const SizedBox(height: 8),
                                LocationSearchResult(
                                  title: 'Egyptian Museum',
                                  subtitle: 'Cairo, Egypt',
                                  icon: Icons.history,
                                  onTap: () => _selectLocation({
                                    'title': 'Egyptian Museum',
                                    'lat': 30.0348,
                                    'lng': 31.2384,
                                  }),
                                ),
                              ],
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
