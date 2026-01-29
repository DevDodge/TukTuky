import 'package:flutter/material.dart';
import 'dart:ui';
import '../config/colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double opacity;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final bool isClickable;
  final Color? backgroundColor;
  final Border? border;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.opacity = 0.1,
    this.shadows,
    this.onTap,
    this.isClickable = false,
    this.backgroundColor,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.surface.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ??
                Border.all(
                  color: AppColors.surface.withOpacity(0.2),
                  width: 1,
                ),
            boxShadow: shadows ?? AppColors.cardShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isClickable ? onTap : null,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassBottomSheet extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsets padding;
  final double borderRadius;
  final String? title;
  final VoidCallback? onClose;

  const GlassBottomSheet({
    Key? key,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 24,
    this.title,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(borderRadius),
        topRight: Radius.circular(borderRadius),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.darkGrey.withOpacity(0.9),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(borderRadius),
              topRight: Radius.circular(borderRadius),
            ),
            border: Border(
              top: BorderSide(
                color: AppColors.surface.withOpacity(0.2),
                width: 1,
              ),
            ),
            boxShadow: AppColors.floatingShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.mediumGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.surface,
                        ),
                      ),
                      if (onClose != null)
                        GestureDetector(
                          onTap: onClose,
                          child: const Icon(
                            Icons.close,
                            color: AppColors.surface,
                          ),
                        ),
                    ],
                  ),
                ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: padding,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final Color? cancelColor;

  const GlassDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.cancelColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkGrey.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.surface.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: AppColors.elevatedShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.surface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Message
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumGrey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (cancelText != null)
                        Expanded(
                          child: TextButton(
                            onPressed: onCancel ??
                                () => Navigator.of(context).pop(false),
                            child: Text(
                              cancelText!,
                              style: TextStyle(
                                color: cancelColor ?? AppColors.mediumGrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      if (confirmText != null)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  confirmColor ?? AppColors.primary,
                            ),
                            onPressed: onConfirm ??
                                () => Navigator.of(context).pop(true),
                            child: Text(confirmText!),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
