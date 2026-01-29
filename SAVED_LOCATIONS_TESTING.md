# Saved Locations Module - Testing Guide

## Module Implementation Summary

The **Saved Locations Module** has been fully implemented with the following features:

### 1. Backend Services (Supabase)
- ✅ `getSavedLocations(userId)` - Fetch all saved locations for a user
- ✅ `createSavedLocation(userId, data)` - Create a new saved location
- ✅ `updateSavedLocation(locationId, data)` - Update an existing location (NEW)
- ✅ `deleteSavedLocation(locationId)` - Delete a saved location

### 2. State Management (Riverpod)
- ✅ `LocationNotifier` with full CRUD operations
- ✅ `addSavedLocation()` - Add new location
- ✅ `updateSavedLocation()` - Update existing location (NEW)
- ✅ `deleteSavedLocation()` - Delete location
- ✅ Automatic loading on initialization
- ✅ Error handling and state updates

### 3. UI Implementation
- ✅ **Main Screen** (`saved_locations_screen_complete.dart`)
  - List view of all saved locations
  - Empty state with call-to-action
  - Location type indicators (Home/Work/Other)
  - Edit and delete options via menu
  - Loading states
  
- ✅ **Add/Edit Screen** (`AddEditLocationScreen`)
  - Google Maps integration for location picking
  - Current location detection
  - Reverse geocoding (lat/lng → address)
  - Location type selector (Home/Work/Other)
  - Form validation
  - Tap on map to select location
  - My location button

### 4. Features Implemented
- ✅ Add new saved location with map picker
- ✅ Edit existing saved location
- ✅ Delete saved location with confirmation
- ✅ View all saved locations
- ✅ Location type categorization (Home/Work/Other)
- ✅ Address autocomplete via reverse geocoding
- ✅ Current location detection
- ✅ Map-based location selection
- ✅ Proper error handling and user feedback

---

## Testing Checklist

### Prerequisites
1. Ensure Supabase is properly configured with credentials
2. Ensure Google Maps API key is configured
3. Ensure location permissions are granted
4. Ensure user is logged in

### Test Cases

#### 1. View Saved Locations
- [ ] Open the app and navigate to Profile → Saved Locations
- [ ] Verify empty state is shown if no locations exist
- [ ] Verify "Add First Location" button is visible
- [ ] Add a location and verify it appears in the list
- [ ] Verify location icon matches type (Home/Work/Other)
- [ ] Verify address is displayed correctly
- [ ] Verify location type badge is shown

#### 2. Add New Location
- [ ] Tap "Add Location" button
- [ ] Verify map opens with current location
- [ ] Verify "My Location" button works
- [ ] Tap on map to select a different location
- [ ] Verify marker moves to tapped location
- [ ] Verify address is automatically filled via reverse geocoding
- [ ] Select location type (Home/Work/Other)
- [ ] Enter location name (e.g., "My Home")
- [ ] Tap "Save Location"
- [ ] Verify success message is shown
- [ ] Verify location appears in the list

#### 3. Edit Existing Location
- [ ] Tap the menu icon (⋮) on a saved location
- [ ] Select "Edit"
- [ ] Verify map opens with the saved location
- [ ] Verify form is pre-filled with existing data
- [ ] Change location name
- [ ] Change location type
- [ ] Tap on map to change location
- [ ] Tap "Update Location"
- [ ] Verify success message is shown
- [ ] Verify changes are reflected in the list

#### 4. Delete Location
- [ ] Tap the menu icon (⋮) on a saved location
- [ ] Select "Delete"
- [ ] Verify confirmation dialog appears
- [ ] Tap "Cancel" and verify location is not deleted
- [ ] Tap menu → Delete again
- [ ] Tap "Delete" in confirmation
- [ ] Verify success message is shown
- [ ] Verify location is removed from the list

#### 5. Location Type Selection
- [ ] Create a location with type "Home"
- [ ] Verify Home icon is shown
- [ ] Create a location with type "Work"
- [ ] Verify Work icon is shown
- [ ] Create a location with type "Other"
- [ ] Verify Location pin icon is shown

#### 6. Map Interaction
- [ ] Test map zoom in/out
- [ ] Test map pan/drag
- [ ] Test tapping on different map locations
- [ ] Test "My Location" button
- [ ] Verify marker updates on tap
- [ ] Verify address updates after marker moves

#### 7. Form Validation
- [ ] Try to save without entering a name
- [ ] Verify error message is shown
- [ ] Try to save without selecting a location
- [ ] Verify error message is shown
- [ ] Enter valid data and verify save works

#### 8. Error Handling
- [ ] Test with no internet connection
- [ ] Verify error message is shown
- [ ] Test with location permissions denied
- [ ] Verify appropriate error is shown
- [ ] Test with invalid Supabase credentials
- [ ] Verify error is handled gracefully

#### 9. Loading States
- [ ] Verify loading indicator shows when fetching locations
- [ ] Verify loading indicator shows when getting current location
- [ ] Verify loading indicator shows when reverse geocoding
- [ ] Verify loading indicator shows when saving/updating

#### 10. Integration with Other Modules
- [ ] Verify saved locations can be used in trip booking (future)
- [ ] Verify locations persist across app restarts
- [ ] Verify locations are user-specific (not shared)

---

## Database Verification

### SQL Queries to Verify Data

```sql
-- Check if saved_locations table exists
SELECT * FROM saved_locations LIMIT 5;

-- Check locations for a specific user
SELECT * FROM saved_locations WHERE user_id = <USER_ID>;

-- Verify location types
SELECT location_type, COUNT(*) 
FROM saved_locations 
GROUP BY location_type;

-- Check for duplicate locations
SELECT user_id, name, COUNT(*) 
FROM saved_locations 
GROUP BY user_id, name 
HAVING COUNT(*) > 1;
```

---

## Known Limitations

1. **No Address Search**: Currently only map-based selection and current location. Address search can be added later using Places API.
2. **No Default Location**: The `is_default` flag exists in the database but is not used in the UI yet.
3. **No Location Sharing**: Locations are private to each user.
4. **No Batch Operations**: Can only add/edit/delete one location at a time.

---

## Next Steps

After testing is complete:

1. **Fix any bugs** found during testing
2. **Update the original screen** (`saved_locations_screen.dart`) with the complete implementation
3. **Add address search** using Google Places API (optional enhancement)
4. **Integrate with trip booking** module to use saved locations
5. **Move to next module**: Emergency Contacts or User Profile Edit

---

## Files Modified/Created

### New Files
- `lib/screens/profile/saved_locations_screen_complete.dart` - Complete implementation

### Modified Files
- `lib/services/supabase_service.dart` - Added `updateSavedLocation()` method
- `lib/providers/location_provider.dart` - Added `updateSavedLocation()` method

### Files to Update (After Testing)
- `lib/screens/profile/saved_locations_screen.dart` - Replace with complete version
- `lib/config/router.dart` - Update import if needed

---

## Running the App

```bash
# Navigate to passenger app directory
cd /home/ubuntu/TukTuky/passenger_app

# Get dependencies
flutter pub get

# Run the app (Android)
flutter run

# Or run on specific device
flutter run -d <device_id>

# Check for any errors
flutter analyze
```

---

## Troubleshooting

### Issue: Map not showing
- Check Google Maps API key in Android/iOS config
- Verify API key has Maps SDK enabled
- Check internet connection

### Issue: Location permission denied
- Go to app settings and grant location permission
- Restart the app

### Issue: Address not loading
- Check Geocoding API is enabled
- Verify internet connection
- Check API quota limits

### Issue: Database errors
- Verify Supabase credentials
- Check table exists and has correct schema
- Verify user is authenticated
- Check Row Level Security policies

---

## Success Criteria

The module is considered complete when:
- ✅ All test cases pass
- ✅ No critical bugs
- ✅ UI is responsive and user-friendly
- ✅ Data persists correctly in database
- ✅ Error handling works properly
- ✅ Loading states are clear
- ✅ User feedback (messages) is appropriate
