import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:goalflow/widgets/ambient_watercolor_background.dart';
import 'package:goalflow/theme/app_theme.dart';

class WelcomeSplashScreen extends StatefulWidget {
  const WelcomeSplashScreen({super.key});

  @override
  State<WelcomeSplashScreen> createState() => _WelcomeSplashScreenState();
}

class _WelcomeSplashScreenState extends State<WelcomeSplashScreen> with TickerProviderStateMixin {
  late AnimationController _uiController;
  
  late Animation<Offset> _slideWelcomeAnimation;
  late Animation<Offset> _slideSubtextAnimation;
  late Animation<double> _fadeSubtextAnimation;
  late Animation<double> _fadeButtonAnimation;
  
  final String _fullWelcome = 'Welcome';
  late List<Animation<double>> _letterFades;

  @override
  void initState() {
    super.initState();

    _uiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Staggered letter fades
    _letterFades = [];
    final double letterStagger = 0.4 / _fullWelcome.length;
    for (int i = 0; i < _fullWelcome.length; i++) {
      _letterFades.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _uiController,
            curve: Interval(i * letterStagger, (i * letterStagger) + 0.2, curve: Curves.easeIn),
          ),
        ),
      );
    }

    _slideWelcomeAnimation = Tween<Offset>(begin: const Offset(0, 0.4), end: const Offset(0, 0)).animate(
      CurvedAnimation(parent: _uiController, curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart)),
    );

    _slideSubtextAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: const Offset(0, 0)).animate(
      CurvedAnimation(parent: _uiController, curve: const Interval(0.4, 0.8, curve: Curves.easeOutQuart)),
    );

    _fadeSubtextAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _uiController, curve: const Interval(0.5, 0.8, curve: Curves.easeIn)),
    );

    _fadeButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _uiController, curve: const Interval(0.7, 1.0, curve: Curves.easeIn)),
    );

    // Start immediately
    _uiController.forward();
  }

  @override
  void dispose() {
    _uiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF1E293B);

    return Theme(
      data: AppTheme.lightTheme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
                context.go('/ai-generation');
              }
            },
            child: AmbientWatercolorBackground(
              child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SlideTransition(
                  position: _slideWelcomeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_fullWelcome.length, (index) {
                      return FadeTransition(
                        opacity: _letterFades[index],
                        child: Text(
                          _fullWelcome[index],
                          style: TextStyle(
                            fontFamily: 'cursive',
                            fontStyle: FontStyle.italic,
                            fontSize: 70,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            height: 1.0,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                SlideTransition(
                  position: _slideSubtextAnimation,
                  child: FadeTransition(
                    opacity: _fadeSubtextAnimation,
                    child: Text(
                      'Your journey starts now. Let AI craft the perfect plan for you.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: textColor.withOpacity(0.75),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                const SizedBox(height: 56),
                
                FadeTransition(
                  opacity: _fadeButtonAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Swipe to reveal your plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor.withOpacity(0.5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_double_arrow_right_rounded,
                        size: 20,
                        color: textColor.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
      ),
      ),
    );
  }
}
