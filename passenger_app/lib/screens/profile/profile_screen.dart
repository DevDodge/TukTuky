import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final userStats = ref.watch(userStatsProvider);
    final memberSince = ref.watch(userMemberSinceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Profile', style: AppTheme.headingS),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/profile-edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mediumGrey),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: user?.profilePhotoUrl != null
                        ? NetworkImage(user!.profilePhotoUrl!)
                        : null,
                    child: user?.profilePhotoUrl == null
                        ? const Icon(Icons.person, size: 48)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'User',
                    style: AppTheme.headingS,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'email@example.com',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.mediumGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Text(
                      'Member since $memberSince',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mediumGrey),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatRow('Trips', '${userStats['trips']}'),
                  Divider(color: AppColors.mediumGrey),
                  _buildStatRow('Rating', '${userStats['rating']}'),
                  Divider(color: AppColors.mediumGrey),
                  _buildStatRow('Referrals', '${userStats['referrals']}'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuOption(
              icon: Icons.location_on,
              title: 'Saved Locations',
              onTap: () => context.push('/saved-locations'),
            ),
            _buildMenuOption(
              icon: Icons.emergency,
              title: 'Emergency Contacts',
              onTap: () => context.push('/emergency-contacts'),
            ),
            _buildMenuOption(
              icon: Icons.account_balance_wallet,
              title: 'Wallet',
              onTap: () => context.push('/wallet'),
            ),
            _buildMenuOption(
              icon: Icons.help,
              title: 'Help & Support',
              onTap: () => context.push('/support'),
            ),
            _buildMenuOption(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).signOut();
                  context.go('/login');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMedium),
          Text(value, style: AppTheme.labelLarge.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mediumGrey),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(title, style: AppTheme.bodyMedium),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.mediumGrey,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
