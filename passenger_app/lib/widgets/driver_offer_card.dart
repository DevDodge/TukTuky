import 'package:flutter/material.dart';
import '../config/colors.dart';

class DriverOfferCard extends StatefulWidget {
  final String driverName;
  final String driverImage;
  final double driverRating;
  final int reviewCount;
  final double offeredFare;
  final double yourFare;
  final String eta;
  final double distance;
  final String? message;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool isHighlighted;

  const DriverOfferCard({
    Key? key,
    required this.driverName,
    required this.driverImage,
    required this.driverRating,
    required this.reviewCount,
    required this.offeredFare,
    required this.yourFare,
    required this.eta,
    required this.distance,
    this.message,
    required this.onAccept,
    required this.onDecline,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  State<DriverOfferCard> createState() => _DriverOfferCardState();
}

class _DriverOfferCardState extends State<DriverOfferCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBetterPrice = widget.offeredFare < widget.yourFare;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(16),
          border: widget.isHighlighted
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: AppColors.mediumGrey, width: 1),
          boxShadow: widget.isHighlighted
              ? AppColors.elevatedShadow
              : AppColors.cardShadow,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Driver Info Row
            Row(
              children: [
                // Driver Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(widget.driverImage),
                ),
                const SizedBox(width: 12),
                // Driver Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.driverName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.surface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.highlight,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.driverRating}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.surface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${widget.reviewCount})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Fare Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isBetterPrice
                        ? AppColors.acceptGreen.withOpacity(0.1)
                        : AppColors.highlight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isBetterPrice
                          ? AppColors.acceptGreen
                          : AppColors.highlight,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'EGP ${widget.offeredFare.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isBetterPrice
                              ? AppColors.acceptGreen
                              : AppColors.highlight,
                        ),
                      ),
                      if (isBetterPrice)
                        Text(
                          'Save ${(widget.yourFare - widget.offeredFare).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.acceptGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ETA and Distance
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.eta,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.surface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.distance.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.surface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Message (if any)
            if (widget.message != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.message!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGrey,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onDecline,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.mediumGrey,
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(
                        color: AppColors.background,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OfferCounter extends StatefulWidget {
  final int viewsCount;
  final int offersCount;

  const OfferCounter({
    Key? key,
    required this.viewsCount,
    required this.offersCount,
  }) : super(key: key);

  @override
  State<OfferCounter> createState() => _OfferCounterState();
}

class _OfferCounterState extends State<OfferCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _scaleController.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(OfferCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offersCount != widget.offersCount) {
      _scaleController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1.5),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Views Counter
            Column(
              children: [
                const Text(
                  '👀',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.viewsCount}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.highlight,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Viewing',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
            // Divider
            Container(
              width: 1,
              height: 60,
              color: AppColors.mediumGrey,
            ),
            // Offers Counter
            Column(
              children: [
                const Text(
                  '📨',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.offersCount}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Offers',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
