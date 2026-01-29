import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

/// Localization Provider for Complete i18n Support
final localizationProvider = StateNotifierProvider<LocalizationNotifier, Locale>(
  (ref) => LocalizationNotifier(),
);

/// Translation Provider - Get translated strings
final translationProvider = Provider<Map<String, dynamic>>((ref) {
  final locale = ref.watch(localizationProvider);
  // This will be populated by LocalizationNotifier
  return ref.watch(_translationsProvider(locale.languageCode)).maybeWhen(
    data: (translations) => translations,
    orElse: () => <String, dynamic>{},
  );
});

/// Internal translations provider
final _translationsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, languageCode) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/translations/$languageCode.json',
      );
      return jsonDecode(jsonString);
    } catch (e) {
      return {};
    }
  },
);

/// Localization Notifier for managing locale state
class LocalizationNotifier extends StateNotifier<Locale> {
  LocalizationNotifier() : super(const Locale('en'));

  /// Change language
  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
  }

  /// Toggle between English and Arabic
  Future<void> toggleLanguage() async {
    final newLanguage = state.languageCode == 'en' ? 'ar' : 'en';
    await setLocale(newLanguage);
  }

  /// Get current language code
  String getCurrentLanguage() => state.languageCode;

  /// Check if RTL (Arabic)
  bool isRTL() => state.languageCode == 'ar';
}

/// Extension for easy translation access
extension TranslationExtension on BuildContext {
  /// Get translated string
  String t(String key) {
    final translations = Localizations.of<AppLocalizations>(this, AppLocalizations);
    return translations?.translate(key) ?? key;
  }

  /// Get translated string with parameters
  String tParams(String key, Map<String, String> params) {
    final translations = Localizations.of<AppLocalizations>(this, AppLocalizations);
    return translations?.translateWithParams(key, params) ?? key;
  }

  /// Check if current locale is RTL
  bool isRTL() {
    return Directionality.of(this) == TextDirection.rtl;
  }
}

/// App Localizations Delegate
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// App Localizations
class AppLocalizations {
  final Locale locale;
  late Map<String, dynamic> _translations;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Load translations from JSON
  Future<void> load() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/translations/${locale.languageCode}.json',
      );
      _translations = jsonDecode(jsonString);
    } catch (e) {
      _translations = {};
    }
  }

  /// Translate key
  String translate(String key) {
    try {
      final keys = key.split('.');
      dynamic value = _translations;
      for (final k in keys) {
        value = value[k];
      }
      return value.toString();
    } catch (e) {
      return key;
    }
  }

  /// Translate with parameters
  String translateWithParams(String key, Map<String, String> params) {
    String text = translate(key);
    params.forEach((paramKey, paramValue) {
      text = text.replaceAll('{$paramKey}', paramValue);
    });
    return text;
  }

  // ============================================================================
  // COMMON TRANSLATIONS
  // ============================================================================
  String get appName => translate('app_name');
  String get welcome => translate('welcome');
  String get login => translate('login');
  String get signup => translate('signup');
  String get phoneNumber => translate('phone_number');
  String get verifyOtp => translate('verify_otp');
  String get enterOtp => translate('enter_otp');
  String get resendOtp => translate('resend_otp');
  String get home => translate('home');
  String get searchLocation => translate('search_location');
  String get pickupLocation => translate('pickup_location');
  String get dropoffLocation => translate('dropoff_location');
  String get confirmTrip => translate('confirm_trip');
  String get yourOffer => translate('your_offer');
  String get baseFare => translate('base_fare');
  String get discount => translate('discount');
  String get total => translate('total');
  String get paymentMethod => translate('payment_method');
  String get wallet => translate('wallet');
  String get cash => translate('cash');
  String get creditCard => translate('credit_card');
  String get requestTrip => translate('request_trip');
  String get waitingForOffers => translate('waiting_for_offers');
  String get driverArriving => translate('driver_arriving');
  String get tripInProgress => translate('trip_in_progress');
  String get tripCompleted => translate('trip_completed');
  String get rateTrip => translate('rate_trip');
  String get addTip => translate('add_tip');
  String get profile => translate('profile');
  String get savedLocations => translate('saved_locations');
  String get emergencyContacts => translate('emergency_contacts');
  String get helpSupport => translate('help_support');
  String get settings => translate('settings');
  String get signOut => translate('sign_out');
  String get addLocation => translate('add_location');
  String get addContact => translate('add_contact');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get save => translate('save');
  String get submit => translate('submit');
  String get done => translate('done');
  String get error => translate('error');
  String get success => translate('success');
  String get loading => translate('loading');

  // ============================================================================
  // EXTENDED TRANSLATIONS
  // ============================================================================
  String get goodMorning => translate('good_morning');
  String get goodAfternoon => translate('good_afternoon');
  String get goodEvening => translate('good_evening');
  String get whereToGo => translate('where_to_go');
  String get searchDestination => translate('search_destination');
  String get recentTrips => translate('recent_trips');
  String get viewAll => translate('view_all');
  String get acceptOffer => translate('accept_offer');
  String get declineOffer => translate('decline_offer');
  String get driverInfo => translate('driver_info');
  String get carDetails => translate('car_details');
  String get eta => translate('eta');
  String get distance => translate('distance');
  String get rating => translate('rating');
  String get reviews => translate('reviews');
  String get bestPrice => translate('best_price');
  String get offersExpireIn => translate('offers_expire_in');
  String get seconds => translate('seconds');
  String get availableOffers => translate('available_offers');
  String get driversResponding => translate('drivers_responding');
  String get cancelTrip => translate('cancel_trip');
  String get areYouSure => translate('are_you_sure');
  String get keepWaiting => translate('keep_waiting');
  String get sosAlert => translate('sos_alert');
  String get emergencyServices => translate('emergency_services');
  String get callPolice => translate('call_police');
  String get shareLocation => translate('share_location');
  String get tripSummary => translate('trip_summary');
  String get pickupTime => translate('pickup_time');
  String get dropoffTime => translate('dropoff_time');
  String get tripDuration => translate('trip_duration');
  String get tripDistance => translate('trip_distance');
  String get fareBreakdown => translate('fare_breakdown');
  String get baseFareAmount => translate('base_fare_amount');
  String get distanceFare => translate('distance_fare');
  String get timeFare => translate('time_fare');
  String get surgePricing => translate('surge_pricing');
  String get promoCodeDiscount => translate('promo_code_discount');
  String get totalFare => translate('total_fare');
  String get paymentStatus => translate('payment_status');
  String get paymentPending => translate('payment_pending');
  String get paymentCompleted => translate('payment_completed');
  String get paymentFailed => translate('payment_failed');
  String get addPromoCode => translate('add_promo_code');
  String get enterPromoCode => translate('enter_promo_code');
  String get applyCode => translate('apply_code');
  String get codeApplied => translate('code_applied');
  String get invalidCode => translate('invalid_code');
  String get topUpWallet => translate('top_up_wallet');
  String get walletBalance => translate('wallet_balance');
  String get recentTransactions => translate('recent_transactions');
  String get addPaymentMethod => translate('add_payment_method');
  String get selectPaymentMethod => translate('select_payment_method');
  String get creditDebitCard => translate('credit_debit_card');
  String get mobileWallet => translate('mobile_wallet');
  String get bankTransfer => translate('bank_transfer');
  String get cardNumber => translate('card_number');
  String get expiryDate => translate('expiry_date');
  String get cvv => translate('cvv');
  String get cardholderName => translate('cardholder_name');
  String get saveCard => translate('save_card');
  String get userProfile => translate('user_profile');
  String get editProfile => translate('edit_profile');
  String get firstName => translate('first_name');
  String get lastName => translate('last_name');
  String get email => translate('email');
  String get dateOfBirth => translate('date_of_birth');
  String get gender => translate('gender');
  String get profilePhoto => translate('profile_photo');
  String get uploadPhoto => translate('upload_photo');
  String get changePhoto => translate('change_photo');
  String get memberSince => translate('member_since');
  String get totalTrips => translate('total_trips');
  String get averageRating => translate('average_rating');
  String get referralCode => translate('referral_code');
  String get shareCode => translate('share_code');
  String get copyCode => translate('copy_code');
  String get codeCopied => translate('code_copied');
  String get referralBonus => translate('referral_bonus');
  String get inviteFriends => translate('invite_friends');
  String get friendsInvited => translate('friends_invited');
  String get bonusEarned => translate('bonus_earned');
  String get supportTickets => translate('support_tickets');
  String get submitTicket => translate('submit_ticket');
  String get ticketId => translate('ticket_id');
  String get ticketStatus => translate('ticket_status');
  String get ticketOpen => translate('ticket_open');
  String get ticketInProgress => translate('ticket_in_progress');
  String get ticketResolved => translate('ticket_resolved');
  String get ticketClosed => translate('ticket_closed');
  String get ticketCategory => translate('ticket_category');
  String get categoryGeneral => translate('category_general');
  String get categoryPayment => translate('category_payment');
  String get categoryDriver => translate('category_driver');
  String get categorySafety => translate('category_safety');
  String get describeIssue => translate('describe_issue');
  String get attachScreenshot => translate('attach_screenshot');
  String get faq => translate('faq');
  String get frequentlyAskedQuestions => translate('frequently_asked_questions');
  String get howToCancelTrip => translate('how_to_cancel_trip');
  String get howToReportDriver => translate('how_to_report_driver');
  String get howToGetRefund => translate('how_to_get_refund');
  String get howToAddPaymentMethod => translate('how_to_add_payment_method');
  String get termsAndConditions => translate('terms_and_conditions');
  String get privacyPolicy => translate('privacy_policy');
  String get byContin => translate('by_continuing');
  String get agreeToOur => translate('agree_to_our');
  String get termsLabel => translate('terms_label');
  String get andLabel => translate('and_label');
  String get privacyLabel => translate('privacy_label');
  String get notificationSettings => translate('notification_settings');
  String get pushNotifications => translate('push_notifications');
  String get emailNotifications => translate('email_notifications');
  String get smsNotifications => translate('sms_notifications');
  String get tripNotifications => translate('trip_notifications');
  String get promoNotifications => translate('promo_notifications');
  String get safetyNotifications => translate('safety_notifications');
  String get language => translate('language');
  String get english => translate('english');
  String get arabic => translate('arabic');
  String get darkMode => translate('dark_mode');
  String get lightMode => translate('light_mode');
  String get systemDefault => translate('system_default');
  String get about => translate('about');
  String get version => translate('version');
  String get buildNumber => translate('build_number');
  String get contactUs => translate('contact_us');
  String get rateApp => translate('rate_app');
  String get shareApp => translate('share_app');
  String get feedback => translate('feedback');
  String get sendFeedback => translate('send_feedback');
  String get deleteAccount => translate('delete_account');
  String get deleteAccountWarning => translate('delete_account_warning');
  String get confirmDelete => translate('confirm_delete');
}
