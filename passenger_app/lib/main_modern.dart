import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/theme_global.dart';
import 'config/router.dart';
import 'config/colors.dart';
import 'providers/localization_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  await NotificationService().initialize();
  
  runApp(const ProviderScope(child: TukTukyApp()));
}

/// Main TukTuky Application with Complete i18n and Modern Design
class TukTukyApp extends ConsumerWidget {
  const TukTukyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch locale changes
    final locale = ref.watch(localizationProvider);

    return MaterialApp.router(
      // ========================================================================
      // APP CONFIGURATION
      // ========================================================================
      title: 'TukTuky',
      debugShowCheckedModeBanner: false,
      
      // ========================================================================
      // THEME CONFIGURATION WITH GLOBAL FONT FAMILY
      // ========================================================================
      theme: AppThemeGlobal.buildThemeData(locale),
      darkTheme: AppThemeGlobal.buildThemeData(locale),
      themeMode: ThemeMode.dark,

      // ========================================================================
      // LOCALIZATION CONFIGURATION
      // ========================================================================
      locale: locale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],

      // ========================================================================
      // TEXT DIRECTION (RTL for Arabic)
      // ========================================================================
      builder: (context, child) {
        return Directionality(
          textDirection: locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },

      // ========================================================================
      // ROUTING CONFIGURATION
      // ========================================================================
      routerConfig: router,

      // ========================================================================
      // HOME PAGE
      // ========================================================================
      home: const SplashScreenModern(),

      // ========================================================================
      // SCROLL BEHAVIOR
      // ========================================================================
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
      ),

      // ========================================================================
      // SHORTCUTS AND ACTIONS
      // ========================================================================
      shortcuts: {
        SingleActivator(LogicalKeyboardKey.escape): const DismissIntent(),
      },
      actions: {
        DismissIntent: CallbackAction<DismissIntent>(
          onInvoke: (intent) {
            Navigator.of(context).maybePop();
            return null;
          },
        ),
      },
    );
  }
}

/// Splash Screen with Modern Design
class SplashScreenModern extends StatefulWidget {
  const SplashScreenModern({Key? key}) : super(key: key);

  @override
  State<SplashScreenModern> createState() => _SplashScreenModernState();
}

class _SplashScreenModernState extends State<SplashScreenModern>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateToHome();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.background,
                AppColors.background.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_taxi,
                        color: Colors.black,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // App name with animation
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Column(
                    children: [
                      Text(
                        'TukTuky',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Ride, Your Way',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 64),

                // Loading indicator
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// APP EXTENSIONS FOR EASY LOCALIZATION ACCESS
/// ============================================================================

extension LocalizationExtension on BuildContext {
  /// Get localization instance
  AppLocalizations get l10n {
    return Localizations.of<AppLocalizations>(this, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  /// Check if RTL
  bool get isRTL {
    return Directionality.of(this) == TextDirection.rtl;
  }

  /// Get text direction
  TextDirection get textDirection {
    return Directionality.of(this);
  }

  /// Get current locale
  Locale get currentLocale {
    return Localizations.localeOf(this);
  }
}

/// ============================================================================
/// THEME EXTENSION FOR EASY ACCESS
/// ============================================================================

extension ThemeExtension on BuildContext {
  /// Get theme data
  ThemeData get theme {
    return Theme.of(this);
  }

  /// Get text theme
  TextTheme get textTheme {
    return Theme.of(this).textTheme;
  }

  /// Get color scheme
  ColorScheme get colorScheme {
    return Theme.of(this).colorScheme;
  }

  /// Get primary color
  Color get primaryColor {
    return Theme.of(this).primaryColor;
  }

  /// Get scaffold background color
  Color get scaffoldBackgroundColor {
    return Theme.of(this).scaffoldBackgroundColor;
  }
}

/// ============================================================================
/// MEDIA QUERY EXTENSION FOR RESPONSIVE DESIGN
/// ============================================================================

extension MediaQueryExtension on BuildContext {
  /// Get screen size
  Size get screenSize {
    return MediaQuery.of(this).size;
  }

  /// Get screen width
  double get screenWidth {
    return MediaQuery.of(this).size.width;
  }

  /// Get screen height
  double get screenHeight {
    return MediaQuery.of(this).size.height;
  }

  /// Get device padding
  EdgeInsets get devicePadding {
    return MediaQuery.of(this).padding;
  }

  /// Get device view insets
  EdgeInsets get deviceViewInsets {
    return MediaQuery.of(this).viewInsets;
  }

  /// Check if device is in landscape
  bool get isLandscape {
    return MediaQuery.of(this).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait
  bool get isPortrait {
    return MediaQuery.of(this).orientation == Orientation.portrait;
  }

  /// Check if small screen
  bool get isSmallScreen {
    return screenWidth < 600;
  }

  /// Check if medium screen
  bool get isMediumScreen {
    return screenWidth >= 600 && screenWidth < 900;
  }

  /// Check if large screen
  bool get isLargeScreen {
    return screenWidth >= 900;
  }

  /// Get device pixel ratio
  double get devicePixelRatio {
    return MediaQuery.of(this).devicePixelRatio;
  }

  /// Check if device has notch
  bool get hasNotch {
    return MediaQuery.of(this).padding.top > 24;
  }
}
