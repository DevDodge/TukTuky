import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/theme.dart';
import '../../widgets/golden_button.dart';
import '../../providers/wallet_provider.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  String _selectedAmount = '50';

  @override
  Widget build(BuildContext context) {
    final walletBalance = ref.watch(walletBalanceProvider);
    final transactions = ref.watch(walletTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Wallet', style: AppTheme.headingS),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.elevatedShadow,
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balance',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppColors.surface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'EGP ${walletBalance.toStringAsFixed(2)}',
                    style: AppTheme.headingM.copyWith(
                      color: AppColors.surface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Top Up Amount', style: AppTheme.labelLarge),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: ['50', '100', '200', '500', '1000', 'Custom']
                  .map((amount) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedAmount = amount),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedAmount == amount
                          ? AppColors.primary
                          : AppColors.darkGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedAmount == amount
                            ? AppColors.primary
                            : AppColors.mediumGrey,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        amount == 'Custom' ? 'Custom' : 'EGP $amount',
                        style: TextStyle(
                          color: _selectedAmount == amount
                              ? AppColors.background
                              : AppColors.surface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GoldenButton(
                label: 'Top Up Wallet',
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 32),
            Text('Recent Transactions', style: AppTheme.labelLarge),
            const SizedBox(height: 12),
            ...transactions.map((transaction) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.darkGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mediumGrey),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: transaction['type'] == 'credit'
                            ? AppColors.acceptGreen.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        transaction['type'] == 'credit'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: transaction['type'] == 'credit'
                            ? AppColors.acceptGreen
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(transaction['description'], style: AppTheme.labelSmall),
                          Text(
                            transaction['date'],
                            style: AppTheme.bodySmall.copyWith(
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${transaction['type'] == 'credit' ? '+' : '-'} EGP ${transaction['amount']}',
                      style: TextStyle(
                        color: transaction['type'] == 'credit'
                            ? AppColors.acceptGreen
                            : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
