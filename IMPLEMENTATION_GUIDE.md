# TukTuky Implementation Guide

This guide provides step-by-step instructions for implementing the TukTuky platform features.

## Table of Contents

1. [Environment Setup](#environment-setup)
2. [Passenger App Implementation](#passenger-app-implementation)
3. [Driver App Implementation](#driver-app-implementation)
4. [Admin Dashboard Implementation](#admin-dashboard-implementation)
5. [Backend Integration](#backend-integration)
6. [Testing Strategy](#testing-strategy)

## Environment Setup

### 1. Install Dependencies

#### Flutter Apps
```bash
# Install Flutter (if not already installed)
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$(pwd)/flutter/bin"

# Verify installation
flutter doctor

# Get dependencies for both apps
cd passenger_app && flutter pub get
cd ../driver_app && flutter pub get
```

#### Admin Dashboard
```bash
cd dashboard
npm install
```

### 2. Configure Supabase

Create a `.env` file in each app directory:

**passenger_app/.env**
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
GOOGLE_MAPS_API_KEY=your_google_maps_key
FIREBASE_PROJECT_ID=your_firebase_project
```

**driver_app/.env**
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
GOOGLE_MAPS_API_KEY=your_google_maps_key
FIREBASE_PROJECT_ID=your_firebase_project
```

### 3. Initialize Firebase

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in each app
cd passenger_app
flutterfire configure

cd ../driver_app
flutterfire configure
```

## Passenger App Implementation

### Phase 1: Authentication

#### 1.1 Create Authentication Provider

Create `passenger_app/lib/providers/auth_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  late final SupabaseService _supabaseService;

  AuthNotifier(this.ref) : super(const AuthState.initial()) {
    _supabaseService = SupabaseService();
    _initializeAuth();
  }

  void _initializeAuth() {
    _supabaseService.authStateChanges.listen((state) {
      if (state.session != null) {
        _loadUser();
      } else {
        state = const AuthState.unauthenticated();
      }
    });
  }

  Future<void> _loadUser() async {
    final user = await _supabaseService.getCurrentUser();
    if (user != null) {
      state = AuthState.authenticated(user);
    }
  }

  Future<void> signInWithGoogle(String idToken) async {
    try {
      state = const AuthState.loading();
      await _supabaseService.signInWithGoogle(idToken);
      await _loadUser();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}

sealed class AuthState {
  const AuthState();

  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

class _Initial extends AuthState {
  const _Initial();
}

class _Loading extends AuthState {
  const _Loading();
}

class _Authenticated extends AuthState {
  final User user;
  const _Authenticated(this.user);
}

class _Unauthenticated extends AuthState {
  const _Unauthenticated();
}

class _Error extends AuthState {
  final String message;
  const _Error(this.message);
}
```

#### 1.2 Create Login Screen

Create `passenger_app/lib/screens/login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              const Text(
                'TukTuky',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDD8B01),
                ),
              ),
              const SizedBox(height: 48),

              // Google Sign In Button
              ElevatedButton.icon(
                onPressed: () {
                  // Implement Google Sign In
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDD8B01),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),

              // Apple Sign In Button
              ElevatedButton.icon(
                onPressed: () {
                  // Implement Apple Sign In
                },
                icon: const Icon(Icons.apple),
                label: const Text('Sign in with Apple'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),

              // Phone Sign In Button
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to phone OTP screen
                },
                icon: const Icon(Icons.phone),
                label: const Text('Sign in with Phone'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC8F01),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Phase 2: Home Screen & Trip Booking

#### 2.1 Create Home Screen

Create `passenger_app/lib/screens/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(30.0444, 31.2357), // Cairo
              zoom: 15,
            ),
          ),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Where to?',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                onTap: () {
                  // Navigate to trip booking screen
                },
              ),
            ),
          ),

          // Bottom Sheet with Recent Trips
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Recent Trips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // List of recent trips
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Phase 3: Trip Booking & Bidding

#### 3.1 Create Trip Booking Screen

Create `passenger_app/lib/screens/trip_booking_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TripBookingScreen extends ConsumerStatefulWidget {
  const TripBookingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TripBookingScreen> createState() => _TripBookingScreenState();
}

class _TripBookingScreenState extends ConsumerState<TripBookingScreen> {
  final pickupController = TextEditingController();
  final dropoffController = TextEditingController();
  final fareController = TextEditingController();
  bool useQuickRide = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Trip'),
        backgroundColor: const Color(0xFFDD8B01),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pickup Location
            const Text(
              'Pickup Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: pickupController,
              decoration: InputDecoration(
                hintText: 'Enter pickup location',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 24),

            // Dropoff Location
            const Text(
              'Dropoff Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: dropoffController,
              decoration: InputDecoration(
                hintText: 'Enter dropoff location',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 24),

            // Ride Type Selection
            const Text(
              'Ride Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => useQuickRide = true);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: useQuickRide
                              ? const Color(0xFFDD8B01)
                              : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.directions_car),
                          SizedBox(height: 8),
                          Text('Quick Ride'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => useQuickRide = false);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: !useQuickRide
                              ? const Color(0xFFDD8B01)
                              : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.local_offer),
                          SizedBox(height: 8),
                          Text('Set Price'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Price Input (if Set Price selected)
            if (!useQuickRide) ...[
              const Text(
                'Your Offer (EGP)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fareController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter your offer',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Book Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Handle booking
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDD8B01),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Book Trip',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    pickupController.dispose();
    dropoffController.dispose();
    fareController.dispose();
    super.dispose();
  }
}
```

## Driver App Implementation

### Phase 1: KYC Verification

#### 1.1 Create Document Upload Screen

Create `driver_app/lib/screens/kyc_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class KYCScreen extends StatefulWidget {
  const KYCScreen({Key? key}) : super(key: key);

  @override
  State<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen> {
  final imagePicker = ImagePicker();
  final documents = {
    'national_id_front': null,
    'national_id_back': null,
    'driving_license': null,
    'vehicle_registration': null,
    'vehicle_insurance': null,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verification'),
        backgroundColor: const Color(0xFFDD8B01),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // National ID Front
          _buildDocumentUploadCard(
            title: 'National ID - Front',
            documentKey: 'national_id_front',
          ),
          const SizedBox(height: 16),

          // National ID Back
          _buildDocumentUploadCard(
            title: 'National ID - Back',
            documentKey: 'national_id_back',
          ),
          const SizedBox(height: 16),

          // Driving License
          _buildDocumentUploadCard(
            title: 'Driving License',
            documentKey: 'driving_license',
          ),
          const SizedBox(height: 16),

          // Vehicle Registration
          _buildDocumentUploadCard(
            title: 'Vehicle Registration',
            documentKey: 'vehicle_registration',
          ),
          const SizedBox(height: 16),

          // Vehicle Insurance
          _buildDocumentUploadCard(
            title: 'Vehicle Insurance',
            documentKey: 'vehicle_insurance',
          ),
          const SizedBox(height: 32),

          // Submit Button
          ElevatedButton(
            onPressed: () {
              // Submit documents
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDD8B01),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Submit for Verification',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required String documentKey,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (documents[documentKey] == null)
              GestureDetector(
                onTap: () async {
                  final image = await imagePicker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    setState(() {
                      documents[documentKey] = image.path;
                    });
                  }
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 48),
                        SizedBox(height: 8),
                        Text('Tap to upload'),
                      ],
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: const Center(
                      child: Icon(Icons.check_circle, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        documents[documentKey] = null;
                      });
                    },
                    child: const Text('Replace'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
```

### Phase 2: Trip Management

#### 2.1 Create Available Trips Screen

Create `driver_app/lib/screens/available_trips_screen.dart`:

```dart
import 'package:flutter/material.dart';

class AvailableTripsScreen extends StatefulWidget {
  const AvailableTripsScreen({Key? key}) : super(key: key);

  @override
  State<AvailableTripsScreen> createState() => _AvailableTripsScreenState();
}

class _AvailableTripsScreenState extends State<AvailableTripsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Trips'),
        backgroundColor: const Color(0xFFDD8B01),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // Replace with actual trip count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cairo → Giza',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '5.2 km • 15 min',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'EGP 50',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDD8B01),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCF202),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '3 offers',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('View Details'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDD8B01),
                          ),
                          child: const Text('Send Offer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

## Admin Dashboard Implementation

### Phase 1: Analytics Dashboard

Create `dashboard/src/pages/Dashboard.tsx`:

```tsx
import React from 'react';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

const Dashboard: React.FC = () => {
  const data = [
    { month: 'Jan', trips: 400, revenue: 2400 },
    { month: 'Feb', trips: 300, revenue: 1398 },
    { month: 'Mar', trips: 200, revenue: 9800 },
  ];

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-8">Dashboard</h1>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-gray-600 mb-2">Active Users</h3>
          <p className="text-3xl font-bold text-yellow-600">2,543</p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-gray-600 mb-2">Total Trips</h3>
          <p className="text-3xl font-bold text-yellow-600">12,456</p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-gray-600 mb-2">Revenue</h3>
          <p className="text-3xl font-bold text-yellow-600">EGP 125,430</p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-gray-600 mb-2">Avg Rating</h3>
          <p className="text-3xl font-bold text-yellow-600">4.8/5</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="bg-white p-6 rounded-lg shadow">
          <h2 className="text-xl font-bold mb-4">Trips & Revenue</h2>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={data}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Line type="monotone" dataKey="trips" stroke="#DD8B01" />
              <Line type="monotone" dataKey="revenue" stroke="#FCF202" />
            </LineChart>
          </ResponsiveContainer>
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <h2 className="text-xl font-bold mb-4">Monthly Revenue</h2>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={data}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="revenue" fill="#DD8B01" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
```

## Backend Integration

### API Service Setup

Create `passenger_app/lib/services/api_service.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;
  final logger = Logger();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://your-api-url/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          logger.i('${options.method} ${options.path}');
          return handler.next(options);
        },
        onError: (error, handler) {
          logger.e('Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return fromJson != null ? fromJson(response.data) : response.data;
    } catch (e) {
      logger.e('GET Error: $e');
      rethrow;
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return fromJson != null ? fromJson(response.data) : response.data;
    } catch (e) {
      logger.e('POST Error: $e');
      rethrow;
    }
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return fromJson != null ? fromJson(response.data) : response.data;
    } catch (e) {
      logger.e('PUT Error: $e');
      rethrow;
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } catch (e) {
      logger.e('DELETE Error: $e');
      rethrow;
    }
  }
}
```

## Testing Strategy

### Unit Testing

Create `passenger_app/test/models_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/models/models.dart';

void main() {
  group('User Model', () {
    test('User.fromJson creates correct instance', () {
      final json = {
        'id': 1,
        'open_id': 'google_123',
        'name': 'John Doe',
        'email': 'john@example.com',
        'phone': '+201234567890',
        'role': 'passenger',
        'is_blocked': false,
        'language': 'ar',
        'referral_code': 'JOHN123',
        'referred_by': null,
        'referral_earnings': 0.0,
        'profile_completeness': 75,
        'created_at': '2026-01-29T10:30:00Z',
        'updated_at': '2026-01-29T10:30:00Z',
        'last_signed_in': '2026-01-29T10:30:00Z',
      };

      final user = User.fromJson(json);

      expect(user.id, 1);
      expect(user.openId, 'google_123');
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.role, 'passenger');
    });

    test('User.toJson creates correct JSON', () {
      final user = User(
        id: 1,
        openId: 'google_123',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+201234567890',
        role: 'passenger',
        createdAt: DateTime(2026, 1, 29),
        updatedAt: DateTime(2026, 1, 29),
        lastSignedIn: DateTime(2026, 1, 29),
      );

      final json = user.toJson();

      expect(json['id'], 1);
      expect(json['open_id'], 'google_123');
      expect(json['name'], 'John Doe');
    });
  });

  group('Trip Model', () {
    test('Trip.fromJson creates correct instance', () {
      final json = {
        'id': 1,
        'passenger_id': 1,
        'driver_id': null,
        'status': 'requested',
        'pickup_lat': 30.0444,
        'pickup_lng': 31.2357,
        'pickup_address': 'Cairo',
        'dropoff_lat': 30.0500,
        'dropoff_lng': 31.2400,
        'dropoff_address': 'Giza',
        'estimated_distance': 5.2,
        'estimated_duration': 15,
        'actual_distance': null,
        'actual_duration': null,
        'passenger_offered_fare': 50.0,
        'views_count': 0,
        'offers_count': 0,
        'accepted_offer_id': null,
        'base_fare': 10.0,
        'distance_fare': 0.0,
        'time_fare': 0.0,
        'surge_fare': 0.0,
        'discount': 0.0,
        'total_fare': 50.0,
        'payment_method': 'cash',
        'payment_status': 'pending',
        'requested_at': '2026-01-29T10:30:00Z',
        'driver_assigned_at': null,
        'driver_arrived_at': null,
        'trip_started_at': null,
        'trip_ended_at': null,
        'passenger_rating': null,
        'passenger_review': null,
        'driver_rating': null,
        'driver_review': null,
        'cancellation_reason': null,
        'cancellation_fee': 0.0,
      };

      final trip = Trip.fromJson(json);

      expect(trip.id, 1);
      expect(trip.passengerId, 1);
      expect(trip.status, 'requested');
      expect(trip.totalFare, 50.0);
    });
  });
}
```

### Integration Testing

Create `passenger_app/integration_test/app_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:passenger_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('Login flow works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify login screen is displayed
      expect(find.text('TukTuky'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
    });

    testWidgets('Navigation works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap on Google Sign In button
      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.byType(app.HomeScreen), findsOneWidget);
    });
  });
}
```

## Conclusion

This implementation guide provides a structured approach to building the TukTuky platform. Follow the phases sequentially and test thoroughly at each step. For detailed API documentation, refer to [API_DOCUMENTATION.md](API_DOCUMENTATION.md).

For questions or issues, refer to the project documentation or contact the development team.
