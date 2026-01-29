# TukTuky Passenger App - Module Analysis

## Database Schema Overview

The database consists of **30 tables** organized into several functional modules:

### Core Tables (Foundation)
1. **users** - Base user accounts (passengers, drivers, admins)
2. **drivers** - Extended driver profiles
3. **wallets** - User wallet balances
4. **fcm_tokens** - Push notification tokens

### Trip Management Module
- **trips** - Main trip records with InDriver-style bidding
- **driver_offers** - Driver price offers for trips
- **trip_views** - Track which drivers viewed trip requests
- **scheduled_trips** - Pre-booked future rides
- **trip_tracking** - GPS route recording during trips

### Payment & Financial Module
- **pricing_config** - Base fare, per km/minute rates
- **zones** - Geographic areas with surge pricing
- **commission_tiers** - Dynamic commission rates
- **wallet_transactions** - Wallet history (topup, debit, refund, etc.)
- **gateway_transactions** - Payment gateway records (Paymob, Fawry, etc.)
- **promo_codes** - Discount codes and promotions
- **promo_usage** - Track promo code usage

### Driver Verification Module
- **driver_documents** - Driver KYC documents (ID, license, etc.)
- **vehicle_documents** - Vehicle documents (registration, insurance, etc.)
- **driver_subscriptions** - Driver subscription plans
- **subscription_plans** - Available subscription tiers

### Safety & Support Module
- **emergency_contacts** - User emergency contacts
- **sos_alerts** - Emergency alerts during rides
- **driver_incidents** - Report bad driver behavior
- **driver_blacklist** - Permanently banned drivers
- **support_tickets** - Customer support cases
- **ticket_messages** - Support ticket chat messages

### User Features Module
- **saved_locations** - Favorite places (home, work, etc.)
- **ratings** - Detailed rating records
- **notifications** - Push notification history

### Admin Module
- **audit_logs** - System audit trail

---

## Module Dependency Analysis

### Level 0: Foundation (No Dependencies)
These modules are independent and can work standalone:

1. **User Profile Module**
   - Tables: `users`, `fcm_tokens`
   - Features: View/edit profile, language settings, profile photo
   - Status: Login/Register already working ✓

### Level 1: Depends on Users Only

2. **Saved Locations Module**
   - Tables: `saved_locations`
   - Dependencies: `users`
   - Features: Add/edit/delete favorite locations (Home, Work, Other)
   - UI: List view, add location screen, map picker
   - Backend: CRUD operations on saved_locations table

3. **Emergency Contacts Module**
   - Tables: `emergency_contacts`
   - Dependencies: `users`
   - Features: Add/edit/delete emergency contacts
   - UI: Contact list, add/edit contact form
   - Backend: CRUD operations on emergency_contacts table

4. **Wallet Module (Basic)**
   - Tables: `wallets`, `wallet_transactions`
   - Dependencies: `users`
   - Features: View balance, transaction history, topup
   - UI: Wallet screen, transaction list, topup screen
   - Backend: Wallet balance display, transaction history

### Level 2: Depends on Level 0-1

5. **Trip Booking Module** (Core Feature)
   - Tables: `trips`, `driver_offers`, `trip_views`, `pricing_config`, `zones`
   - Dependencies: `users`, `saved_locations` (optional)
   - Features: Request trip, view offers, accept offer, track trip
   - UI: Map screen, location picker, bidding screen, tracking screen
   - Backend: Trip creation, offer management, real-time updates

6. **Scheduled Trips Module**
   - Tables: `scheduled_trips`
   - Dependencies: `users`, `trips`
   - Features: Schedule future rides, view scheduled trips
   - UI: Schedule screen, calendar picker, scheduled trips list
   - Backend: Create/cancel scheduled trips

7. **Promo Codes Module**
   - Tables: `promo_codes`, `promo_usage`
   - Dependencies: `users`, `trips`
   - Features: Enter promo code, view discounts
   - UI: Promo code input, applied discounts display
   - Backend: Validate and apply promo codes

### Level 3: Depends on Level 0-2

8. **Payment Module**
   - Tables: `gateway_transactions`, `wallet_transactions`
   - Dependencies: `users`, `wallets`, `trips`
   - Features: Pay for trips, payment methods, payment history
   - UI: Payment method selector, payment confirmation
   - Backend: Payment gateway integration (Paymob, Fawry)

9. **Rating & Review Module**
   - Tables: `ratings`
   - Dependencies: `users`, `trips`
   - Features: Rate driver, write review, view ratings
   - UI: Rating screen, review form
   - Backend: Submit ratings, calculate average ratings

10. **Trip History Module**
    - Tables: `trips`, `ratings`
    - Dependencies: `users`, `trips`
    - Features: View past trips, trip details, receipts
    - UI: Trip history list, trip detail screen
    - Backend: Fetch trip history with filters

### Level 4: Advanced Features

11. **SOS & Safety Module**
    - Tables: `sos_alerts`, `emergency_contacts`
    - Dependencies: `users`, `trips`, `emergency_contacts`
    - Features: Trigger SOS, notify contacts, track location
    - UI: SOS button, alert confirmation, contact notification
    - Backend: Create SOS alert, send notifications

12. **Support Tickets Module**
    - Tables: `support_tickets`, `ticket_messages`
    - Dependencies: `users`, `trips` (optional)
    - Features: Create ticket, chat with support, view ticket status
    - UI: Support screen, ticket list, chat interface
    - Backend: Ticket CRUD, message sending

13. **Notifications Module**
    - Tables: `notifications`, `fcm_tokens`
    - Dependencies: `users`, all other modules
    - Features: View notifications, notification settings
    - UI: Notification list, notification detail
    - Backend: Fetch notifications, mark as read

---

## Recommended Implementation Order

Based on dependency analysis and user value, here's the recommended order:

### Phase 1: Foundation ✓
- [x] User Authentication (Login/Register) - **Already Working**

### Phase 2: User Profile Features
- [ ] **Saved Locations Module** ← **NEXT MODULE TO IMPLEMENT**
- [ ] Emergency Contacts Module
- [ ] User Profile Edit Module

### Phase 3: Core Trip Features
- [ ] Trip Booking Module (with bidding)
- [ ] Trip Tracking Module
- [ ] Trip History Module

### Phase 4: Financial Features
- [ ] Wallet Module (topup, balance)
- [ ] Payment Module (gateway integration)
- [ ] Promo Codes Module

### Phase 5: Post-Trip Features
- [ ] Rating & Review Module
- [ ] Scheduled Trips Module

### Phase 6: Safety & Support
- [ ] SOS & Safety Module
- [ ] Support Tickets Module
- [ ] Notifications Module

---

## Next Module: Saved Locations

**Why this module first?**
1. **No dependencies** beyond users table (which is already working)
2. **Simple CRUD operations** - good for establishing patterns
3. **Useful for trip booking** - users can quickly select saved locations
4. **Low complexity** - no real-time features, no payment integration
5. **Clear UI/UX** - list, add, edit, delete screens

**What needs to be implemented:**
1. **UI Screens:**
   - Saved Locations List Screen
   - Add/Edit Location Screen
   - Map Picker for selecting location
   - Location type selector (Home, Work, Other)

2. **Backend Services:**
   - Supabase service methods for CRUD operations
   - Location validation
   - Default location handling

3. **State Management:**
   - Riverpod provider for saved locations
   - Local state for form handling

4. **Database Operations:**
   - INSERT new location
   - SELECT all locations for user
   - UPDATE existing location
   - DELETE location
   - Handle is_default flag (only one default per type)

5. **Integration Points:**
   - Google Maps API for map picker
   - Places API for address autocomplete
   - Location services for current location

---

## Current App Structure Analysis

### Existing Screens (passenger_app/lib/screens/)
- ✓ auth/login_screen.dart
- ✓ auth/otp_screen.dart
- ✓ home/home_screen.dart
- ✓ profile/profile_screen.dart
- ✓ profile/saved_locations_screen.dart ← **EXISTS BUT NEEDS IMPLEMENTATION**
- ✓ profile/emergency_contacts_screen.dart
- ✓ profile/wallet_screen.dart
- ✓ trip/bidding_screen.dart
- ✓ trip/trip_booking_screen.dart
- ✓ support/support_screen.dart

### Existing Providers (passenger_app/lib/providers/)
- ✓ auth_provider.dart
- ✓ user_provider.dart
- ✓ location_provider.dart
- ✓ trip_provider.dart
- ✓ wallet_provider.dart
- ✓ otp_provider.dart
- ✓ localization_provider.dart

### Existing Services (passenger_app/lib/services/)
- ✓ supabase_service.dart
- ✓ places_service.dart
- ✓ notification_service.dart
- ✓ otp_service.dart

### Existing Models (passenger_app/lib/models/)
- ✓ models.dart (User, Trip, DriverOffer, etc.)

---

## Conclusion

The **Saved Locations Module** is the ideal next module to implement because:
- It has minimal dependencies (only users table)
- It provides immediate value to users
- It establishes patterns for other CRUD modules
- The screen already exists but needs full implementation
- It will be useful when implementing the trip booking module later

The module can be completed with:
1. Full UI implementation (list, add, edit screens)
2. Backend service methods (CRUD operations)
3. State management with Riverpod
4. Map integration for location picking
5. Testing and validation
