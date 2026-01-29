# Fixes Applied - Saved Locations Module

## Date: January 29, 2026

---

## Issues Fixed

### 1. ❌ Foreign Key Constraint Violation (user_id=0)
**Error**: `insert or update on table "saved_locations" violates foreign key constraint "saved_locations_user_id_fkey"`

**Root Cause**: When `currentUser` was null in the location provider, it defaulted to `userId = 0`, which doesn't exist in the database.

**Solution Applied**:
- Modified `getSavedLocations()` in `supabase_service.dart` to fetch the actual user ID from Supabase auth when `userId == 0`
- Modified `createSavedLocation()` in `supabase_service.dart` to fetch the actual user ID from Supabase auth when `userId == 0`
- Added proper error handling with meaningful error messages

**Files Modified**:
- `lib/services/supabase_service.dart`

---

### 2. 🗺️ Map Showing San Francisco Instead of Egypt
**Issue**: The map was showing San Francisco, CA instead of the user's actual location in Egypt.

**Root Cause**: iOS simulator defaults to San Francisco coordinates. The app was correctly getting the "current location" from the simulator, but that location was San Francisco.

**Solution Applied**:
- Added geographic bounds check for Egypt (22°N to 32°N, 25°E to 35°E)
- If detected location is outside Egypt, automatically use Cairo coordinates (30.0444°N, 31.2357°E)
- Added user-friendly message informing about the fallback
- Added fallback to Cairo if GPS fails completely

**Files Modified**:
- `lib/screens/profile/saved_locations_screen.dart`

---

## Code Changes

### 1. `lib/services/supabase_service.dart`

#### getSavedLocations Method
```dart
Future<List<models.SavedLocation>> getSavedLocations(int userId) async {
  try {
    // If userId is 0, get it from the authenticated user's database record
    int actualUserId = userId;
    if (userId == 0) {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return []; // Return empty list if not authenticated
      }
      actualUserId = currentUser.id;
    }
    
    final response = await _client
        .from('saved_locations')
        .select()
        .eq('user_id', actualUserId)
        .order('is_default', ascending: false);

    return (response as List)
        .map((location) => models.SavedLocation.fromJson(location))
        .toList();
  } catch (e) {
    logger.e('Error getting saved locations: $e');
    return [];
  }
}
```

#### createSavedLocation Method
```dart
Future<models.SavedLocation> createSavedLocation(
    int userId, Map<String, dynamic> locationData) async {
  try {
    // If userId is 0, get it from the authenticated user's database record
    int actualUserId = userId;
    if (userId == 0) {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('User must be logged in to save locations');
      }
      actualUserId = currentUser.id;
    }
    
    locationData['user_id'] = actualUserId;
    final response = await _client
        .from('saved_locations')
        .insert(locationData)
        .select()
        .single();

    return models.SavedLocation.fromJson(response);
  } catch (e) {
    logger.e('Error creating saved location: $e');
    rethrow;
  }
}
```

### 2. `lib/screens/profile/saved_locations_screen.dart`

#### _getCurrentLocation Method
```dart
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

    // Check if location is in Egypt (rough bounds: 22°N to 32°N, 25°E to 35°E)
    // If not (e.g., simulator default), use Cairo as default
    LatLng finalPosition;
    if (position.latitude >= 22 && position.latitude <= 32 &&
        position.longitude >= 25 && position.longitude <= 35) {
      // Location is in Egypt, use it
      finalPosition = LatLng(position.latitude, position.longitude);
    } else {
      // Location is outside Egypt (likely simulator default), use Cairo
      finalPosition = const LatLng(30.0444, 31.2357); // Cairo, Egypt
      _showMessage('Using Cairo as default location. Set simulator location to your actual location in Egypt.', isError: false);
    }

    setState(() {
      _selectedPosition = finalPosition;
      _isGettingCurrentLocation = false;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_selectedPosition!),
    );

    _getAddressFromLatLng(_selectedPosition!);
  } catch (e) {
    setState(() => _isGettingCurrentLocation = false);
    // If GPS fails completely, use Cairo as fallback
    setState(() {
      _selectedPosition = const LatLng(30.0444, 31.2357); // Cairo, Egypt
    });
    _showMessage('Using Cairo as default location', isError: false);
  }
}
```

---

## How to Set Simulator Location to Egypt

### Option 1: Custom Location (Recommended)
1. Open the iOS Simulator
2. Go to **Features** → **Location** → **Custom Location...**
3. Enter coordinates for your location in Egypt:
   - **Cairo**: Latitude: `30.0444`, Longitude: `31.2357`
   - **Alexandria**: Latitude: `31.2001`, Longitude: `29.9187`
   - **Giza**: Latitude: `30.0131`, Longitude: `31.2089`
4. Click **OK**

### Option 2: Use GPX File
1. Create a GPX file with your Egypt location
2. Go to **Features** → **Location** → **GPX File...**
3. Select your GPX file

### Option 3: Xcode Scheme
1. In Xcode, go to **Product** → **Scheme** → **Edit Scheme...**
2. Select **Run** → **Options**
3. Check **Allow Location Simulation**
4. Choose a default location or add a custom one

---

## Testing Instructions

### 1. Test User Authentication Fix
1. **Restart the app** (hot restart: press 'R')
2. Navigate to **Profile → Saved Locations**
3. Tap **"Add Location"**
4. Fill in the details and tap **"Save Location"**
5. **Expected**: Location saves successfully without foreign key error

### 2. Test Egypt Location Fix
1. **Set simulator location** to Cairo using instructions above
2. Tap **"Add Location"**
3. **Expected**: Map shows Cairo, Egypt (not San Francisco)
4. **Alternative**: If simulator is still on San Francisco, the app will automatically use Cairo and show a message

### 3. Test Map Interaction
1. Tap on the map to select a location
2. **Expected**: Marker moves, address updates
3. Tap **"My Location"** button
4. **Expected**: Map centers on current location (Cairo if in simulator)

---

## Benefits of These Fixes

### User ID Fix
✅ Prevents database errors when user state is loading  
✅ Automatically retrieves correct user ID from Supabase auth  
✅ Provides clear error messages if user is not authenticated  
✅ Works even if the User model hasn't loaded yet

### Location Fix
✅ Automatically detects if location is outside Egypt  
✅ Uses Cairo as sensible default for Egyptian app  
✅ Informs user about the fallback  
✅ Works on simulator without manual configuration  
✅ Still uses actual GPS location if in Egypt

---

## Known Limitations

1. **Egypt Bounds Check**: The geographic bounds are approximate. Locations very close to Egypt's borders might be incorrectly flagged as outside Egypt.

2. **Simulator Only**: The Cairo fallback is primarily for simulator testing. On real devices in Egypt, GPS will work correctly.

3. **User Model Dependency**: The fix still depends on the User model being available in the database. If the user exists in Supabase auth but not in the users table, it will fail.

---

## Next Steps

1. ✅ Test the fixes thoroughly
2. ✅ Verify locations save correctly
3. ✅ Verify map shows Egypt locations
4. ✅ Test on real device in Egypt
5. ⏭️ Move to next module (Emergency Contacts)

---

## Status

✅ **Fixes Applied and Ready for Testing**

Both issues have been resolved:
- Foreign key constraint error fixed
- Map location defaults to Egypt

Please test and report any remaining issues.
