# TukTuky - Ride-Hailing Platform for TukTuk Transportation

![TukTuky Logo](assets/logo.png)

**TukTuky** is a comprehensive ride-hailing platform designed specifically for TukTuk (توكتوك) transportation in Egypt. The platform features an **InDriver-style bidding system** where passengers set their own prices and drivers counter-offer, creating a dynamic and fair pricing model.

## 🎯 Project Overview

TukTuky is a full-stack ride-hailing solution consisting of three main applications:

1. **Passenger App** (Flutter) - iOS/Android
2. **Driver App** (Flutter) - iOS/Android  
3. **Admin Dashboard** (React) - Web

### Key Features

#### 🚗 Passenger App
- **Social & Phone Authentication** - Google, Apple, Facebook, and OTP
- **InDriver Bidding System** - Set your own price, receive driver offers
- **Real-time Tracking** - Live driver location and trip tracking
- **Multiple Payment Methods** - Cash, Wallet, Card (Paymob, Fawry)
- **Wallet System** - Top-up, transaction history, promo codes
- **Safety Features** - SOS button, emergency contacts, incident reporting
- **Trip Management** - Scheduled trips, trip history, ratings
- **Saved Locations** - Home, Work, and custom locations
- **Support System** - In-app support tickets and chat

#### 🚙 Driver App
- **KYC Verification** - Document verification, background checks
- **Trip Management** - View requests, send offers, accept trips
- **Real-time Navigation** - Google Maps integration with route optimization
- **Earnings Dashboard** - Track earnings, commissions, payouts
- **Subscription Plans** - Dynamic commission tiers
- **Safety & Incidents** - Report incidents, SOS alerts
- **Ratings & Reviews** - Passenger ratings and feedback
- **Wallet Management** - Balance tracking, payouts

#### 📊 Admin Dashboard
- **Analytics** - Real-time metrics, revenue tracking, statistics
- **User Management** - Driver KYC verification, user blocking
- **Financial Management** - Commission settings, promo codes
- **Support Management** - Ticket handling, SOS alerts
- **Incident Management** - Driver incident review and action
- **System Configuration** - Pricing, zones, subscription plans

## 🛠️ Technology Stack

### Frontend
- **Flutter 3.x** - Cross-platform mobile development
- **React 18** - Web dashboard
- **TypeScript** - Type-safe code
- **TailwindCSS** - Utility-first styling
- **Riverpod** - State management (Flutter)
- **Redux** - State management (Web)

### Backend
- **Supabase** - PostgreSQL database, Auth, Realtime, Storage
- **Firebase** - Authentication, Cloud Messaging, Analytics
- **Google Maps API** - Maps and location services
- **Payment Gateways** - Paymob, Fawry, Vodafone Cash, Orange Cash

### Database
- **PostgreSQL** - 30 tables with comprehensive schema
- **Supabase Storage** - File storage for documents and photos
- **Redis** (Optional) - Caching layer

## 📁 Project Structure

```
TukTuky/
├── passenger_app/              # Flutter Passenger App
│   ├── lib/
│   │   ├── models/            # Data models
│   │   ├── providers/         # Riverpod state management
│   │   ├── screens/           # UI screens
│   │   ├── widgets/           # Reusable widgets
│   │   ├── services/          # API & Supabase services
│   │   └── utils/             # Utilities
│   ├── pubspec.yaml
│   └── README.md
│
├── driver_app/                 # Flutter Driver App
│   ├── lib/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── services/
│   │   └── utils/
│   ├── pubspec.yaml
│   └── README.md
│
├── dashboard/                  # React Admin Dashboard
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   ├── store/
│   │   └── utils/
│   ├── package.json
│   └── README.md
│
├── database/
│   ├── schema.sql              # PostgreSQL schema
│   ├── seed.sql                # Sample data
│   └── migrations/
│
├── docs/
│   ├── API_DOCUMENTATION.md
│   ├── DATABASE_SCHEMA.md
│   ├── SETUP_GUIDE.md
│   └── DEPLOYMENT.md
│
├── ARCHITECTURE.md
├── README.md
└── .gitignore
```

## 🚀 Quick Start

### Prerequisites
- Flutter 3.x
- Dart 3.0+
- Node.js 18+
- PostgreSQL 14+
- Git

### Installation

1. **Clone Repository**
```bash
git clone https://github.com/yourusername/tuktuk.git
cd TukTuky
```

2. **Setup Passenger App**
```bash
cd passenger_app
flutter pub get
flutter pub run build_runner build
```

3. **Setup Driver App**
```bash
cd ../driver_app
flutter pub get
flutter pub run build_runner build
```

4. **Setup Dashboard**
```bash
cd ../dashboard
npm install
npm run dev
```

5. **Setup Database**
- Create Supabase project
- Run database schema
- Configure environment variables

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed instructions.

## 📚 Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture and design
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Complete setup instructions
- **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** - API endpoints and usage
- **[DATABASE_SCHEMA.md](database/schema.sql)** - Database tables and relationships

## 🎨 Design System

### Brand Colors
- **Primary Black**: `#0A0C0B` - Main background
- **Golden Yellow**: `#DD8B01` - Primary accent
- **Bright Yellow**: `#FCF202` - Highlights
- **Orange Gold**: `#DC8F01` - Secondary accent
- **White**: `#FFFFFF` - Text on dark

### Typography
- **Poppins** - English text
- **Cairo** - Arabic text

### Design Principles
- Dark mode by default
- Glassmorphism effects
- Smooth animations
- Bottom sheet actions
- Skeleton loaders

## 🔐 Security

- **Authentication**: Supabase Auth with JWT
- **Authorization**: Row-Level Security (RLS)
- **Encryption**: HTTPS, encrypted sensitive data
- **Payment**: PCI compliant, tokenization
- **KYC**: Document verification
- **Rate Limiting**: API rate limiting
- **Monitoring**: Error tracking with Sentry

## 📊 Database Schema

### Core Tables (30 Total)
- **users** - User accounts
- **drivers** - Driver profiles
- **trips** - Trip records
- **driver_offers** - Bidding offers
- **wallets** - Wallet balances
- **payments** - Payment records
- **ratings** - User ratings
- **support_tickets** - Support cases
- **notifications** - Push notifications
- **promo_codes** - Discount codes
- And 20+ more...

See [database/schema.sql](database/schema.sql) for complete schema.

## 🔄 Real-time Features

- **Trip Updates** - Status changes, driver assignment
- **Live Offers** - New driver offers in real-time
- **Location Tracking** - Driver location updates
- **Notifications** - Push notifications
- **Chat** - Support ticket messages

## 💳 Payment Integration

- **Paymob** - Card payments
- **Fawry** - Bill payments
- **Vodafone Cash** - Mobile wallet
- **Orange Cash** - Mobile wallet
- **Wallet** - In-app wallet

## 📈 Analytics

- **Firebase Analytics** - User behavior tracking
- **Sentry** - Error tracking
- **Custom Analytics** - Business metrics
- **Real-time Dashboard** - Live metrics

## 🧪 Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Web tests
npm test
```

## 🚢 Deployment

### Mobile Apps
- **Android**: Google Play Store
- **iOS**: Apple App Store

### Dashboard
- **Vercel** - Recommended
- **AWS** - EC2, S3, CloudFront
- **Google Cloud** - App Engine, Cloud Run
- **Heroku** - PaaS option

See [DEPLOYMENT.md](docs/DEPLOYMENT.md) for detailed instructions.

## 📱 Screenshots

### Passenger App
- Authentication screens
- Home with map
- Trip booking flow
- InDriver bidding
- Trip tracking
- Ratings and reviews

### Driver App
- KYC verification
- Trip requests
- Offer management
- Navigation
- Earnings dashboard
- Wallet management

### Admin Dashboard
- Analytics dashboard
- User management
- Financial management
- Support management
- System configuration

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see LICENSE file for details.

## 🆘 Support

- **Documentation**: [docs.tuktuk.com](https://docs.tuktuk.com)
- **Email**: support@tuktuk.com
- **Issues**: [GitHub Issues](https://github.com/yourusername/tuktuk/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/tuktuk/discussions)

## 🗺️ Roadmap

### Phase 1 (Current)
- ✅ Project setup and architecture
- ✅ Database schema
- ✅ Authentication system
- ⏳ Basic UI implementation

### Phase 2
- Trip booking system
- InDriver bidding
- Real-time tracking
- Payment integration

### Phase 3
- Driver app
- Admin dashboard
- Analytics
- Advanced features

### Phase 4
- Mobile optimization
- Performance tuning
- Security hardening
- Production deployment

## 👥 Team

- **Project Lead**: [Your Name]
- **Backend Developer**: [Name]
- **Frontend Developer**: [Name]
- **Mobile Developer**: [Name]
- **DevOps Engineer**: [Name]

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- Google Maps for location services
- Payment gateway partners

## 📞 Contact

- **Website**: https://tuktuk.com
- **Email**: info@tuktuk.com
- **Phone**: +20 (XXX) XXX-XXXX
- **Address**: Cairo, Egypt

---

**Made with ❤️ for TukTuk drivers and passengers in Egypt**

Last Updated: January 29, 2026
