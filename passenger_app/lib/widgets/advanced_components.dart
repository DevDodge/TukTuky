import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/colors.dart';
import '../config/modern_theme.dart';

/// ============================================================================
/// SKELETON LOADER - Loading placeholder with shimmer effect
/// ============================================================================
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const SkeletonLoader({
    Key? key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
    this.isCircle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.mediumGrey.withOpacity(0.3),
      highlightColor: AppColors.mediumGrey.withOpacity(0.1),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: isCircle
              ? BorderRadius.circular(height / 2)
              : BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// ============================================================================
/// SKELETON CARD - Loading placeholder for cards
/// ============================================================================
class SkeletonCard extends StatelessWidget {
  final double height;
  final EdgeInsets padding;

  const SkeletonCard({
    Key? key,
    this.height = 120,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(ModernTheme.radiusL),
        border: Border.all(color: AppColors.mediumGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(width: 150, height: 16),
          const SizedBox(height: 12),
          SkeletonLoader(width: double.infinity, height: 14),
          const SizedBox(height: 8),
          SkeletonLoader(width: 200, height: 14),
        ],
      ),
    );
  }
}

/// ============================================================================
/// SKELETON PROFILE - Loading placeholder for profile screen
/// ============================================================================
class SkeletonProfile extends StatelessWidget {
  const SkeletonProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkGrey,
              borderRadius: BorderRadius.circular(ModernTheme.radiusL),
              border: Border.all(color: AppColors.mediumGrey),
            ),
            child: Row(
              children: [
                SkeletonLoader(width: 60, height: 60, isCircle: true),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(width: 150, height: 16),
                      const SizedBox(height: 8),
                      SkeletonLoader(width: 100, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Stats
          ...List.generate(3, (index) => SkeletonCard()),
        ],
      ),
    );
  }
}

/// ============================================================================
/// MODERN LOADING OVERLAY - Full-screen loading indicator
/// ============================================================================
class ModernLoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isDismissible;

  const ModernLoadingOverlay({
    Key? key,
    this.message,
    this.isDismissible = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => isDismissible,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.darkGrey,
              borderRadius: BorderRadius.circular(ModernTheme.radiusL),
              boxShadow: ModernTheme.shadowXl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    strokeWidth: 3,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: const TextStyle(
                      color: AppColors.surface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ModernLoadingOverlay(message: message),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// ============================================================================
/// MODERN TOAST - Elegant toast notification
/// ============================================================================
class ModernToast {
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = AppColors.primary,
    IconData? icon,
    bool isError = false,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 30,
        left: 16,
        right: 16,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: ModernTheme.durationM,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, (1 - value) * 100),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isError ? Colors.red : backgroundColor,
              borderRadius: BorderRadius.circular(ModernTheme.radiusM),
              boxShadow: ModernTheme.shadowL,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  static void success(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.acceptGreen,
      icon: Icons.check_circle,
    );
  }

  static void error(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
      isError: true,
    );
  }

  static void info(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.highlight,
      icon: Icons.info,
    );
  }
}

/// ============================================================================
/// MODERN SNACKBAR - Enhanced snackbar with actions
/// ============================================================================
class ModernSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
    Color backgroundColor = AppColors.primary,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isError ? Colors.red : backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernTheme.radiusM),
        ),
        elevation: 8,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onAction ?? () {},
                textColor: Colors.white,
              )
            : null,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.acceptGreen,
    );
  }

  static void error(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: Colors.red,
      isError: true,
    );
  }
}

/// ============================================================================
/// MODERN DIALOG - Elegant dialog with animations
/// ============================================================================
class ModernDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String? cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const ModernDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel,
    required this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1).animate(
          CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.easeOutBack,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkGrey,
            borderRadius: BorderRadius.circular(ModernTheme.radiusL),
            boxShadow: ModernTheme.shadowXl,
            border: Border.all(color: AppColors.mediumGrey),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.surface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.mediumGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (cancelLabel != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onCancel?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.mediumGrey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(ModernTheme.radiusM),
                          ),
                        ),
                        child: Text(
                          cancelLabel!,
                          style: const TextStyle(color: AppColors.surface),
                        ),
                      ),
                    ),
                  if (cancelLabel != null) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDestructive ? Colors.red : AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(ModernTheme.radiusM),
                        ),
                      ),
                      child: Text(
                        confirmLabel,
                        style: TextStyle(
                          color: isDestructive ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmLabel = 'Confirm',
    String? cancelLabel = 'Cancel',
    VoidCallback? onCancel,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => ModernDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDestructive: isDestructive,
      ),
    );
  }
}

/// ============================================================================
/// MODERN BOTTOM SHEET - Elegant bottom sheet with safe area
/// ============================================================================
class ModernBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isScrollable;
  final double maxHeight;

  const ModernBottomSheet({
    Key? key,
    required this.title,
    required this.child,
    this.isScrollable = true,
    this.maxHeight = 0.8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ModernTheme.radiusL),
        ),
        boxShadow: ModernTheme.shadowXl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.mediumGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.surface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.mediumGrey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Content
          Flexible(
            child: isScrollable
                ? SingleChildScrollView(child: child)
                : child,
          ),
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String title,
    required Widget child,
    bool isScrollable = true,
    double maxHeight = 0.8,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModernBottomSheet(
        title: title,
        child: child,
        isScrollable: isScrollable,
        maxHeight: maxHeight,
      ),
    );
  }
}

/// ============================================================================
/// SHIMMER EFFECT - Animated shimmer loading effect
/// ============================================================================
class ShimmerEffect extends StatelessWidget {
  final Widget child;

  const ShimmerEffect({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.mediumGrey.withOpacity(0.3),
      highlightColor: AppColors.mediumGrey.withOpacity(0.1),
      child: child,
    );
  }
}
