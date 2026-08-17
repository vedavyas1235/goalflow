import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:goalflow/widgets/ambient_watercolor_background.dart';
import 'package:goalflow/services/api_service.dart';
import 'package:goalflow/services/goal_provider.dart';
import 'package:goalflow/theme/app_theme.dart';

class AiGenerationScreen extends StatefulWidget {
  final Map<String, dynamic> onboardingData;
  const AiGenerationScreen({super.key, this.onboardingData = const {}});

  @override
  State<AiGenerationScreen> createState() => _AiGenerationScreenState();
}

class CustomTypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const CustomTypewriterText({super.key, required this.text, required this.style});

  @override
  State<CustomTypewriterText> createState() => _CustomTypewriterTextState();
}

class _CustomTypewriterTextState extends State<CustomTypewriterText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _textAnimation;

  @override
  void initState() {
    super.initState();
    // Fast typing speed based on text length (approx 15ms per char)
    final duration = Duration(milliseconds: widget.text.length * 15);
    
    _controller = AnimationController(vsync: this, duration: duration);
    _textAnimation = IntTween(begin: 0, end: widget.text.length).animate(_controller);
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _textAnimation,
      builder: (context, child) {
        String visibleString = widget.text.substring(0, _textAnimation.value);
        return Text(
          visibleString,
          style: widget.style,
        );
      },
    );
  }
}

class _AiGenerationScreenState extends State<AiGenerationScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isGenerating = true;
  bool _isNavigating = false;
  int _progressStepIndex = 0;
  Timer? _progressTimer;

  final List<String> _progressMessages = [
    'Analyzing your goal & core motivations...',
    'Evaluating schedule, available time & constraints...',
    'Synthesizing personalized 3-month milestone blueprint...',
    'Structuring complete 30-day daily actionable roadmap...',
    'Finalizing your customized strategy and daily tasks...',
  ];

  String _slide1Text = "";
  String _slide2Text = "";
  String _slide3Text = "";

  @override
  void initState() {
    super.initState();
    _startProgressTimer();
    _fetchAiData();
  }

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _isGenerating) {
        setState(() {
          _progressStepIndex = (_progressStepIndex + 1) % _progressMessages.length;
        });
      }
    });
  }
  
  Future<void> _fetchAiData() async {
    try {
      final result = await ApiService().generateAIOnboarding(widget.onboardingData);
      final slides = result['slides'];
      
      if (slides != null && slides is Map) {
        _slide1Text = "${slides['slide1']?['title'] ?? 'Overview'}\n\n${slides['slide1']?['content'] ?? ''}";
        _slide2Text = "${slides['slide2']?['title'] ?? 'Details'}\n\n${slides['slide2']?['content'] ?? ''}";
        _slide3Text = "${slides['slide3']?['title'] ?? 'Roadmap'}\n\n${slides['slide3']?['content'] ?? ''}";
      } else {
        _slide1Text = "STRENGTHS & WEAKNESSES\n\nFailed to parse JSON slides properly.";
        _slide2Text = "TIME TO COMPLETE\n\nThe AI format was corrupted.";
        _slide3Text = "YOUR CUSTOM PLAN\n\nPlease try again.";
      }
    } catch (e) {
      _slide1Text = "STRENGTHS & WEAKNESSES\n\nError connecting to AI.\n\nUsing fallback data.";
      _slide2Text = "TIME TO COMPLETE\n\nEnsure your backend is running and OpenRouter API key is set.";
      _slide3Text = "YOUR CUSTOM PLAN\n\nSwipe to enter Dashboard and try again later.";
      print('AI Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent, duration: const Duration(seconds: 10)),
        );
      }
    }

    _progressTimer?.cancel();
    if (mounted) {
      setState(() => _isGenerating = false);
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      await ApiService.setOnboardingCompleted(true);
      await ApiService.clearOnboardingDraft();
      if (mounted) {
        Provider.of<GoalProvider>(context, listen: false).fetchGoals();
        context.go('/home');
      }
    }
  }

  Widget _buildSlideText(String content) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: CustomTypewriterText(
        text: content,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildSlide1() {
    return _buildSlideText(_slide1Text);
  }

  Widget _buildSlide2() {
    return _buildSlideText(_slide2Text);
  }

  Widget _buildSlide3() {
    return _buildSlideText(_slide3Text);
  }

  @override
  Widget build(BuildContext context) {
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
            if (!_isGenerating && _currentIndex > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOutCubic,
              );
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: AmbientWatercolorBackground(
              child: SafeArea(
                child: _isGenerating
                    ? _buildGeneratingState()
                    : Column(
                        children: [
                          const SizedBox(height: 20),
                          // Progress Indicator
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                        child: Row(
                          children: List.generate(
                            3,
                            (index) => Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 5,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: _currentIndex >= index
                                      ? const Color(0xFF1E293B)
                                      : Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Slides
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const BouncingScrollPhysics(),
                          onPageChanged: (index) async {
                            if (index == 3) {
                              await ApiService.setOnboardingCompleted(true);
                              await ApiService.clearOnboardingDraft();
                              if (context.mounted) {
                                Provider.of<GoalProvider>(context, listen: false).fetchGoals();
                                context.go('/home');
                              }
                            } else {
                              setState(() {
                                _currentIndex = index;
                              });
                            }
                          },
                          children: [
                            _buildSlide1(),
                            _buildSlide2(),
                            _buildSlide3(),
                            const SizedBox(), // Restore Dummy Slide for Dashboard Swipe
                          ],
                        ),
                      ),
                      
                      // Action Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
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
                              onTap: _nextPage,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentIndex == 2 ? 'Enter Dashboard' : 'Next Insight',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      _currentIndex == 2 ? Icons.check_circle_outline_rounded : Icons.arrow_forward_rounded,
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
    );
  }

  Widget _buildGeneratingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Container(
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E293B).withOpacity(0.06),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'AI is Crafting Your Plan...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Text(
                  _progressMessages[_progressStepIndex],
                  key: ValueKey<int>(_progressStepIndex),
                  style: const TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B), 
                    height: 1.5
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
