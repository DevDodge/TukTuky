-- ============================================================================
-- TukTuky Database Schema - Supabase PostgreSQL DDL
-- Generated: 2026-01-29
-- Total Tables: 30
-- ============================================================================

-- Enable UUID extension if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- CUSTOM TYPES (ENUMS)
-- ============================================================================

-- User roles
CREATE TYPE user_role AS ENUM ('passenger', 'driver', 'admin');

-- Language preference
CREATE TYPE language_pref AS ENUM ('ar', 'en');

-- Driver KYC status
CREATE TYPE kyc_status AS ENUM ('pending', 'approved', 'rejected');

-- Trip status
CREATE TYPE trip_status AS ENUM (
    'requested',
    'bidding',
    'searching',
    'driver_assigned',
    'driver_arrived',
    'in_trip',
    'completed',
    'cancelled_by_passenger',
    'cancelled_by_driver',
    'cancelled_timeout'
);

-- Payment method
CREATE TYPE payment_method AS ENUM ('cash', 'wallet', 'card', 'mobile_wallet');

-- Payment status
CREATE TYPE payment_status AS ENUM ('pending', 'authorized', 'captured', 'failed', 'refunded');

-- Driver offer status
CREATE TYPE offer_status AS ENUM ('pending', 'accepted', 'rejected', 'withdrawn', 'expired');

-- Document types for drivers
CREATE TYPE driver_document_type AS ENUM (
    'national_id_front',
    'national_id_back',
    'driving_license',
    'tuktuk_license',
    'criminal_record',
    'profile_photo'
);

-- Document types for vehicles
CREATE TYPE vehicle_document_type AS ENUM (
    'vehicle_registration',
    'vehicle_insurance',
    'inspection_certificate',
    'tuktuk_photo_front',
    'tuktuk_photo_back',
    'tuktuk_photo_side'
);

-- Verification status
CREATE TYPE verification_status AS ENUM ('pending', 'approved', 'rejected');

-- Subscription status
CREATE TYPE subscription_status AS ENUM ('active', 'expired', 'cancelled', 'pending_payment');

-- Wallet transaction type
CREATE TYPE transaction_type AS ENUM ('topup', 'debit', 'refund', 'promo', 'payout', 'commission', 'bonus', 'penalty');

-- Payment gateway
CREATE TYPE payment_gateway AS ENUM ('paymob', 'fawry', 'vodafone_cash', 'orange_cash');

-- Gateway payment status
CREATE TYPE gateway_status AS ENUM ('pending', 'success', 'failed', 'refunded');

-- Gateway payment method
CREATE TYPE gateway_payment_method AS ENUM ('card', 'mobile_wallet', 'cash_collect');

-- Support ticket category
CREATE TYPE ticket_category AS ENUM ('payment', 'driver', 'app_issue', 'lost_item', 'safety', 'other');

-- Ticket status
CREATE TYPE ticket_status AS ENUM ('open', 'in_progress', 'resolved', 'closed');

-- Priority level
CREATE TYPE priority_level AS ENUM ('low', 'medium', 'high', 'urgent', 'critical');

-- Promo discount type
CREATE TYPE discount_type AS ENUM ('percentage', 'fixed');

-- SOS alert status
CREATE TYPE sos_status AS ENUM ('active', 'responded', 'resolved', 'false_alarm');

-- Incident type
CREATE TYPE incident_type AS ENUM (
    'unsafe_driving',
    'harassment',
    'intoxication',
    'fraud',
    'rude_behavior',
    'route_deviation',
    'overcharging',
    'other'
);

-- Incident status
CREATE TYPE incident_status AS ENUM ('pending', 'investigating', 'resolved', 'dismissed');

-- Notification type
CREATE TYPE notification_type AS ENUM ('trip', 'payment', 'promo', 'system', 'safety', 'subscription', 'kyc');

-- Device platform
CREATE TYPE device_platform AS ENUM ('ios', 'android', 'web');

-- Saved location type
CREATE TYPE location_type AS ENUM ('home', 'work', 'other');

-- Scheduled trip status
CREATE TYPE scheduled_trip_status AS ENUM ('scheduled', 'reminded', 'searching', 'assigned', 'cancelled', 'expired', 'completed');

-- ============================================================================
-- TABLE 1: users
-- Purpose: Store all user accounts (passengers, drivers, admins)
-- ============================================================================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    open_id VARCHAR(64) NOT NULL UNIQUE, -- OAuth ID from social login (Google, Apple, Facebook)
    name TEXT,
    email VARCHAR(320),
    login_method VARCHAR(64),
    phone VARCHAR(20),
    role user_role NOT NULL DEFAULT 'passenger',
    is_blocked BOOLEAN NOT NULL DEFAULT FALSE,
    language language_pref NOT NULL DEFAULT 'ar',
    referral_code VARCHAR(20) UNIQUE,
    referred_by INTEGER REFERENCES users(id),
    referral_earnings DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    profile_completeness INTEGER NOT NULL DEFAULT 0, -- 0-100%
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_signed_in TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_referral_code ON users(referral_code);
CREATE INDEX idx_users_referred_by ON users(referred_by);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);

-- ============================================================================
-- TABLE 2: drivers
-- Purpose: Extended profile for drivers only
-- ============================================================================
CREATE TABLE drivers (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    vehicle_type VARCHAR(50) NOT NULL DEFAULT 'tuktuk',
    vehicle_plate VARCHAR(20) NOT NULL,
    vehicle_description TEXT,
    vehicle_photo TEXT, -- Storage URL
    vehicle_model VARCHAR(100),
    vehicle_year INTEGER,
    kyc_status kyc_status NOT NULL DEFAULT 'pending',
    kyc_reviewed_by INTEGER REFERENCES users(id),
    kyc_reviewed_at TIMESTAMPTZ,
    kyc_rejection_reason TEXT,
    is_online BOOLEAN NOT NULL DEFAULT FALSE,
    current_lat DECIMAL(10,7),
    current_lng DECIMAL(10,7),
    last_location_update TIMESTAMPTZ,
    total_trips INTEGER NOT NULL DEFAULT 0,
    rating DECIMAL(3,2) NOT NULL DEFAULT 0.00, -- 0.00-5.00
    total_earnings DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    available_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00, -- Can be NEGATIVE (debt)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_drivers_user_id ON drivers(user_id);
CREATE INDEX idx_drivers_kyc_status ON drivers(kyc_status);
CREATE INDEX idx_drivers_is_online ON drivers(is_online);
CREATE INDEX idx_drivers_location ON drivers(current_lat, current_lng);

-- ============================================================================
-- TABLE 3: trips
-- Purpose: Main ride/trip records with InDriver-style bidding
-- ============================================================================
CREATE TABLE trips (
    id SERIAL PRIMARY KEY,
    passenger_id INTEGER NOT NULL REFERENCES users(id),
    driver_id INTEGER REFERENCES drivers(id),
    status trip_status NOT NULL DEFAULT 'requested',
    
    -- Location (can be typed if not on Google Maps)
    pickup_lat DECIMAL(10,7) NOT NULL,
    pickup_lng DECIMAL(10,7) NOT NULL,
    pickup_address TEXT,
    dropoff_lat DECIMAL(10,7) NOT NULL,
    dropoff_lng DECIMAL(10,7) NOT NULL,
    dropoff_address TEXT,
    
    -- Distance & Duration
    estimated_distance DECIMAL(8,2), -- km
    estimated_duration INTEGER, -- minutes
    actual_distance DECIMAL(8,2),
    actual_duration INTEGER,
    
    -- InDriver Bidding
    passenger_offered_fare DECIMAL(10,2),
    views_count INTEGER NOT NULL DEFAULT 0,
    offers_count INTEGER NOT NULL DEFAULT 0,
    accepted_offer_id INTEGER, -- FK added after driver_offers table
    
    -- Fare breakdown (final after negotiation)
    base_fare DECIMAL(10,2) NOT NULL,
    distance_fare DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    time_fare DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    surge_fare DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    discount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_fare DECIMAL(10,2) NOT NULL,
    
    -- Payment
    payment_method payment_method NOT NULL,
    payment_status payment_status NOT NULL DEFAULT 'pending',
    
    -- Timestamps
    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    driver_assigned_at TIMESTAMPTZ,
    driver_arrived_at TIMESTAMPTZ,
    trip_started_at TIMESTAMPTZ,
    trip_ended_at TIMESTAMPTZ,
    
    -- Ratings (DOUBLE PRECISION for decimal stars 1.0-5.0)
    passenger_rating DOUBLE PRECISION, -- Rating from passenger to driver
    passenger_review TEXT,
    driver_rating DOUBLE PRECISION, -- Rating from driver to passenger
    driver_review TEXT,
    
    -- Cancellation
    cancellation_reason TEXT,
    cancellation_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00
);

CREATE INDEX idx_trips_passenger_id ON trips(passenger_id);
CREATE INDEX idx_trips_driver_id ON trips(driver_id);
CREATE INDEX idx_trips_status ON trips(status);
CREATE INDEX idx_trips_requested_at ON trips(requested_at);

-- ============================================================================
-- TABLE 4: driver_offers
-- Purpose: InDriver-style bidding - drivers send price offers
-- ============================================================================
CREATE TABLE driver_offers (
    id SERIAL PRIMARY KEY,
    trip_id INTEGER NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    driver_id INTEGER NOT NULL REFERENCES drivers(id),
    offered_fare DECIMAL(10,2) NOT NULL,
    message TEXT,
    status offer_status NOT NULL DEFAULT 'pending',
    estimated_arrival INTEGER, -- minutes to pickup
    distance_to_pickup DECIMAL(6,2), -- km
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    responded_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    
    UNIQUE(trip_id, driver_id) -- One offer per driver per trip
);

CREATE INDEX idx_driver_offers_trip_id ON driver_offers(trip_id);
CREATE INDEX idx_driver_offers_driver_id ON driver_offers(driver_id);
CREATE INDEX idx_driver_offers_status ON driver_offers(status);

-- Add FK for accepted_offer_id in trips
ALTER TABLE trips ADD CONSTRAINT fk_trips_accepted_offer 
    FOREIGN KEY (accepted_offer_id) REFERENCES driver_offers(id);

-- ============================================================================
-- TABLE 5: trip_views
-- Purpose: Track which drivers viewed a trip request
-- Rules: Only idle drivers, max 5 min response, ≤15 min ETA to pickup
-- ============================================================================
CREATE TABLE trip_views (
    id SERIAL PRIMARY KEY,
    trip_id INTEGER NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    driver_id INTEGER NOT NULL REFERENCES drivers(id),
    viewed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(trip_id, driver_id)
);

CREATE INDEX idx_trip_views_trip_id ON trip_views(trip_id);

-- ============================================================================
-- TABLE 6: driver_documents
-- Purpose: Individual driver document verification
-- ============================================================================
CREATE TABLE driver_documents (
    id SERIAL PRIMARY KEY,
    driver_id INTEGER NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    document_type driver_document_type NOT NULL,
    document_url TEXT NOT NULL, -- Supabase Storage URL
    verification_status verification_status NOT NULL DEFAULT 'pending',
    verified_by INTEGER REFERENCES users(id),
    verified_at TIMESTAMPTZ,
    rejection_reason TEXT,
    expires_at TIMESTAMPTZ,
    document_number VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(driver_id, document_type)
);

CREATE INDEX idx_driver_documents_driver_id ON driver_documents(driver_id);
CREATE INDEX idx_driver_documents_status ON driver_documents(verification_status);

-- ============================================================================
-- TABLE 7: vehicle_documents
-- Purpose: Tuktuk legal documents (registration, insurance)
-- ============================================================================
CREATE TABLE vehicle_documents (
    id SERIAL PRIMARY KEY,
    driver_id INTEGER NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    document_type vehicle_document_type NOT NULL,
    document_url TEXT NOT NULL,
    verification_status verification_status NOT NULL DEFAULT 'pending',
    verified_by INTEGER REFERENCES users(id),
    verified_at TIMESTAMPTZ,
    rejection_reason TEXT,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(driver_id, document_type)
);

CREATE INDEX idx_vehicle_documents_driver_id ON vehicle_documents(driver_id);
CREATE INDEX idx_vehicle_documents_status ON vehicle_documents(verification_status);

-- ============================================================================
-- TABLE 8: subscription_plans
-- Purpose: Define subscription tiers for drivers
-- ============================================================================
CREATE TABLE subscription_plans (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NOT NULL,
    description TEXT,
    description_ar TEXT,
    duration_days INTEGER NOT NULL, -- 30, 90, 365
    price DECIMAL(10,2) NOT NULL,
    features TEXT, -- JSON array: ["priority", "featured"]
    max_trips INTEGER, -- null = unlimited
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- TABLE 9: commission_tiers
-- Purpose: Dynamic tax/commission rates based on trip count
-- Example: 0-50 trips = 30%, 51-70 = 25%, 71-100 = 20%
-- ============================================================================
CREATE TABLE commission_tiers (
    id SERIAL PRIMARY KEY,
    plan_id INTEGER REFERENCES subscription_plans(id), -- null = all plans
    min_trips INTEGER NOT NULL,
    max_trips INTEGER NOT NULL,
    commission_percent DECIMAL(5,2) NOT NULL, -- e.g., 30.00 for 30%
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_commission_tiers_plan_id ON commission_tiers(plan_id);
CREATE INDEX idx_commission_tiers_range ON commission_tiers(min_trips, max_trips);

-- ============================================================================
-- TABLE 10: driver_subscriptions
-- Purpose: Track driver subscription purchases
-- NOTE: Driver can have NEGATIVE balance (debt)
-- ============================================================================
CREATE TABLE driver_subscriptions (
    id SERIAL PRIMARY KEY,
    driver_id INTEGER NOT NULL REFERENCES drivers(id),
    plan_id INTEGER NOT NULL REFERENCES subscription_plans(id),
    status subscription_status NOT NULL DEFAULT 'pending_payment',
    amount_paid DECIMAL(10,2) NOT NULL,
    payment_method payment_method NOT NULL,
    payment_reference VARCHAR(100),
    starts_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    cancelled_at TIMESTAMPTZ,
    cancellation_reason TEXT,
    trips_used INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_driver_subscriptions_driver_id ON driver_subscriptions(driver_id);
CREATE INDEX idx_driver_subscriptions_status ON driver_subscriptions(status);
CREATE INDEX idx_driver_subscriptions_expires_at ON driver_subscriptions(expires_at);

-- ============================================================================
-- TABLE 11: wallets
-- Purpose: User/driver wallet balance
-- NOTE: Balance can be NEGATIVE for drivers (debt)
-- ============================================================================
CREATE TABLE wallets (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    balance DECIMAL(12,2) NOT NULL DEFAULT 0.00, -- Can be NEGATIVE
    currency VARCHAR(3) NOT NULL DEFAULT 'EGP',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_wallets_user_id ON wallets(user_id);

-- ============================================================================
-- TABLE 12: wallet_transactions
-- Purpose: Complete history of all wallet movements
-- Includes bonus and penalty (debit) with reasons
-- ============================================================================
CREATE TABLE wallet_transactions (
    id SERIAL PRIMARY KEY,
    wallet_id INTEGER NOT NULL REFERENCES wallets(id),
    user_id INTEGER NOT NULL REFERENCES users(id),
    type transaction_type NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    balance_before DECIMAL(12,2) NOT NULL,
    balance_after DECIMAL(12,2) NOT NULL,
    trip_id INTEGER REFERENCES trips(id),
    description TEXT, -- Human-readable note / reason for bonus or penalty
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_wallet_transactions_wallet_id ON wallet_transactions(wallet_id);
CREATE INDEX idx_wallet_transactions_user_id ON wallet_transactions(user_id);
CREATE INDEX idx_wallet_transactions_type ON wallet_transactions(type);

-- ============================================================================
-- TABLE 13: gateway_transactions
-- Purpose: External payment gateway records (Paymob, Fawry, Vodafone Cash)
-- ============================================================================
CREATE TABLE gateway_transactions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    trip_id INTEGER REFERENCES trips(id),
    subscription_id INTEGER REFERENCES driver_subscriptions(id),
    gateway payment_gateway NOT NULL,
    gateway_reference VARCHAR(100),
    amount DECIMAL(10,2) NOT NULL,
    status gateway_status NOT NULL DEFAULT 'pending',
    payment_method gateway_payment_method NOT NULL,
    gateway_response TEXT, -- JSON for debugging
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_gateway_transactions_user_id ON gateway_transactions(user_id);
CREATE INDEX idx_gateway_transactions_status ON gateway_transactions(status);
CREATE INDEX idx_gateway_transactions_reference ON gateway_transactions(gateway_reference);

-- ============================================================================
-- TABLE 14: pricing_config
-- Purpose: Fare calculation settings
-- ============================================================================
CREATE TABLE pricing_config (
    id SERIAL PRIMARY KEY,
    base_fare DECIMAL(10,2) NOT NULL, -- Starting price
    per_km_rate DECIMAL(10,2) NOT NULL, -- Price per km
    per_minute_rate DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    minimum_fare DECIMAL(10,2) NOT NULL,
    cancellation_fee_driver DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    cancellation_fee_passenger DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    free_cancellation_minutes INTEGER NOT NULL DEFAULT 2,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- TABLE 15: zones
-- Purpose: Geographic areas with special pricing (surge/demand zones)
-- surge_multiplier: 1.0 = normal price, 1.5 = 50% more during peak hours
-- ============================================================================
CREATE TABLE zones (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NOT NULL,
    coordinates TEXT NOT NULL, -- GeoJSON polygon
    surge_multiplier DECIMAL(4,2) NOT NULL DEFAULT 1.00, -- 1.0 = normal, 1.5 = 50% surge
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON COLUMN zones.surge_multiplier IS 'Multiplier for fare during peak hours. 1.0 = normal price, 1.5 = 50% higher. Used when demand is high in this zone.';

-- ============================================================================
-- TABLE 16: ratings
-- Purpose: Detailed rating records with tags (optional)
-- ============================================================================
CREATE TABLE ratings (
    id SERIAL PRIMARY KEY,
    trip_id INTEGER NOT NULL REFERENCES trips(id),
    rater_id INTEGER NOT NULL REFERENCES users(id),
    rated_id INTEGER NOT NULL REFERENCES users(id),
    rating DOUBLE PRECISION NOT NULL, -- 1.0-5.0
    review TEXT,
    tags TEXT, -- JSON: ["clean", "polite", "safe"]
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ratings_trip_id ON ratings(trip_id);
CREATE INDEX idx_ratings_rated_id ON ratings(rated_id);

-- ============================================================================
-- TABLE 17: support_tickets
-- Purpose: Customer support cases
-- ============================================================================
CREATE TABLE support_tickets (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    trip_id INTEGER REFERENCES trips(id),
    category ticket_category NOT NULL,
    subject VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    status ticket_status NOT NULL DEFAULT 'open',
    priority priority_level NOT NULL DEFAULT 'medium',
    assigned_to INTEGER REFERENCES users(id),
    resolution TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

CREATE INDEX idx_support_tickets_user_id ON support_tickets(user_id);
CREATE INDEX idx_support_tickets_status ON support_tickets(status);
CREATE INDEX idx_support_tickets_priority ON support_tickets(priority);

-- ============================================================================
-- TABLE 18: ticket_messages
-- Purpose: Messages within support tickets (chat-style)
-- ============================================================================
CREATE TABLE ticket_messages (
    id SERIAL PRIMARY KEY,
    ticket_id INTEGER NOT NULL REFERENCES support_tickets(id) ON DELETE CASCADE,
    sender_id INTEGER NOT NULL REFERENCES users(id),
    message TEXT NOT NULL,
    is_staff BOOLEAN NOT NULL DEFAULT FALSE,
    attachment_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ticket_messages_ticket_id ON ticket_messages(ticket_id);

-- ============================================================================
-- TABLE 19: promo_codes
-- Purpose: Discount codes and promotions
-- ============================================================================
CREATE TABLE promo_codes (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    discount_type discount_type NOT NULL,
    discount_value DECIMAL(10,2) NOT NULL, -- 20 for 20% or 20 EGP
    max_discount DECIMAL(10,2), -- Cap for percentage discounts
    min_trip_amount DECIMAL(10,2),
    usage_limit INTEGER, -- Total uses allowed
    usage_per_user INTEGER NOT NULL DEFAULT 1,
    valid_from TIMESTAMPTZ NOT NULL,
    valid_until TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_promo_codes_code ON promo_codes(code);
CREATE INDEX idx_promo_codes_valid_until ON promo_codes(valid_until);

-- ============================================================================
-- TABLE 20: promo_usage
-- Purpose: Track who used which promo codes
-- ============================================================================
CREATE TABLE promo_usage (
    id SERIAL PRIMARY KEY,
    promo_code_id INTEGER NOT NULL REFERENCES promo_codes(id),
    user_id INTEGER NOT NULL REFERENCES users(id),
    trip_id INTEGER NOT NULL REFERENCES trips(id),
    discount_amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_promo_usage_promo_code_id ON promo_usage(promo_code_id);
CREATE INDEX idx_promo_usage_user_id ON promo_usage(user_id);

-- ============================================================================
-- TABLE 21: emergency_contacts
-- Purpose: User's emergency contacts for SOS feature
-- ============================================================================
CREATE TABLE emergency_contacts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    relationship VARCHAR(50),
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_emergency_contacts_user_id ON emergency_contacts(user_id);

-- ============================================================================
-- TABLE 22: sos_alerts
-- Purpose: Emergency alerts triggered during rides
-- ============================================================================
CREATE TABLE sos_alerts (
    id SERIAL PRIMARY KEY,
    trip_id INTEGER NOT NULL REFERENCES trips(id),
    triggered_by INTEGER NOT NULL REFERENCES users(id),
    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(10,7) NOT NULL,
    status sos_status NOT NULL DEFAULT 'active',
    contacts_notified TEXT, -- JSON array of contact IDs
    handled_by INTEGER REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

CREATE INDEX idx_sos_alerts_trip_id ON sos_alerts(trip_id);
CREATE INDEX idx_sos_alerts_status ON sos_alerts(status);

-- ============================================================================
-- TABLE 23: driver_incidents
-- Purpose: Report bad driver behavior
-- ============================================================================
CREATE TABLE driver_incidents (
    id SERIAL PRIMARY KEY,
    driver_id INTEGER NOT NULL REFERENCES drivers(id),
    reported_by INTEGER NOT NULL REFERENCES users(id),
    trip_id INTEGER REFERENCES trips(id),
    incident_type incident_type NOT NULL,
    description TEXT NOT NULL,
    evidence_urls TEXT, -- JSON array of photo/video URLs
    status incident_status NOT NULL DEFAULT 'pending',
    priority priority_level NOT NULL DEFAULT 'medium',
    assigned_to INTEGER REFERENCES users(id),
    action_taken TEXT, -- Warning, suspension, ban
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

CREATE INDEX idx_driver_incidents_driver_id ON driver_incidents(driver_id);
CREATE INDEX idx_driver_incidents_status ON driver_incidents(status);
CREATE INDEX idx_driver_incidents_priority ON driver_incidents(priority);

-- ============================================================================
-- TABLE 24: driver_blacklist
-- Purpose: Permanently banned drivers
-- ============================================================================
CREATE TABLE driver_blacklist (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE REFERENCES users(id),
    national_id VARCHAR(20) NOT NULL UNIQUE, -- Prevent re-registration
    phone VARCHAR(20),
    reason TEXT NOT NULL,
    incident_ids TEXT, -- JSON array of incident IDs
    blacklisted_by INTEGER NOT NULL REFERENCES users(id),
    is_permanent BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_driver_blacklist_national_id ON driver_blacklist(national_id);
CREATE INDEX idx_driver_blacklist_phone ON driver_blacklist(phone);

-- ============================================================================
-- TABLE 25: trip_tracking
-- Purpose: GPS route recording during trips
-- NOTE: Can be storage-heavy. Consider keeping only 30 days.
-- ============================================================================
CREATE TABLE trip_tracking (
    id SERIAL PRIMARY KEY,
    trip_id INTEGER NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(10,7) NOT NULL,
    speed DECIMAL(6,2), -- km/h
    heading DECIMAL(5,2), -- 0-360 degrees
    accuracy DECIMAL(6,2), -- meters
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_trip_tracking_trip_id ON trip_tracking(trip_id);
CREATE INDEX idx_trip_tracking_recorded_at ON trip_tracking(recorded_at);

-- ============================================================================
-- TABLE 26: notifications
-- Purpose: Push notification history
-- ============================================================================
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    title VARCHAR(200) NOT NULL,
    title_ar VARCHAR(200),
    body TEXT NOT NULL,
    body_ar TEXT,
    type notification_type NOT NULL DEFAULT 'system',
    data TEXT, -- JSON payload for deep linking
    reference_id INTEGER,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_type ON notifications(type);

-- ============================================================================
-- TABLE 27: fcm_tokens
-- Purpose: Device tokens for push notifications
-- ============================================================================
CREATE TABLE fcm_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    platform device_platform NOT NULL,
    device_id VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_fcm_tokens_user_id ON fcm_tokens(user_id);
CREATE INDEX idx_fcm_tokens_is_active ON fcm_tokens(is_active);

-- ============================================================================
-- TABLE 28: saved_locations
-- Purpose: User's favorite/saved places
-- ============================================================================
CREATE TABLE saved_locations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    address TEXT,
    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(10,7) NOT NULL,
    location_type location_type NOT NULL DEFAULT 'other',
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_saved_locations_user_id ON saved_locations(user_id);

-- ============================================================================
-- TABLE 29: scheduled_trips
-- Purpose: Pre-booked rides for future times
-- ============================================================================
CREATE TABLE scheduled_trips (
    id SERIAL PRIMARY KEY,
    passenger_id INTEGER NOT NULL REFERENCES users(id),
    scheduled_at TIMESTAMPTZ NOT NULL,
    pickup_lat DECIMAL(10,7) NOT NULL,
    pickup_lng DECIMAL(10,7) NOT NULL,
    pickup_address TEXT,
    dropoff_lat DECIMAL(10,7) NOT NULL,
    dropoff_lng DECIMAL(10,7) NOT NULL,
    dropoff_address TEXT,
    status scheduled_trip_status NOT NULL DEFAULT 'scheduled',
    trip_id INTEGER REFERENCES trips(id),
    estimated_fare DECIMAL(10,2),
    notes TEXT,
    reminder_sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_scheduled_trips_passenger_id ON scheduled_trips(passenger_id);
CREATE INDEX idx_scheduled_trips_scheduled_at ON scheduled_trips(scheduled_at);
CREATE INDEX idx_scheduled_trips_status ON scheduled_trips(status);

-- ============================================================================
-- TABLE 30: audit_logs
-- Purpose: System audit trail for admin actions
-- ============================================================================
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    action VARCHAR(100) NOT NULL, -- e.g., "driver.approved", "user.blocked"
    entity VARCHAR(50) NOT NULL, -- e.g., "driver", "user", "trip"
    entity_id INTEGER NOT NULL,
    changes TEXT, -- JSON diff of before/after
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity, entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- ============================================================================
-- TRIGGERS FOR updated_at
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to all tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_drivers_updated_at BEFORE UPDATE ON drivers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_driver_documents_updated_at BEFORE UPDATE ON driver_documents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_vehicle_documents_updated_at BEFORE UPDATE ON vehicle_documents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subscription_plans_updated_at BEFORE UPDATE ON subscription_plans FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_commission_tiers_updated_at BEFORE UPDATE ON commission_tiers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_wallets_updated_at BEFORE UPDATE ON wallets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_gateway_transactions_updated_at BEFORE UPDATE ON gateway_transactions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_support_tickets_updated_at BEFORE UPDATE ON support_tickets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) - Enable and configure as needed
-- ============================================================================
-- Example: Enable RLS for users table
-- ALTER TABLE users ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Users can view own profile" ON users FOR SELECT USING (auth.uid()::text = open_id);

-- ============================================================================
-- SEED DATA: Default pricing config
-- ============================================================================
INSERT INTO pricing_config (base_fare, per_km_rate, per_minute_rate, minimum_fare, cancellation_fee_driver, cancellation_fee_passenger, free_cancellation_minutes, is_active)
VALUES (10.00, 3.00, 0.50, 15.00, 10.00, 5.00, 2, TRUE);

-- ============================================================================
-- SEED DATA: Initial commission tiers
-- ============================================================================
INSERT INTO commission_tiers (min_trips, max_trips, commission_percent, is_active) VALUES
(0, 50, 30.00, TRUE),
(51, 70, 25.00, TRUE),
(71, 100, 20.00, TRUE),
(101, 999999, 15.00, TRUE);

-- ============================================================================
-- COMMENTS
-- ============================================================================
COMMENT ON TABLE users IS 'All user accounts: passengers, drivers, admins. Every person has one record here.';
COMMENT ON TABLE drivers IS 'Extended profile for drivers. Links to users table. Can have NEGATIVE balance (debt).';
COMMENT ON TABLE trips IS 'Main ride records with InDriver-style bidding. Location can be typed if not on Google Maps.';
COMMENT ON TABLE driver_offers IS 'InDriver-style bidding. Drivers send price offers to passengers.';
COMMENT ON TABLE trip_views IS 'Track which drivers viewed a trip. Rules: idle drivers only, 5 min response, ≤15 min pickup ETA.';
COMMENT ON TABLE commission_tiers IS 'Dynamic commission rates based on trip count. Admin editable. Example: 0-50 trips = 30%.';
COMMENT ON TABLE wallet_transactions IS 'Wallet history including bonus and penalty with reasons.';
COMMENT ON TABLE zones IS 'Geographic areas with surge pricing. surge_multiplier 1.5 = 50% higher fare during peak hours.';

-- ============================================================================
-- END OF DDL
-- ============================================================================
