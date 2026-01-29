# TukTuky - Ride-Hailing Platform Architecture

## Project Overview

TukTuky is a comprehensive ride-hailing platform designed for TukTuk (توكتوك) transportation in Egypt. The platform consists of three main applications:

1. **Passenger App** (Flutter) - iOS/Android
2. **Driver App** (Flutter) - iOS/Android
3. **Admin Dashboard** (Web) - React/TypeScript

## Technology Stack

### Frontend
- **Passenger & Driver Apps**: Flutter 3.x with Dart
- **Admin Dashboard**: React 18 + TypeScript + TailwindCSS
- **State Management**: Riverpod (Flutter), Redux (Web)
- **Maps**: Google Maps SDK
- **Real-time**: Supabase Realtime
- **Push Notifications**: Firebase Cloud Messaging (FCM)

### Backend
- **Database**: Supabase PostgreSQL (30 tables)
- **Authentication**: Supabase Auth (OAuth + Phone OTP)
- **Real-time**: Supabase Realtime subscriptions
- **File Storage**: Supabase Storage
- **API**: Supabase REST API + Custom Node.js/FastAPI backend

### Payment Integration
- Paymob
- Fawry
- Vodafone Cash
- Orange Cash

## Project Structure

```
TukTuky/
├── passenger_app/              # Flutter Passenger Application
│   ├── lib/
│   │   ├── main.dart
│   │   ├── config/
│   │   ├── models/
│   │   ├── providers/          # Riverpod state management
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── services/           # API & Supabase services
│   │   └── utils/
│   ├── pubspec.yaml
│   └── README.md
│
├── driver_app/                 # Flutter Driver Application
│   ├── lib/
│   │   ├── main.dart
│   │   ├── config/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── services/
│   │   └── utils/
│   ├── pubspec.yaml
│   └── README.md
│
├── dashboard/                  # Admin Dashboard (Web)
│   ├── src/
│   │   ├── main.tsx
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   ├── store/
│   │   └── utils/
│   ├── package.json
│   └── README.md
│
├── backend/                    # Backend Services (Optional)
│   ├── api/                    # FastAPI/Node.js API
│   ├── functions/              # Supabase Edge Functions
│   └── migrations/             # Database migrations
│
├── database/
│   ├── schema.sql              # Complete PostgreSQL schema
│   ├── seed.sql                # Sample data
│   └── migrations/
│
└── docs/
    ├── API_DOCUMENTATION.md
    ├── DATABASE_SCHEMA.md
    ├── SETUP_GUIDE.md
    └── DEPLOYMENT.md
```

## Database Schema Overview

### Core Tables
- **users**: All user accounts (passengers, drivers, admins)
- **drivers**: Extended driver profiles with KYC status
- **trips**: Main trip records with bidding system
- **driver_offers**: InDriver-style price offers

### Payment & Wallet
- **wallets**: User/driver wallet balances
- **wallet_transactions**: Complete transaction history
- **gateway_transactions**: External payment gateway records
- **promo_codes**: Discount codes and promotions

### Safety & Support
- **sos_alerts**: Emergency alerts during rides
- **driver_incidents**: Bad driver behavior reports
- **support_tickets**: Customer support cases
- **emergency_contacts**: User's emergency contacts

### Additional Features
- **subscription_plans**: Driver subscription tiers
- **commission_tiers**: Dynamic commission rates
- **saved_locations**: User's favorite places
- **scheduled_trips**: Pre-booked rides
- **notifications**: Push notification history
- **ratings**: Detailed rating records

## Key Features

### Passenger App
1. **Authentication**
   - Social login (Google, Apple, Facebook)
   - Phone OTP verification
   - Language selection (Arabic/English)

2. **Trip Booking**
   - Map-based pickup/dropoff selection
   - InDriver-style bidding
   - Quick ride option
   - Scheduled trips

3. **Real-time Features**
   - Live driver tracking
   - Driver offer notifications
   - Trip status updates
   - SOS button

4. **Payments**
   - Multiple payment methods (Cash, Wallet, Card)
   - Wallet top-up
   - Promo code application
   - Transaction history

5. **User Profile**
   - Profile management
   - Saved locations
   - Emergency contacts
   - Trip history
   - Ratings and reviews

### Driver App
1. **Authentication & KYC**
   - Document verification
   - Vehicle registration
   - Background checks

2. **Trip Management**
   - View trip requests
   - Send price offers
   - Accept/reject trips
   - Real-time navigation

3. **Earnings**
   - Wallet management
   - Commission tracking
   - Subscription plans
   - Payout history

4. **Safety**
   - SOS alerts
   - Incident reporting
   - Ratings and reviews

### Admin Dashboard
1. **Analytics**
   - Real-time metrics
   - Revenue tracking
   - Driver/passenger statistics

2. **User Management**
   - Driver KYC verification
   - User blocking/unblocking
   - Incident management

3. **Financial Management**
   - Commission settings
   - Promo code management
   - Payment gateway configuration

4. **Support**
   - Ticket management
   - SOS alert handling
   - Driver incident review

## API Endpoints Structure

### Authentication
- `POST /auth/register` - User registration
- `POST /auth/phone-otp` - Send OTP
- `POST /auth/verify-otp` - Verify OTP
- `POST /auth/social-login` - Social login

### Trips
- `POST /trips` - Create trip request
- `GET /trips/:id` - Get trip details
- `GET /trips` - List user trips
- `PUT /trips/:id/status` - Update trip status
- `POST /trips/:id/cancel` - Cancel trip

### Driver Offers
- `POST /driver-offers` - Create offer
- `GET /trips/:id/offers` - Get trip offers
- `PUT /driver-offers/:id/accept` - Accept offer
- `PUT /driver-offers/:id/reject` - Reject offer

### Payments
- `POST /payments/process` - Process payment
- `GET /wallet` - Get wallet balance
- `POST /wallet/topup` - Top-up wallet
- `GET /transactions` - Get transaction history

### Ratings
- `POST /ratings` - Submit rating
- `GET /ratings/:userId` - Get user ratings

## Real-time Features

### Supabase Realtime Subscriptions
1. **Trip Updates**: Status changes, driver assignment
2. **Driver Offers**: New offers, offer updates
3. **Location Tracking**: Driver location updates
4. **Notifications**: Push notification delivery
5. **Chat**: Support ticket messages

## Security Considerations

1. **Authentication**: Supabase Auth with JWT tokens
2. **Authorization**: Row-level security (RLS) policies
3. **Data Encryption**: HTTPS, encrypted sensitive fields
4. **Payment Security**: PCI compliance, tokenization
5. **Location Privacy**: Anonymized tracking data
6. **KYC Verification**: Document validation

## Deployment Strategy

### Development
- Local development with Supabase local stack
- Firebase emulator for notifications
- Google Maps API key for development

### Staging
- Supabase staging project
- Firebase staging project
- Payment gateway sandbox

### Production
- Supabase production project
- Firebase production project
- Payment gateway production
- CDN for static assets
- Load balancing for API

## Performance Optimization

1. **Caching**: Redis for frequently accessed data
2. **Pagination**: Implement cursor-based pagination
3. **Image Optimization**: Compress and resize images
4. **Database Indexing**: Strategic indexes on frequently queried columns
5. **API Rate Limiting**: Prevent abuse
6. **Offline Support**: Local caching for Flutter apps

## Monitoring & Analytics

1. **Error Tracking**: Sentry integration
2. **Performance Monitoring**: Firebase Performance
3. **Analytics**: Google Analytics, Mixpanel
4. **Logs**: Centralized logging with ELK stack
5. **Alerts**: Real-time alerts for critical issues

## Development Timeline

- **Phase 1** (Weeks 1-2): Project setup, database schema
- **Phase 2** (Weeks 3-4): Authentication, basic UI
- **Phase 3** (Weeks 5-6): Trip booking, bidding system
- **Phase 4** (Weeks 7-8): Real-time features, tracking
- **Phase 5** (Weeks 9-10): Payments, wallet
- **Phase 6** (Weeks 11-12): Admin dashboard
- **Phase 7** (Weeks 13-14): Testing, optimization
- **Phase 8** (Week 15): Deployment, launch

## Next Steps

1. Initialize Flutter projects for passenger and driver apps
2. Set up Supabase project and database
3. Create API documentation
4. Set up CI/CD pipelines
5. Begin development on authentication layer
