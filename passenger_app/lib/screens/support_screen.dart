import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/colors.dart';
import '../config/theme.dart';
import '../widgets/golden_button.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  late TextEditingController _messageController;
  String _selectedCategory = 'general';
  List<Map<String, String>> tickets = [
    {
      'id': '#1001',
      'subject': 'Driver canceled trip',
      'status': 'resolved',
      'date': 'Jan 25, 2026'
    },
    {
      'id': '#1000',
      'subject': 'Payment issue',
      'status': 'open',
      'date': 'Jan 28, 2026'
    },
  ];

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitTicket() {
    if (_messageController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Support ticket submitted successfully')),
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Help & Support', style: AppTheme.headingS),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Submit a Ticket', style: AppTheme.labelLarge),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mediumGrey),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButton<String>(
                    value: _selectedCategory,
                    items: ['general', 'payment', 'driver', 'safety']
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
                    },
                    isExpanded: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Describe your issue',
                      hintStyle: const TextStyle(color: AppColors.mediumGrey),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.mediumGrey),
                      ),
                    ),
                    style: const TextStyle(color: AppColors.surface),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: GoldenButton(
                      label: 'Submit Ticket',
                      onPressed: _submitTicket,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Your Tickets', style: AppTheme.labelLarge),
            const SizedBox(height: 12),
            ...tickets.map((ticket) {
              final isResolved = ticket['status'] == 'resolved';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.darkGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mediumGrey),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ticket['id']!, style: AppTheme.labelSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isResolved
                                ? AppColors.acceptGreen.withOpacity(0.1)
                                : AppColors.highlight.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ticket['status']!.toUpperCase(),
                            style: TextStyle(
                              color: isResolved
                                  ? AppColors.acceptGreen
                                  : AppColors.highlight,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(ticket['subject']!, style: AppTheme.labelSmall),
                    const SizedBox(height: 8),
                    Text(
                      ticket['date']!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mediumGrey),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FAQ', style: AppTheme.labelLarge),
                  const SizedBox(height: 12),
                  _buildFAQItem(
                    'How do I cancel a trip?',
                    'You can cancel a trip before the driver arrives by tapping the cancel button.',
                  ),
                  _buildFAQItem(
                    'How do I report a driver?',
                    'Use the report button during or after the trip to report any issues.',
                  ),
                  _buildFAQItem(
                    'How do I get a refund?',
                    'Contact support with your trip details for refund requests.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: AppTheme.labelSmall),
          const SizedBox(height: 8),
          Text(
            answer,
            style: AppTheme.bodySmall.copyWith(
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }
}
