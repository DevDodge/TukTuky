import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// Google Places API Service for location autocomplete and place details
class PlacesService {
  static const String _placesBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  
  // Your Google Maps API key
  static const String _apiKey = 'AIzaSyBy_Ee_CKO3CrMF7TLofcLPT4ANvm9NVR8';
  
  final Logger _logger = Logger();
  
  /// Search for places using Google Places Autocomplete API
  /// Returns a list of place predictions
  Future<List<PlacePrediction>> searchPlaces(String query, {String? language}) async {
    if (query.isEmpty) return [];
    
    try {
      final uri = Uri.parse('$_placesBaseUrl/autocomplete/json').replace(
        queryParameters: {
          'input': query,
          'key': _apiKey,
          'types': 'geocode|establishment',
          'components': 'country:eg', // Restrict to Egypt
          'language': language ?? 'ar', // Arabic by default
        },
      );
      
      _logger.d('Searching places: $uri');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          _logger.d('Found ${predictions.length} predictions');
          return predictions
              .map((p) => PlacePrediction.fromJson(p))
              .toList();
        } else if (data['status'] == 'ZERO_RESULTS') {
          return [];
        } else {
          _logger.e('Places API error: ${data['status']} - ${data['error_message']}');
          return [];
        }
      } else {
        _logger.e('HTTP error: ${response.statusCode}');
        return [];
      }
    } catch (e, stack) {
      _logger.e('Error searching places: $e', error: e, stackTrace: stack);
      return [];
    }
  }
  
  /// Get place details using Place ID
  /// Returns latitude, longitude, and formatted address
  Future<PlaceDetails?> getPlaceDetails(String placeId, {String? fallbackAddress}) async {
    _logger.d('Getting details for placeId: $placeId');
    
    try {
      // Build URL with proper encoding
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/details/json',
        {
          'place_id': placeId,
          'key': _apiKey,
          'fields': 'geometry,formatted_address,name',
        },
      );
      
      _logger.d('Place Details URL: $uri');
      final response = await http.get(uri);
      
      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final result = data['result'];
          _logger.i('✅ Got place details: ${result['name']}');
          return PlaceDetails.fromJson(result);
        } else {
          _logger.e('Place Details API error status: ${data['status']} - ${data['error_message']}');
        }
      } else {
        _logger.e('HTTP error: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logger.e('Place Details error: $e', error: e, stackTrace: stack);
    }
    
    _logger.w('Place Details failed, returning null');
    return null;
  }
}

/// Model for place autocomplete predictions
class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  
  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });
  
  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] ?? {};
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: structuredFormatting['main_text'] ?? json['description'] ?? '',
      secondaryText: structuredFormatting['secondary_text'] ?? '',
    );
  }
  
  @override
  String toString() => 'PlacePrediction(placeId: $placeId, mainText: $mainText)';
}

/// Model for place details with coordinates
class PlaceDetails {
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  
  PlaceDetails({
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });
  
  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] ?? {};
    final location = geometry['location'] ?? {};
    
    return PlaceDetails(
      name: json['name'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
      latitude: (location['lat'] ?? 0.0).toDouble(),
      longitude: (location['lng'] ?? 0.0).toDouble(),
    );
  }
  
  @override
  String toString() => 'PlaceDetails(name: $name, lat: $latitude, lng: $longitude)';
}
