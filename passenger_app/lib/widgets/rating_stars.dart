import 'package:flutter/material.dart';
import '../config/colors.dart';

class RatingStars extends StatefulWidget {
  final double initialRating;
  final int starCount;
  final double starSize;
  final ValueChanged<double>? onRatingChanged;
  final bool isInteractive;
  final Color activeColor;
  final Color inactiveColor;

  const RatingStars({
    Key? key,
    this.initialRating = 0,
    this.starCount = 5,
    this.starSize = 32,
    this.onRatingChanged,
    this.isInteractive = true,
    this.activeColor = AppColors.highlight,
    this.inactiveColor = AppColors.mediumGrey,
  }) : super(key: key);

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars>
    with SingleTickerProviderStateMixin {
  late double _rating;
  late AnimationController _animationController;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimations = List.generate(
      widget.starCount,
      (index) => Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index / widget.starCount,
            (index + 1) / widget.starCount,
            curve: Curves.elasticOut,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onStarTap(int index) {
    if (widget.isInteractive) {
      setState(() {
        _rating = index + 1.0;
      });
      _animationController.forward(from: 0.0);
      widget.onRatingChanged?.call(_rating);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        widget.starCount,
        (index) => ScaleTransition(
          scale: _scaleAnimations[index],
          child: GestureDetector(
            onTap: () => _onStarTap(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                index < _rating ? Icons.star_rounded : Icons.star_outline,
                color: index < _rating
                    ? widget.activeColor
                    : widget.inactiveColor,
                size: widget.starSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RatingDisplay extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double starSize;
  final TextStyle? ratingTextStyle;
  final TextStyle? countTextStyle;

  const RatingDisplay({
    Key? key,
    required this.rating,
    required this.reviewCount,
    this.starSize = 20,
    this.ratingTextStyle,
    this.countTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          color: AppColors.highlight,
          size: starSize,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: ratingTextStyle ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.surface,
              ),
        ),
        const SizedBox(width: 4),
        Text(
          '($reviewCount)',
          style: countTextStyle ??
              const TextStyle(
                fontSize: 12,
                color: AppColors.mediumGrey,
              ),
        ),
      ],
    );
  }
}

class RatingCard extends StatefulWidget {
  final String driverName;
  final String driverImage;
  final double driverRating;
  final int reviewCount;
  final ValueChanged<double>? onRatingSubmitted;
  final ValueChanged<String>? onReviewSubmitted;
  final VoidCallback? onTipPressed;

  const RatingCard({
    Key? key,
    required this.driverName,
    required this.driverImage,
    required this.driverRating,
    required this.reviewCount,
    this.onRatingSubmitted,
    this.onReviewSubmitted,
    this.onTipPressed,
  }) : super(key: key);

  @override
  State<RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<RatingCard> {
  double _userRating = 0;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Driver Info
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(widget.driverImage),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.driverName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.surface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RatingDisplay(
                      rating: widget.driverRating,
                      reviewCount: widget.reviewCount,
                      starSize: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Rating Question
          const Text(
            'How was your trip?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.surface,
            ),
          ),
          const SizedBox(height: 16),
          // Stars
          RatingStars(
            initialRating: _userRating,
            starSize: 40,
            onRatingChanged: (rating) {
              setState(() => _userRating = rating);
              widget.onRatingSubmitted?.call(rating);
            },
          ),
          const SizedBox(height: 24),
          // Review Text
          TextField(
            controller: _reviewController,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Share your experience (optional)',
              hintStyle: const TextStyle(color: AppColors.mediumGrey),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.mediumGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.mediumGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            style: const TextStyle(color: AppColors.surface),
            onChanged: (value) {
              widget.onReviewSubmitted?.call(value);
            },
          ),
          const SizedBox(height: 16),
          // Tip Button
          if (widget.onTipPressed != null)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTipPressed,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.card_giftcard, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Add Tip',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
