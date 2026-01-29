import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../config/colors.dart';
import '../../config/theme.dart';
import '../../widgets/golden_button.dart';
import '../../providers/location_provider.dart';
import '../../models/models.dart';

class SavedLocationsScreen extends ConsumerStatefulWidget {
  final int initialTab;
  
  const SavedLocationsScreen({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  ConsumerState<SavedLocationsScreen> createState() =>
      _SavedLocationsScreenState();
}

class _SavedLocationsScreenState
    extends ConsumerState<SavedLocationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load saved locations when screen opens
    Future.microtask(() {
      ref.read(locationProvider.notifier);
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _addLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditLocationScreen(),
      ),
    );

    if (result != null) {
      try {
        await ref.read(locationProvider.notifier).addSavedLocation(
              result['name'] as String,
              result['address'] as String,
              result['latitude'] as double,
              result['longitude'] as double,
              result['type'] as String,
            );
        _showMessage('Location saved successfully!');
      } catch (e) {
        _showMessage('Failed to save location: $e', isError: true);
      }
    }
  }

  Future<void> _editLocation(SavedLocation location) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditLocationScreen(location: location),
      ),
    );

    if (result != null) {
      try {
        await ref.read(locationProvider.notifier).updateSavedLocation(
              location.id,
              result['name'] as String,
              result['address'] as String,
              result['latitude'] as double,
              result['longitude'] as double,
              result['type'] as String,
            );
        _showMessage('Location updated successfully!');
      } catch (e) {
        _showMessage('Failed to update location: $e', isError: true);
      }
    }
  }

  Future<void> _deleteLocation(SavedLocation location) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGrey,
        title: const Text('Delete Location'),
        content: Text('Are you sure you want to delete "${location.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(locationProvider.notifier).deleteSavedLocation(location.id);
        _showMessage('Location deleted successfully!');
      } catch (e) {
        _showMessage('Failed to delete location: $e', isError: true);
      }
    }
  }

  IconData _getLocationIcon(String type) {
    switch (type) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }

  String _getLocationTypeLabel(String type) {
    switch (type) {
      case 'home':
        return 'Home';
      case 'work':
        return 'Work';
      default:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final savedLocations = locationState.savedLocations;
    final isLoading = locationState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Saved Locations', style: AppTheme.headingS),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedLocations.isEmpty
              ? _buildEmptyState()
              : _buildLocationsList(savedLocations),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addLocation,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Location'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: AppColors.mediumGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'No saved locations yet',
            style: AppTheme.headingS.copyWith(color: AppColors.mediumGrey),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your favorite places for quick access',
            style: AppTheme.bodySmall.copyWith(color: AppColors.mediumGrey),
          ),
          const SizedBox(height: 32),
          GoldenButton(
            label: 'Add First Location',
            onPressed: _addLocation,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsList(List<SavedLocation> locations) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.darkGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.mediumGrey),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getLocationIcon(location.locationType),
                color: AppColors.primary,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    location.name,
                    style: AppTheme.labelLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getLocationTypeLabel(location.locationType),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                location.address ?? 'No address',
                style: AppTheme.bodySmall.copyWith(
                  color: AppColors.mediumGrey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              color: AppColors.darkGrey,
              onSelected: (value) {
                if (value == 'edit') {
                  _editLocation(location);
                } else if (value == 'delete') {
                  _deleteLocation(location);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// ADD/EDIT LOCATION SCREEN WITH MAP PICKER
// ============================================================================

class AddEditLocationScreen extends StatefulWidget {
  final SavedLocation? location;

  const AddEditLocationScreen({Key? key, this.location}) : super(key: key);

  @override
  State<AddEditLocationScreen> createState() => _AddEditLocationScreenState();
}

class _AddEditLocationScreenState extends State<AddEditLocationScreen> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  String _selectedType = 'home';
  LatLng? _selectedPosition;
  GoogleMapController? _mapController;
  bool _isLoadingAddress = false;
  bool _isGettingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.location?.name ?? '');
    _addressController = TextEditingController(text: widget.location?.address ?? '');
    _selectedType = widget.location?.locationType ?? 'home';
    
    if (widget.location != null) {
      _selectedPosition = LatLng(
        widget.location!.latitude,
        widget.location!.longitude,
      );
    } else {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingCurrentLocation = true);
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedPosition = LatLng(position.latitude, position.longitude);
        _isGettingCurrentLocation = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_selectedPosition!),
      );

      _getAddressFromLatLng(_selectedPosition!);
    } catch (e) {
      setState(() => _isGettingCurrentLocation = false);
      _showMessage('Failed to get current location: $e', isError: true);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() => _isLoadingAddress = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        setState(() {
          _addressController.text = address;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingAddress = false);
      _showMessage('Failed to get address', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
    _getAddressFromLatLng(position);
  }

  void _saveLocation() {
    if (_nameController.text.isEmpty) {
      _showMessage('Please enter a location name', isError: true);
      return;
    }

    if (_selectedPosition == null) {
      _showMessage('Please select a location on the map', isError: true);
      return;
    }

    Navigator.pop(context, {
      'name': _nameController.text,
      'address': _addressController.text,
      'latitude': _selectedPosition!.latitude,
      'longitude': _selectedPosition!.longitude,
      'type': _selectedType,
    });
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.location == null ? 'Add Location' : 'Edit Location',
          style: AppTheme.headingS,
        ),
      ),
      body: Column(
        children: [
          // Map Section
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                _selectedPosition == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isGettingCurrentLocation)
                              const CircularProgressIndicator()
                            else ...[
                              Icon(
                                Icons.location_searching,
                                size: 60,
                                color: AppColors.mediumGrey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Getting your location...',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppColors.mediumGrey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _selectedPosition!,
                          zoom: 15,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        onTap: _onMapTap,
                        markers: {
                          Marker(
                            markerId: const MarkerId('selected'),
                            position: _selectedPosition!,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueYellow,
                            ),
                          ),
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                      ),
                // Current Location Button
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: _getCurrentLocation,
                    child: Icon(
                      Icons.my_location,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Form Section
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location Details', style: AppTheme.headingS),
                    const SizedBox(height: 16),
                    // Location Type Selector
                    Row(
                      children: [
                        _buildTypeChip('home', Icons.home, 'Home'),
                        const SizedBox(width: 8),
                        _buildTypeChip('work', Icons.work, 'Work'),
                        const SizedBox(width: 8),
                        _buildTypeChip('other', Icons.location_on, 'Other'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Name Input
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Location Name',
                        hintText: 'e.g., My Home, Office',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.mediumGrey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.mediumGrey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Address Input
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        hintText: 'Select location on map',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.mediumGrey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.mediumGrey),
                        ),
                        suffixIcon: _isLoadingAddress
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : null,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: GoldenButton(
                        label: widget.location == null ? 'Save Location' : 'Update Location',
                        onPressed: _saveLocation,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type, IconData icon, String label) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.2)
                : AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.mediumGrey,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.mediumGrey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.mediumGrey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
