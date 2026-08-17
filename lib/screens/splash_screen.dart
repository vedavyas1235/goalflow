import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:goalflow/widgets/ambient_watercolor_background.dart';
import 'package:goalflow/theme/app_theme.dart';
import 'package:goalflow/services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _uiController;
  DateTime? _lastBackPress;
  
  late Animation<Offset> _slideHelloAnimation;
  late Animation<Offset> _slideQuoteAnimation;
  late Animation<double> _fadeQuoteAnimation;
  late Animation<double> _fadeButtonAnimation;

  final List<double> _letterOpacities = [0.0, 0.0, 0.0, 0.0, 0.0];
  final String _fullHello = 'hello';
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _uiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _slideHelloAnimation = Tween<Offset>(begin: const Offset(0, 1.2), end: const Offset(0, 0)).animate(
      CurvedAnimation(parent: _uiController, curve: const Interval(0.0, 0.3, curve: Curves.easeOutQuart)),
    );

    _slideQuoteAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: const Offset(0, 0)).animate(
      CurvedAnimation(parent: _uiController, curve: const Interval(0.2, 0.9, curve: Curves.easeOutQuart)),
    );

    _fadeQuoteAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _uiController, curve: const Interval(0.2, 0.9, curve: Curves.easeIn)),
    );

    _fadeButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _uiController, curve: const Interval(0.7, 1.0, curve: Curves.easeIn)),
    );

    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    for (int i = 0; i < _fullHello.length; i++) {
      if (mounted) {
        setState(() {
          _letterOpacities[i] = 1.0;
        });
      }
      await Future.delayed(const Duration(milliseconds: 250));
    }
    
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (mounted) {
      _uiController.forward();

      // If user is already logged in, auto-transition smoothly to /home
      if (ApiService.currentUserId != null) {
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted && !_hasNavigated) {
            _proceed();
          }
        });
      }
    }
  }

  void _proceed() {
    if (_hasNavigated) return;
    _hasNavigated = true;
    context.go('/onboarding');
  }

  @override
  void dispose() {
    _uiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF1E293B);
    final isLoggedIn = ApiService.currentUserId != null;

    return Theme(
      data: AppTheme.lightTheme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            final now = DateTime.now();
            if (_lastBackPress == null || now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
              _lastBackPress = now;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Press back again to exit GoalFlow'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            } else {
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _proceed,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
                  _proceed();
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
                          position: _slideHelloAnimation,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_fullHello.length, (index) {
                              return AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: _letterOpacities[index],
                                child: Text(
                                  _fullHello[index],
                                  style: const TextStyle(
                                    fontFamily: 'cursive',
                                    fontSize: 80,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    height: 1.0,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                        
                        SlideTransition(
                          position: _slideQuoteAnimation,
                          child: FadeTransition(
                            opacity: _fadeQuoteAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'A journey of a thousand miles begins with a single step.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: textColor.withOpacity(0.75),
                                    height: 1.5,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '— Lao Tzu',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor.withOpacity(0.4),
                                    letterSpacing: 1.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 56),
                        
                        FadeTransition(
                          opacity: _fadeButtonAnimation,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1E293B).withOpacity(0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: _proceed,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Continue',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
      ),
    );
  }
}
