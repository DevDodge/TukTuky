import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'auth_provider.dart';

// User profile provider
final userProfileProvider = Provider<User?>((ref) {
  return ref.watch(currentUserProvider);
});

// User referral code provider
final userReferralCodeProvider = Provider<String?>((ref) {
  final user = ref.watch(userProfileProvider);
  return user?.referralCode;
});

// User referral earnings provider
final userReferralEarningsProvider = Provider<double>((ref) {
  final user = ref.watch(userProfileProvider);
  return user?.referralEarnings ?? 0.0;
});

// User language preference provider
final userLanguageProvider = StateProvider<String>((ref) {
  final user = ref.watch(userProfileProvider);
  return user?.language ?? 'ar';
});

// User profile completeness provider
final userProfileCompletenessProvider = Provider<int>((ref) {
  final user = ref.watch(userProfileProvider);
  return user?.profileCompleteness ?? 0;
});

// User is blocked provider
final userIsBlockedProvider = Provider<bool>((ref) {
  final user = ref.watch(userProfileProvider);
  return user?.isBlocked ?? false;
});

// User name provider
final userNameProvider = Provider<String>((ref) {
  final user = ref.watch(userProfileProvider);
  return user?.name ?? 'User';
});

// User email provider
final userEmailProvider = Provider<String?>((ref) {
  final user = ref.watch(userProfileProvider);
  return user?.email;
});

// User phone provider
final userPhoneProvider = Provider<String?>((ref) {
  final user = ref.watch(userProfileProvider);
  return user?.phone;
});

// User avatar provider
final userAvatarProvider = Provider<String?>((ref) {
  final user = ref.watch(userProfileProvider);
  return user?.profilePhotoUrl;
});

// User rating provider
final userRatingProvider = Provider<double>((ref) {
  final user = ref.watch(userProfileProvider);
  return user?.rating ?? 0.0;
});

// User trip count provider
final userTripCountProvider = Provider<int>((ref) {
  final user = ref.watch(userProfileProvider);
  return user?.totalTrips ?? 0;
});

// User creation date provider
final userCreationDateProvider = Provider<DateTime?>((ref) {
  final user = ref.watch(userProfileProvider);
  return user?.createdAt;
});

// User last sign in provider
final userLastSignInProvider = Provider<DateTime?>((ref) {
  final user = ref.watch(userProfileProvider);
  return user?.lastSignedIn;
});

// User referred by provider
final userReferredByProvider = Provider<int?>((ref) {
  final user = ref.watch(userProfileProvider);
  return user?.referredBy;
});

// User member since provider
final userMemberSinceProvider = Provider<String>((ref) {
  final user = ref.watch(userProfileProvider);
  if (user?.createdAt == null) return 'N/A';

  final now = DateTime.now();
  final difference = now.difference(user!.createdAt);

  if (difference.inDays < 1) {
    return 'Today';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays < 30) {
    final weeks = difference.inDays ~/ 7;
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  } else if (difference.inDays < 365) {
    final months = difference.inDays ~/ 30;
    return '$months month${months > 1 ? 's' : ''} ago';
  } else {
    final years = difference.inDays ~/ 365;
    return '$years year${years > 1 ? 's' : ''} ago';
  }
});

// User stats provider
final userStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final user = ref.watch(userProfileProvider);
  return {
    'trips': user?.totalTrips ?? 0,
    'rating': user?.rating ?? 0.0,
    'referrals': user?.referralEarnings ?? 0.0,
    'completeness': user?.profileCompleteness ?? 0,
  };
});
