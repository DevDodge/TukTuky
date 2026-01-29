import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../config/modern_theme.dart';

/// ============================================================================
/// SWIPE DETECTOR - Detect swipe gestures
/// ============================================================================
class SwipeDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final double swipeThreshold;
  final Duration swipeDuration;

  const SwipeDetector({
    Key? key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.swipeThreshold = 50,
    this.swipeDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<SwipeDetector> createState() => _SwipeDetectorState();
}

class _SwipeDetectorState extends State<SwipeDetector> {
  late Offset _initialPosition;
  late DateTime _initialTime;

  void _onPanStart(DragStartDetails details) {
    _initialPosition = details.globalPosition;
    _initialTime = DateTime.now();
  }

  void _onPanEnd(DragEndDetails details) {
    final now = DateTime.now();
    final timeDiff = now.difference(_initialTime);

    if (timeDiff.compareTo(widget.swipeDuration) > 0) {
      return;
    }

    final dx = details.globalPosition.dx - _initialPosition.dx;
    final dy = details.globalPosition.dy - _initialPosition.dy;

    if (dx.abs() > dy.abs()) {
      if (dx > widget.swipeThreshold) {
        widget.onSwipeRight?.call();
      } else if (dx < -widget.swipeThreshold) {
        widget.onSwipeLeft?.call();
      }
    } else {
      if (dy > widget.swipeThreshold) {
        widget.onSwipeDown?.call();
      } else if (dy < -widget.swipeThreshold) {
        widget.onSwipeUp?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanEnd: _onPanEnd,
      child: widget.child,
    );
  }
}

/// ============================================================================
/// LONG PRESS DETECTOR - Detect long press with haptic feedback
/// ============================================================================
class HapticLongPressDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onLongPress;
  final Duration duration;
  final bool enableHaptic;

  const HapticLongPressDetector({
    Key? key,
    required this.child,
    required this.onLongPress,
    this.duration = const Duration(milliseconds: 500),
    this.enableHaptic = true,
  }) : super(key: key);

  @override
  State<HapticLongPressDetector> createState() =>
      _HapticLongPressDetectorState();
}

class _HapticLongPressDetectorState extends State<HapticLongPressDetector> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        if (widget.enableHaptic) {
          await ModernTheme.hapticMedium();
        }
        widget.onLongPress();
      },
      onLongPressStart: (_) {
        setState(() => _isPressed = true);
      },
      onLongPressEnd: (_) {
        setState(() => _isPressed = false);
      },
      child: Opacity(
        opacity: _isPressed ? 0.7 : 1,
        child: widget.child,
      ),
    );
  }
}

/// ============================================================================
/// PULL TO REFRESH - Modern pull-to-refresh with haptic feedback
/// ============================================================================
class ModernPullToRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color backgroundColor;
  final bool enableHaptic;

  const ModernPullToRefresh({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.backgroundColor = AppColors.background,
    this.enableHaptic = true,
  }) : super(key: key);

  @override
  State<ModernPullToRefresh> createState() => _ModernPullToRefreshState();
}

class _ModernPullToRefreshState extends State<ModernPullToRefresh> {
  late RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    try {
      if (widget.enableHaptic) {
        await ModernTheme.hapticLight();
      }
      await widget.onRefresh();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _onRefresh();
      },
      backgroundColor: AppColors.darkGrey,
      color: AppColors.primary,
      child: widget.child,
    );
  }
}

/// ============================================================================
/// SCALE BUTTON - Button with scale animation and haptic feedback
/// ============================================================================
class ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double scale;
  final Duration duration;
  final bool enableHaptic;
  final HapticFeedbackType hapticType;

  const ScaleButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.scale = 0.95,
    this.duration = const Duration(milliseconds: 150),
    this.enableHaptic = true,
    this.hapticType = HapticFeedbackType.light,
  }) : super(key: key);

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _onPressed() async {
    if (widget.enableHaptic) {
      switch (widget.hapticType) {
        case HapticFeedbackType.light:
          await ModernTheme.hapticLight();
          break;
        case HapticFeedbackType.medium:
          await ModernTheme.hapticMedium();
          break;
        case HapticFeedbackType.heavy:
          await ModernTheme.hapticHeavy();
          break;
        case HapticFeedbackType.selection:
          await ModernTheme.hapticSelection();
          break;
      }
    }
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onPressed,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: widget.scale).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        ),
        child: widget.child,
      ),
    );
  }
}

enum HapticFeedbackType { light, medium, heavy, selection }

/// ============================================================================
/// SLIDE ANIMATION - Slide-in animation for widgets
/// ============================================================================
class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset begin;
  final Curve curve;

  const SlideInAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.begin = const Offset(0, 0.3),
    this.curve = Curves.easeOut,
  }) : super(key: key);

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _offsetAnimation = Tween<Offset>(begin: widget.begin, end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _offsetAnimation, child: widget.child);
  }
}

/// ============================================================================
/// FADE IN ANIMATION - Fade-in animation for widgets
/// ============================================================================
class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const FadeInAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOut,
  }) : super(key: key);

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _opacityAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacityAnimation, child: widget.child);
  }
}

/// ============================================================================
/// BOUNCE ANIMATION - Bounce animation for widgets
/// ============================================================================
class BounceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const BounceAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
  }) : super(key: key);

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}

/// ============================================================================
/// PULSING ANIMATION - Pulsing animation for widgets
/// ============================================================================
class PulsingAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minOpacity;

  const PulsingAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.minOpacity = 0.5,
  }) : super(key: key);

  @override
  State<PulsingAnimation> createState() => _PulsingAnimationState();
}

class _PulsingAnimationState extends State<PulsingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);
    _opacityAnimation = Tween<double>(begin: widget.minOpacity, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacityAnimation, child: widget.child);
  }
}

class RefreshController {
  final bool initialRefresh;

  RefreshController({this.initialRefresh = false});

  void refreshCompleted() {}
  void refreshFailed() {}
}
