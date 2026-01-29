# TukTuky API Documentation

## Base URL
```
https://your-supabase-url/rest/v1
```

## Authentication
All requests require authentication headers:
```
Authorization: Bearer {jwt_token}
Content-Type: application/json
```

## Response Format
All responses follow this format:
```json
{
  "success": true,
  "data": {},
  "message": "Success message",
  "error": null
}
```

---

## Authentication Endpoints

### 1. Social Login
**Endpoint**: `POST /auth/social-login`

**Request**:
```json
{
  "provider": "google|apple|facebook",
  "token": "provider_token",
  "language": "ar|en"
}
```

**Response**:
```json
{
  "user": {
    "id": 1,
    "open_id": "google_12345",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "passenger"
  },
  "jwt_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

### 2. Phone OTP Request
**Endpoint**: `POST /auth/phone-otp`

**Request**:
```json
{
  "phone": "+201234567890"
}
```

**Response**:
```json
{
  "message": "OTP sent successfully",
  "session_id": "session_12345"
}
```

### 3. Verify OTP
**Endpoint**: `POST /auth/verify-otp`

**Request**:
```json
{
  "phone": "+201234567890",
  "otp": "123456",
  "session_id": "session_12345"
}
```

**Response**:
```json
{
  "user": {
    "id": 1,
    "phone": "+201234567890",
    "role": "passenger"
  },
  "jwt_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

---

## User Endpoints

### 1. Get Current User
**Endpoint**: `GET /users/me`

**Response**:
```json
{
  "id": 1,
  "open_id": "google_12345",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+201234567890",
  "role": "passenger",
  "language": "ar",
  "referral_code": "JOHN123",
  "profile_completeness": 75,
  "created_at": "2026-01-15T10:30:00Z"
}
```

### 2. Update User Profile
**Endpoint**: `PUT /users/{id}`

**Request**:
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "language": "ar"
}
```

### 3. Get User Referral Info
**Endpoint**: `GET /users/{id}/referral`

**Response**:
```json
{
  "referral_code": "JOHN123",
  "referral_earnings": 250.00,
  "referrals_count": 5,
  "referrals": [
    {
      "id": 2,
      "name": "Jane Doe",
      "referred_at": "2026-01-10T10:30:00Z"
    }
  ]
}
```

---

## Trip Endpoints

### 1. Create Trip Request
**Endpoint**: `POST /trips`

**Request**:
```json
{
  "pickup_lat": 30.0444,
  "pickup_lng": 31.2357,
  "pickup_address": "Cairo, Egypt",
  "dropoff_lat": 30.0500,
  "dropoff_lng": 31.2400,
  "dropoff_address": "Giza, Egypt",
  "passenger_offered_fare": 50.00,
  "payment_method": "cash|wallet|card"
}
```

**Response**:
```json
{
  "id": 1,
  "passenger_id": 1,
  "status": "requested",
  "pickup_lat": 30.0444,
  "pickup_lng": 31.2357,
  "pickup_address": "Cairo, Egypt",
  "dropoff_lat": 30.0500,
  "dropoff_lng": 31.2400,
  "dropoff_address": "Giza, Egypt",
  "estimated_distance": 5.2,
  "estimated_duration": 15,
  "passenger_offered_fare": 50.00,
  "base_fare": 10.00,
  "total_fare": 50.00,
  "payment_method": "cash",
  "requested_at": "2026-01-29T10:30:00Z"
}
```

### 2. Get Trip Details
**Endpoint**: `GET /trips/{id}`

**Response**:
```json
{
  "id": 1,
  "passenger_id": 1,
  "driver_id": 5,
  "status": "in_trip",
  "pickup_lat": 30.0444,
  "pickup_lng": 31.2357,
  "dropoff_lat": 30.0500,
  "dropoff_lng": 31.2400,
  "estimated_distance": 5.2,
  "estimated_duration": 15,
  "actual_distance": 5.1,
  "actual_duration": 14,
  "total_fare": 50.00,
  "driver": {
    "id": 5,
    "user_id": 3,
    "name": "Ahmed Hassan",
    "rating": 4.8,
    "vehicle_plate": "ABC123",
    "current_lat": 30.0460,
    "current_lng": 31.2370
  }
}
```

### 3. List User Trips
**Endpoint**: `GET /trips?limit=10&offset=0`

**Response**:
```json
{
  "trips": [
    {
      "id": 1,
      "status": "completed",
      "pickup_address": "Cairo",
      "dropoff_address": "Giza",
      "total_fare": 50.00,
      "completed_at": "2026-01-29T10:30:00Z"
    }
  ],
  "total": 15,
  "limit": 10,
  "offset": 0
}
```

### 4. Cancel Trip
**Endpoint**: `PUT /trips/{id}/cancel`

**Request**:
```json
{
  "reason": "Driver is too far"
}
```

### 5. Update Trip Status
**Endpoint**: `PUT /trips/{id}/status`

**Request**:
```json
{
  "status": "driver_arrived|in_trip|completed"
}
```

---

## Driver Offers Endpoints

### 1. Get Trip Offers
**Endpoint**: `GET /trips/{id}/offers`

**Response**:
```json
{
  "offers": [
    {
      "id": 1,
      "driver_id": 5,
      "offered_fare": 45.00,
      "message": "I can pick you up in 5 minutes",
      "estimated_arrival": 5,
      "distance_to_pickup": 2.3,
      "status": "pending",
      "driver": {
        "id": 5,
        "name": "Ahmed Hassan",
        "rating": 4.8,
        "vehicle_plate": "ABC123"
      }
    }
  ],
  "total": 3
}
```

### 2. Accept Offer
**Endpoint**: `POST /driver-offers/{id}/accept`

**Response**:
```json
{
  "message": "Offer accepted",
  "trip_id": 1,
  "driver_id": 5
}
```

### 3. Reject Offer
**Endpoint**: `POST /driver-offers/{id}/reject`

**Response**:
```json
{
  "message": "Offer rejected"
}
```

---

## Wallet Endpoints

### 1. Get Wallet Balance
**Endpoint**: `GET /wallet`

**Response**:
```json
{
  "id": 1,
  "user_id": 1,
  "balance": 250.00,
  "currency": "EGP",
  "updated_at": "2026-01-29T10:30:00Z"
}
```

### 2. Top-up Wallet
**Endpoint**: `POST /wallet/topup`

**Request**:
```json
{
  "amount": 100.00,
  "payment_method": "card|mobile_wallet",
  "gateway": "paymob|fawry"
}
```

**Response**:
```json
{
  "transaction_id": "txn_12345",
  "amount": 100.00,
  "status": "pending",
  "payment_url": "https://payment.gateway.com/pay/txn_12345"
}
```

### 3. Get Transaction History
**Endpoint**: `GET /wallet/transactions?limit=10&offset=0`

**Response**:
```json
{
  "transactions": [
    {
      "id": 1,
      "type": "topup",
      "amount": 100.00,
      "balance_before": 150.00,
      "balance_after": 250.00,
      "description": "Wallet top-up",
      "created_at": "2026-01-29T10:30:00Z"
    }
  ],
  "total": 25
}
```

---

## Ratings Endpoints

### 1. Submit Rating
**Endpoint**: `POST /ratings`

**Request**:
```json
{
  "trip_id": 1,
  "rated_id": 3,
  "rating": 4.5,
  "review": "Great driver, very professional",
  "tags": ["clean", "polite", "safe"]
}
```

### 2. Get User Ratings
**Endpoint**: `GET /users/{id}/ratings`

**Response**:
```json
{
  "average_rating": 4.8,
  "total_ratings": 125,
  "ratings": [
    {
      "id": 1,
      "rating": 5.0,
      "review": "Excellent service",
      "rater": {
        "name": "John Doe"
      },
      "created_at": "2026-01-29T10:30:00Z"
    }
  ]
}
```

---

## Promo Code Endpoints

### 1. Apply Promo Code
**Endpoint**: `POST /promo-codes/apply`

**Request**:
```json
{
  "code": "SAVE50",
  "trip_id": 1
}
```

**Response**:
```json
{
  "code": "SAVE50",
  "discount_type": "percentage",
  "discount_value": 20,
  "discount_amount": 10.00,
  "new_total": 40.00
}
```

### 2. Get Available Promo Codes
**Endpoint**: `GET /promo-codes`

**Response**:
```json
{
  "codes": [
    {
      "code": "SAVE50",
      "description": "Save 20% on your next ride",
      "discount_type": "percentage",
      "discount_value": 20,
      "valid_until": "2026-02-28T23:59:59Z"
    }
  ]
}
```

---

## Saved Locations Endpoints

### 1. Create Saved Location
**Endpoint**: `POST /saved-locations`

**Request**:
```json
{
  "name": "Home",
  "address": "123 Main St, Cairo",
  "latitude": 30.0444,
  "longitude": 31.2357,
  "location_type": "home|work|other",
  "is_default": true
}
```

### 2. Get Saved Locations
**Endpoint**: `GET /saved-locations`

**Response**:
```json
{
  "locations": [
    {
      "id": 1,
      "name": "Home",
      "address": "123 Main St, Cairo",
      "latitude": 30.0444,
      "longitude": 31.2357,
      "location_type": "home",
      "is_default": true
    }
  ]
}
```

### 3. Update Saved Location
**Endpoint**: `PUT /saved-locations/{id}`

**Request**:
```json
{
  "name": "Home",
  "address": "456 New St, Cairo",
  "latitude": 30.0500,
  "longitude": 31.2400,
  "is_default": true
}
```

### 4. Delete Saved Location
**Endpoint**: `DELETE /saved-locations/{id}`

---

## Support Tickets Endpoints

### 1. Create Support Ticket
**Endpoint**: `POST /support-tickets`

**Request**:
```json
{
  "category": "payment|driver|app_issue|lost_item|safety|other",
  "subject": "Payment issue",
  "description": "I was charged twice for my trip",
  "trip_id": 1
}
```

### 2. Get Support Tickets
**Endpoint**: `GET /support-tickets?limit=10&offset=0`

**Response**:
```json
{
  "tickets": [
    {
      "id": 1,
      "category": "payment",
      "subject": "Payment issue",
      "status": "open",
      "priority": "high",
      "created_at": "2026-01-29T10:30:00Z"
    }
  ]
}
```

### 3. Get Ticket Details
**Endpoint**: `GET /support-tickets/{id}`

**Response**:
```json
{
  "id": 1,
  "category": "payment",
  "subject": "Payment issue",
  "description": "I was charged twice for my trip",
  "status": "in_progress",
  "priority": "high",
  "messages": [
    {
      "id": 1,
      "sender_id": 1,
      "message": "I was charged twice",
      "is_staff": false,
      "created_at": "2026-01-29T10:30:00Z"
    }
  ]
}
```

### 4. Add Message to Ticket
**Endpoint**: `POST /support-tickets/{id}/messages`

**Request**:
```json
{
  "message": "Thank you for reporting this issue"
}
```

---

## Emergency Contacts Endpoints

### 1. Add Emergency Contact
**Endpoint**: `POST /emergency-contacts`

**Request**:
```json
{
  "name": "Mom",
  "phone": "+201234567890",
  "relationship": "Mother",
  "is_primary": true
}
```

### 2. Get Emergency Contacts
**Endpoint**: `GET /emergency-contacts`

**Response**:
```json
{
  "contacts": [
    {
      "id": 1,
      "name": "Mom",
      "phone": "+201234567890",
      "relationship": "Mother",
      "is_primary": true
    }
  ]
}
```

### 3. Update Emergency Contact
**Endpoint**: `PUT /emergency-contacts/{id}`

### 4. Delete Emergency Contact
**Endpoint**: `DELETE /emergency-contacts/{id}`

---

## SOS Alerts Endpoints

### 1. Trigger SOS Alert
**Endpoint**: `POST /sos-alerts`

**Request**:
```json
{
  "trip_id": 1,
  "latitude": 30.0444,
  "longitude": 31.2357
}
```

**Response**:
```json
{
  "id": 1,
  "trip_id": 1,
  "status": "active",
  "contacts_notified": [1, 2, 3],
  "created_at": "2026-01-29T10:30:00Z"
}
```

### 2. Get SOS Alert Status
**Endpoint**: `GET /sos-alerts/{id}`

---

## Scheduled Trips Endpoints

### 1. Create Scheduled Trip
**Endpoint**: `POST /scheduled-trips`

**Request**:
```json
{
  "scheduled_at": "2026-02-15T10:30:00Z",
  "pickup_lat": 30.0444,
  "pickup_lng": 31.2357,
  "pickup_address": "Cairo",
  "dropoff_lat": 30.0500,
  "dropoff_lng": 31.2400,
  "dropoff_address": "Giza",
  "notes": "Please arrive 5 minutes early"
}
```

### 2. Get Scheduled Trips
**Endpoint**: `GET /scheduled-trips`

**Response**:
```json
{
  "trips": [
    {
      "id": 1,
      "scheduled_at": "2026-02-15T10:30:00Z",
      "pickup_address": "Cairo",
      "dropoff_address": "Giza",
      "status": "scheduled",
      "estimated_fare": 50.00
    }
  ]
}
```

### 3. Cancel Scheduled Trip
**Endpoint**: `DELETE /scheduled-trips/{id}`

---

## Notifications Endpoints

### 1. Get Notifications
**Endpoint**: `GET /notifications?limit=10&offset=0`

**Response**:
```json
{
  "notifications": [
    {
      "id": 1,
      "title": "Driver Arrived",
      "body": "Your driver Ahmed has arrived",
      "type": "trip",
      "is_read": false,
      "created_at": "2026-01-29T10:30:00Z"
    }
  ]
}
```

### 2. Mark Notification as Read
**Endpoint**: `PUT /notifications/{id}/read`

### 3. Mark All as Read
**Endpoint**: `PUT /notifications/read-all`

---

## Error Codes

| Code | Message | Description |
|------|---------|-------------|
| 400 | Bad Request | Invalid request parameters |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | User doesn't have permission |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource already exists |
| 422 | Unprocessable Entity | Validation error |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |
| 503 | Service Unavailable | Service temporarily unavailable |

---

## Rate Limiting

- **Limit**: 100 requests per minute per user
- **Headers**: 
  - `X-RateLimit-Limit`: 100
  - `X-RateLimit-Remaining`: 95
  - `X-RateLimit-Reset`: 1643450400

---

## Pagination

All list endpoints support pagination:
- `limit`: Number of items per page (default: 10, max: 100)
- `offset`: Number of items to skip (default: 0)

Example: `GET /trips?limit=20&offset=40`

---

## Filtering

List endpoints support filtering:

Example: `GET /trips?status=completed&payment_method=cash`

---

## Sorting

List endpoints support sorting:

Example: `GET /trips?sort=requested_at&order=desc`

---

## Real-time Subscriptions

Subscribe to real-time updates using WebSocket:

```dart
final subscription = supabase
  .from('trips')
  .on(RealtimeEventTypes.all, (payload) {
    print('Trip updated: ${payload.newRecord}');
  })
  .subscribe();
```

---

## Webhook Events

Subscribe to webhook events for:
- Trip status changes
- Payment confirmations
- Driver online/offline
- New offers received
- Ratings submitted

Configure webhooks in dashboard settings.
