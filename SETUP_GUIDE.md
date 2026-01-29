# TukTuky Platform - Setup & Deployment Guide

## Prerequisites

### System Requirements
- **Flutter**: 3.x or higher
- **Dart**: 3.0 or higher
- **Node.js**: 18.x or higher (for dashboard)
- **PostgreSQL**: 14+ (for Supabase)
- **Git**: 2.x or higher

### Development Tools
- Android Studio or Xcode (for mobile development)
- VS Code or Android Studio IDE
- Supabase CLI
- Firebase CLI

## Project Setup

### 1. Clone Repository
```bash
cd /home/ubuntu/TukTuky
git init
git add .
git commit -m "Initial commit: TukTuky platform setup"
```

### 2. Flutter Apps Setup

#### Passenger App
```bash
cd passenger_app
flutter pub get
flutter pub run build_runner build
```

#### Driver App
```bash
cd ../driver_app
flutter pub get
flutter pub run build_runner build
```

### 3. Database Setup

#### Create Supabase Project
1. Go to [Supabase](https://supabase.com)
2. Create new project
3. Note your API URL and API Key

#### Apply Database Schema
```bash
# Using Supabase CLI
supabase db push

# Or manually:
# 1. Go to Supabase Dashboard
# 2. SQL Editor
# 3. Copy contents of database/schema.sql
# 4. Execute
```

#### Create Storage Buckets
```sql
-- In Supabase SQL Editor
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('driver-documents', 'driver-documents', false),
  ('vehicle-documents', 'vehicle-documents', false),
  ('trip-photos', 'trip-photos', false),
  ('user-avatars', 'user-avatars', true);
```

### 4. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create new project
3. Enable Authentication (Phone, Google, Apple, Facebook)
4. Enable Cloud Messaging
5. Download configuration files

#### Add Firebase to Apps
```bash
# Passenger App
cd passenger_app
flutterfire configure

# Driver App
cd ../driver_app
flutterfire configure
```

### 5. Environment Configuration

#### Create `.env` files

**passenger_app/.env**
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GOOGLE_MAPS_API_KEY=your_google_maps_key
FIREBASE_PROJECT_ID=your_firebase_project_id
PAYMOB_API_KEY=your_paymob_key
```

**driver_app/.env**
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GOOGLE_MAPS_API_KEY=your_google_maps_key
FIREBASE_PROJECT_ID=your_firebase_project_id
PAYMOB_API_KEY=your_paymob_key
```

### 6. Dashboard Setup

```bash
cd dashboard
npm install
npm run dev
```

## Running the Applications

### Development Mode

#### Passenger App
```bash
cd passenger_app
flutter run
```

#### Driver App
```bash
cd driver_app
flutter run
```

#### Dashboard
```bash
cd dashboard
npm run dev
```

### Production Build

#### Android
```bash
cd passenger_app
flutter build apk --release
flutter build appbundle --release
```

#### iOS
```bash
cd passenger_app
flutter build ios --release
```

#### Web Dashboard
```bash
cd dashboard
npm run build
npm run start
```

## API Configuration

### Supabase Configuration

#### Row Level Security (RLS) Policies

**Users Table**
```sql
-- Users can only read their own profile
CREATE POLICY "Users can read own profile"
ON users FOR SELECT
USING (auth.uid()::text = open_id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
ON users FOR UPDATE
USING (auth.uid()::text = open_id);
```

**Trips Table**
```sql
-- Passengers can read their own trips
CREATE POLICY "Passengers can read own trips"
ON trips FOR SELECT
USING (passenger_id = (SELECT id FROM users WHERE open_id = auth.uid()::text));

-- Drivers can read assigned trips
CREATE POLICY "Drivers can read assigned trips"
ON trips FOR SELECT
USING (driver_id = (SELECT id FROM drivers WHERE user_id = (SELECT id FROM users WHERE open_id = auth.uid()::text)));
```

#### Enable Realtime Subscriptions
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE trips;
ALTER PUBLICATION supabase_realtime ADD TABLE driver_offers;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE trip_tracking;
```

### Payment Gateway Setup

#### Paymob Integration
1. Create Paymob account
2. Get API Key from dashboard
3. Configure in environment variables
4. Test with sandbox credentials

#### Fawry Integration
1. Create Fawry merchant account
2. Get merchant code and security key
3. Configure in environment variables

## Testing

### Unit Tests
```bash
cd passenger_app
flutter test

cd ../driver_app
flutter test
```

### Integration Tests
```bash
cd passenger_app
flutter test integration_test/

cd ../driver_app
flutter test integration_test/
```

### API Testing
```bash
# Using Postman or curl
curl -X GET https://your-supabase-url/rest/v1/users \
  -H "Authorization: Bearer your_token" \
  -H "Content-Type: application/json"
```

## Deployment

### Mobile App Deployment

#### Google Play Store
1. Create Google Play Developer account
2. Create app listing
3. Build release APK/Bundle
4. Upload to Play Store
5. Submit for review

#### Apple App Store
1. Create Apple Developer account
2. Create app in App Store Connect
3. Build release IPA
4. Upload to TestFlight
5. Submit for review

### Web Dashboard Deployment

#### Using Vercel
```bash
cd dashboard
vercel deploy --prod
```

#### Using AWS
```bash
cd dashboard
npm run build
# Upload dist/ to S3
# Configure CloudFront
```

#### Using Google Cloud
```bash
cd dashboard
npm run build
gcloud app deploy
```

## Monitoring & Analytics

### Firebase Analytics
- Configured automatically in Flutter apps
- View in Firebase Console

### Sentry Error Tracking
```dart
// In main.dart
await Sentry.init(
  'your_sentry_dsn',
  tracesSampleRate: 1.0,
);
```

### Logs
- Supabase: View in dashboard
- Firebase: View in console
- Custom: Implement centralized logging

## Troubleshooting

### Common Issues

#### Flutter Build Errors
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Supabase Connection Issues
- Verify API URL and keys
- Check network connectivity
- Verify RLS policies
- Check CORS settings

#### Firebase Authentication Issues
- Verify Firebase configuration
- Check authentication providers
- Verify SHA-1 certificate (Android)
- Verify bundle ID (iOS)

#### Payment Gateway Issues
- Verify API keys
- Check sandbox vs production
- Verify webhook URLs
- Check transaction logs

## Security Checklist

- [ ] Enable HTTPS everywhere
- [ ] Configure CORS properly
- [ ] Implement rate limiting
- [ ] Validate all inputs
- [ ] Use environment variables for secrets
- [ ] Enable 2FA for admin accounts
- [ ] Regular security audits
- [ ] Implement logging and monitoring
- [ ] Use encrypted connections
- [ ] Regular backups

## Performance Optimization

### Flutter Apps
- Use lazy loading for lists
- Implement image caching
- Optimize database queries
- Use code splitting
- Minimize app size

### Dashboard
- Implement code splitting
- Use lazy loading
- Optimize images
- Implement service workers
- Use CDN for static assets

### Database
- Add strategic indexes
- Implement query optimization
- Use connection pooling
- Archive old data
- Regular maintenance

## Maintenance

### Regular Tasks
- Monitor error logs
- Review user feedback
- Update dependencies
- Security patches
- Database backups
- Performance monitoring

### Scheduled Maintenance
- Database optimization (weekly)
- Log cleanup (monthly)
- Dependency updates (monthly)
- Security audits (quarterly)
- Disaster recovery tests (quarterly)

## Support & Documentation

### Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Maps API](https://developers.google.com/maps)

### Contact
- Email: support@tuktuk.com
- Documentation: docs.tuktuk.com
- Issues: GitHub Issues
