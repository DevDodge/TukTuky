// User Models
class User {
  final int id;
  final String openId;
  final String? name;
  final String? email;
  final String? phone;
  final String? profilePhotoUrl;
  final String role;
  final bool isBlocked;
  final String language;
  final String? referralCode;
  final int? referredBy;
  final double referralEarnings;
  final int profileCompleteness;
  final double rating;
  final int totalTrips;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastSignedIn;

  User({
    required this.id,
    required this.openId,
    this.name,
    this.email,
    this.phone,
    this.profilePhotoUrl,
    this.role = 'passenger',
    this.isBlocked = false,
    this.language = 'ar',
    this.referralCode,
    this.referredBy,
    this.referralEarnings = 0.0,
    this.profileCompleteness = 0,
    this.rating = 5.0,
    this.totalTrips = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.lastSignedIn,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      openId: json['open_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profilePhotoUrl: json['profile_photo_url'],
      role: json['role'] ?? 'passenger',
      isBlocked: json['is_blocked'] ?? false,
      language: json['language'] ?? 'ar',
      referralCode: json['referral_code'],
      referredBy: json['referred_by'],
      referralEarnings: (json['referral_earnings'] ?? 0.0).toDouble(),
      profileCompleteness: json['profile_completeness'] ?? 0,
      rating: (json['rating'] ?? 5.0).toDouble(),
      totalTrips: json['total_trips'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastSignedIn: DateTime.parse(json['last_signed_in']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'open_id': openId,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_photo_url': profilePhotoUrl,
      'role': role,
      'is_blocked': isBlocked,
      'language': language,
      'referral_code': referralCode,
      'referred_by': referredBy,
      'referral_earnings': referralEarnings,
      'profile_completeness': profileCompleteness,
      'rating': rating,
      'total_trips': totalTrips,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_signed_in': lastSignedIn.toIso8601String(),
    };
  }
}

// Trip Models
class Trip {
  final int id;
  final int passengerId;
  final int? driverId;
  final String status;
  final double pickupLat;
  final double pickupLng;
  final String? pickupAddress;
  final double dropoffLat;
  final double dropoffLng;
  final String? dropoffAddress;
  final double? estimatedDistance;
  final int? estimatedDuration;
  final double? actualDistance;
  final int? actualDuration;
  final double? passengerOfferedFare;
  final int viewsCount;
  final int offersCount;
  final int? acceptedOfferId;
  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double surgeFare;
  final double discount;
  final double totalFare;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime requestedAt;
  final DateTime? driverAssignedAt;
  final DateTime? driverArrivedAt;
  final DateTime? tripStartedAt;
  final DateTime? tripEndedAt;
  final double? passengerRating;
  final String? passengerReview;
  final double? driverRating;
  final String? driverReview;
  final String? cancellationReason;
  final double cancellationFee;

  Trip({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.status,
    required this.pickupLat,
    required this.pickupLng,
    this.pickupAddress,
    required this.dropoffLat,
    required this.dropoffLng,
    this.dropoffAddress,
    this.estimatedDistance,
    this.estimatedDuration,
    this.actualDistance,
    this.actualDuration,
    this.passengerOfferedFare,
    this.viewsCount = 0,
    this.offersCount = 0,
    this.acceptedOfferId,
    required this.baseFare,
    this.distanceFare = 0.0,
    this.timeFare = 0.0,
    this.surgeFare = 0.0,
    this.discount = 0.0,
    required this.totalFare,
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    required this.requestedAt,
    this.driverAssignedAt,
    this.driverArrivedAt,
    this.tripStartedAt,
    this.tripEndedAt,
    this.passengerRating,
    this.passengerReview,
    this.driverRating,
    this.driverReview,
    this.cancellationReason,
    this.cancellationFee = 0.0,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      passengerId: json['passenger_id'],
      driverId: json['driver_id'],
      status: json['status'],
      pickupLat: (json['pickup_lat'] as num).toDouble(),
      pickupLng: (json['pickup_lng'] as num).toDouble(),
      pickupAddress: json['pickup_address'],
      dropoffLat: (json['dropoff_lat'] as num).toDouble(),
      dropoffLng: (json['dropoff_lng'] as num).toDouble(),
      dropoffAddress: json['dropoff_address'],
      estimatedDistance: json['estimated_distance'] != null 
          ? (json['estimated_distance'] as num).toDouble() 
          : null,
      estimatedDuration: json['estimated_duration'],
      actualDistance: json['actual_distance'] != null 
          ? (json['actual_distance'] as num).toDouble() 
          : null,
      actualDuration: json['actual_duration'],
      passengerOfferedFare: json['passenger_offered_fare'] != null 
          ? (json['passenger_offered_fare'] as num).toDouble() 
          : null,
      viewsCount: json['views_count'] ?? 0,
      offersCount: json['offers_count'] ?? 0,
      acceptedOfferId: json['accepted_offer_id'],
      baseFare: (json['base_fare'] as num).toDouble(),
      distanceFare: (json['distance_fare'] as num?)?.toDouble() ?? 0.0,
      timeFare: (json['time_fare'] as num?)?.toDouble() ?? 0.0,
      surgeFare: (json['surge_fare'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      totalFare: (json['total_fare'] as num).toDouble(),
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'] ?? 'pending',
      requestedAt: DateTime.parse(json['requested_at']),
      driverAssignedAt: json['driver_assigned_at'] != null 
          ? DateTime.parse(json['driver_assigned_at']) 
          : null,
      driverArrivedAt: json['driver_arrived_at'] != null 
          ? DateTime.parse(json['driver_arrived_at']) 
          : null,
      tripStartedAt: json['trip_started_at'] != null 
          ? DateTime.parse(json['trip_started_at']) 
          : null,
      tripEndedAt: json['trip_ended_at'] != null 
          ? DateTime.parse(json['trip_ended_at']) 
          : null,
      passengerRating: json['passenger_rating'] != null 
          ? (json['passenger_rating'] as num).toDouble() 
          : null,
      passengerReview: json['passenger_review'],
      driverRating: json['driver_rating'] != null 
          ? (json['driver_rating'] as num).toDouble() 
          : null,
      driverReview: json['driver_review'],
      cancellationReason: json['cancellation_reason'],
      cancellationFee: (json['cancellation_fee'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passenger_id': passengerId,
      'driver_id': driverId,
      'status': status,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'pickup_address': pickupAddress,
      'dropoff_lat': dropoffLat,
      'dropoff_lng': dropoffLng,
      'dropoff_address': dropoffAddress,
      'estimated_distance': estimatedDistance,
      'estimated_duration': estimatedDuration,
      'actual_distance': actualDistance,
      'actual_duration': actualDuration,
      'passenger_offered_fare': passengerOfferedFare,
      'views_count': viewsCount,
      'offers_count': offersCount,
      'accepted_offer_id': acceptedOfferId,
      'base_fare': baseFare,
      'distance_fare': distanceFare,
      'time_fare': timeFare,
      'surge_fare': surgeFare,
      'discount': discount,
      'total_fare': totalFare,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'requested_at': requestedAt.toIso8601String(),
      'driver_assigned_at': driverAssignedAt?.toIso8601String(),
      'driver_arrived_at': driverArrivedAt?.toIso8601String(),
      'trip_started_at': tripStartedAt?.toIso8601String(),
      'trip_ended_at': tripEndedAt?.toIso8601String(),
      'passenger_rating': passengerRating,
      'passenger_review': passengerReview,
      'driver_rating': driverRating,
      'driver_review': driverReview,
      'cancellation_reason': cancellationReason,
      'cancellation_fee': cancellationFee,
    };
  }
}

// Driver Offer Model
class DriverOffer {
  final int id;
  final int tripId;
  final int driverId;
  final double offeredFare;
  final String? message;
  final String status;
  final int? estimatedArrival;
  final double? distanceToPickup;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime? expiresAt;

  DriverOffer({
    required this.id,
    required this.tripId,
    required this.driverId,
    required this.offeredFare,
    this.message,
    this.status = 'pending',
    this.estimatedArrival,
    this.distanceToPickup,
    required this.createdAt,
    this.respondedAt,
    this.expiresAt,
  });

  factory DriverOffer.fromJson(Map<String, dynamic> json) {
    return DriverOffer(
      id: json['id'],
      tripId: json['trip_id'],
      driverId: json['driver_id'],
      offeredFare: (json['offered_fare'] as num).toDouble(),
      message: json['message'],
      status: json['status'] ?? 'pending',
      estimatedArrival: json['estimated_arrival'],
      distanceToPickup: json['distance_to_pickup'] != null 
          ? (json['distance_to_pickup'] as num).toDouble() 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      respondedAt: json['responded_at'] != null 
          ? DateTime.parse(json['responded_at']) 
          : null,
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'driver_id': driverId,
      'offered_fare': offeredFare,
      'message': message,
      'status': status,
      'estimated_arrival': estimatedArrival,
      'distance_to_pickup': distanceToPickup,
      'created_at': createdAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}

// Wallet Model
class Wallet {
  final int id;
  final int userId;
  final double balance;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    this.currency = 'EGP',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      userId: json['user_id'],
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] ?? 'EGP',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'balance': balance,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Wallet copyWith({
    int? id,
    int? userId,
    double? balance,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Saved Location Model
class SavedLocation {
  final int id;
  final int userId;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final String locationType;
  final bool isDefault;
  final DateTime createdAt;

  SavedLocation({
    required this.id,
    required this.userId,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    this.locationType = 'other',
    this.isDefault = false,
    required this.createdAt,
  });

  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      address: json['address'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      locationType: json['location_type'] ?? 'other',
      isDefault: json['is_default'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'location_type': locationType,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Promo Code Model
class PromoCode {
  final int id;
  final String code;
  final String? description;
  final String discountType;
  final double discountValue;
  final double? maxDiscount;
  final double? minTripAmount;
  final int? usageLimit;
  final int usagePerUser;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final DateTime createdAt;

  PromoCode({
    required this.id,
    required this.code,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.maxDiscount,
    this.minTripAmount,
    this.usageLimit,
    this.usagePerUser = 1,
    required this.validFrom,
    required this.validUntil,
    this.isActive = true,
    required this.createdAt,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id'],
      code: json['code'],
      description: json['description'],
      discountType: json['discount_type'],
      discountValue: (json['discount_value'] as num).toDouble(),
      maxDiscount: json['max_discount'] != null 
          ? (json['max_discount'] as num).toDouble() 
          : null,
      minTripAmount: json['min_trip_amount'] != null 
          ? (json['min_trip_amount'] as num).toDouble() 
          : null,
      usageLimit: json['usage_limit'],
      usagePerUser: json['usage_per_user'] ?? 1,
      validFrom: DateTime.parse(json['valid_from']),
      validUntil: DateTime.parse(json['valid_until']),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'discount_type': discountType,
      'discount_value': discountValue,
      'max_discount': maxDiscount,
      'min_trip_amount': minTripAmount,
      'usage_limit': usageLimit,
      'usage_per_user': usagePerUser,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
