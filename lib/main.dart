import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/views.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:to_do_app/core/utils/state_notifier.dart';
import 'dart:io' show Platform;

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ThemeMode.light),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('darkMode') ?? false;

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith((ref) => ThemeModeNotifier(
          isDarkMode ? ThemeMode.dark : ThemeMode.light
        )),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.light(
          primary: AppColors.textPrimary,
          secondary: AppColors.textSecondary
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.cardBackground,
        dividerColor: Colors.black,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
            ),
      ),
      darkTheme: ThemeData(
        primaryColor: AppColors.dmPrimary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.dmTextPrimary,
          secondary: AppColors.dmTextSecondary
        ),
        scaffoldBackgroundColor: AppColors.dmBackground,
        cardColor: AppColors.dmCardBackground,
        dividerColor: Colors.white,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: AppColors.dmTextPrimary,
              displayColor: AppColors.dmTextPrimary,
            ),
      ),
      themeMode: themeMode,
      home: const MySplashScreen(page: MainPage()),
    );
  }
}


class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key, required this.page});

  final Widget page;

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late AnimationController _alignmentAnimationController;
  // ignore: unused_field
  late Animation<double> _fadeAnimation;
  late Animation<Alignment> _alignmentAnimation;

  @override
  void initState() {
    super.initState();

    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward(); // fade in/out movement
    
    _alignmentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true); // Loop gradient movement

    // Fade animation: goes from 0 (invisible) to 1 (fully visible)
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeInOut),
    );

    // Background animation: shift gradient from top-left to bottom-right
    _alignmentAnimation = AlignmentTween(
      begin: Alignment.topRight,
      end: Alignment.topLeft,
    ).animate(
      CurvedAnimation(parent: _alignmentAnimationController, curve: Curves.easeInOut),
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(const Duration(seconds:4), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => widget.page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );
            return FadeTransition(
              opacity: fadeAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    });
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _alignmentAnimationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  final String title = "Welcome.";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: Listenable.merge([_alignmentAnimationController, _fadeAnimationController]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.cardColor],
              begin: _alignmentAnimation.value,
              end: Alignment(-_alignmentAnimation.value.x, -_alignmentAnimation.value.y), // Opposite corner
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(title.length, (index) {
                final start = index / title.length;
                final end = (index + 1) / title.length;

                final animation = CurvedAnimation(
                  parent: _fadeAnimationController,
                  curve: Interval(start, end, curve: Curves.easeIn),
                );

                return FadeTransition(
                  opacity: animation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title[index],
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          decoration: TextDecoration.none
                        ),
                      )
                    ],
                  ),
                );
              })
            ),
          ),
        );
      },
    );
  }
}
