import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:goalflow/widgets/ambient_watercolor_background.dart';
import 'package:goalflow/services/api_service.dart';
import 'package:goalflow/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Controllers for text inputs to preserve user typing
  late final TextEditingController _nameController;
  late final TextEditingController _mainObjectiveController;
  late final TextEditingController _firstGoalTitleController;
  late final TextEditingController _detailedDescriptionController;
  late final TextEditingController _workingFrequencyController;
  late final TextEditingController _constraintsController;

  late final FocusNode _nameFocusNode;
  late final FocusNode _mainObjectiveFocusNode;
  late final FocusNode _firstGoalTitleFocusNode;
  late final FocusNode _detailedDescriptionFocusNode;
  late final FocusNode _workingFrequencyFocusNode;
  late final FocusNode _constraintsFocusNode;

  // Onboarding Data State
  String timeframe = '3 Months';
  String category = 'Learning';
  String priority = 'High';
  
  // Routine Data
  List<String> preferredDays = ['Mon', 'Wed', 'Fri'];
  String preferredTime = 'Morning';
  String targetDuration = '30 mins';
  
  // Personalization
  String progressStyle = 'Strict';
  String reminderPref = 'Daily Reminders';
  int selectedAvatarIndex = 0;

  // Custom Fields
  String customTimeframe = '';
  String customStartTime = '';
  String customEndTime = '';
  String customTargetDuration = '';

  final List<Map<String, dynamic>> avatarProfiles = [
    {'icon': Icons.face_rounded, 'name': 'Achiever'},
    {'icon': Icons.sentiment_very_satisfied_rounded, 'name': 'Optimist'},
    {'icon': Icons.rocket_launch_rounded, 'name': 'Pioneer'},
    {'icon': Icons.local_fire_department_rounded, 'name': 'Relentless'},
    {'icon': Icons.spa_rounded, 'name': 'Mindful'},
  ];

  final List<IconData> avatarIcons = [
    Icons.face_rounded,
    Icons.sentiment_very_satisfied_rounded,
    Icons.rocket_launch_rounded,
    Icons.local_fire_department_rounded,
    Icons.spa_rounded,
  ];

  final List<String> categories = [
    'Learning',
    'Health',
    'Career',
    'Personal',
    'Finance',
    'Productivity',
    'Relationships',
    'Custom'
  ];

  final Map<String, IconData> categoryIcons = {
    'Learning': Icons.school_outlined,
    'Health': Icons.favorite_outline_rounded,
    'Career': Icons.work_outline_rounded,
    'Personal': Icons.self_improvement_rounded,
    'Finance': Icons.account_balance_wallet_outlined,
    'Productivity': Icons.bolt_rounded,
    'Relationships': Icons.groups_outlined,
    'Custom': Icons.tune_rounded,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: ApiService.currentUserData?['name'] ?? '');
    _mainObjectiveController = TextEditingController();
    _firstGoalTitleController = TextEditingController();
    _detailedDescriptionController = TextEditingController();
    _workingFrequencyController = TextEditingController(text: '3 times a week');
    _constraintsController = TextEditingController();

    _nameFocusNode = FocusNode()..addListener(() => setState(() {}));
    _mainObjectiveFocusNode = FocusNode()..addListener(() => setState(() {}));
    _firstGoalTitleFocusNode = FocusNode()..addListener(() => setState(() {}));
    _detailedDescriptionFocusNode = FocusNode()..addListener(() => setState(() {}));
    _workingFrequencyFocusNode = FocusNode()..addListener(() => setState(() {}));
    _constraintsFocusNode = FocusNode()..addListener(() => setState(() {}));

    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final draft = await ApiService.loadOnboardingDraft();
    if (draft != null && mounted) {
      setState(() {
        if (draft['name'] != null && (draft['name'] as String).isNotEmpty) {
          _nameController.text = draft['name'];
        }
        if (draft['mainObjective'] != null) {
          _mainObjectiveController.text = draft['mainObjective'];
        }
        if (draft['firstGoalTitle'] != null) {
          _firstGoalTitleController.text = draft['firstGoalTitle'];
        }
        if (draft['detailedDescription'] != null) {
          _detailedDescriptionController.text = draft['detailedDescription'];
        }
        if (draft['workingFrequency'] != null) {
          _workingFrequencyController.text = draft['workingFrequency'];
        }
        if (draft['constraints'] != null) {
          _constraintsController.text = draft['constraints'];
        }
        timeframe = draft['timeframe'] ?? '3 Months';
        category = draft['category'] ?? 'Learning';
        priority = draft['priority'] ?? 'High';
        if (draft['preferredDays'] != null) {
          preferredDays = List<String>.from(draft['preferredDays']);
        }
        preferredTime = draft['preferredTime'] ?? 'Morning';
        targetDuration = draft['targetDuration'] ?? '30 mins';
        progressStyle = draft['progressStyle'] ?? 'Strict';
        reminderPref = draft['reminderPref'] ?? 'Daily Reminders';
        selectedAvatarIndex = draft['selectedAvatarIndex'] ?? 0;
      });
    }
  }

  void _saveDraft() {
    ApiService.saveOnboardingDraft({
      'name': _nameController.text,
      'mainObjective': _mainObjectiveController.text,
      'firstGoalTitle': _firstGoalTitleController.text,
      'detailedDescription': _detailedDescriptionController.text,
      'timeframe': timeframe,
      'category': category,
      'priority': priority,
      'preferredDays': preferredDays,
      'preferredTime': preferredTime,
      'targetDuration': targetDuration,
      'workingFrequency': _workingFrequencyController.text,
      'constraints': _constraintsController.text,
      'progressStyle': progressStyle,
      'reminderPref': reminderPref,
      'selectedAvatarIndex': selectedAvatarIndex,
      'currentIndex': _currentIndex,
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mainObjectiveController.dispose();
    _firstGoalTitleController.dispose();
    _detailedDescriptionController.dispose();
    _workingFrequencyController.dispose();
    _constraintsController.dispose();
    _nameFocusNode.dispose();
    _mainObjectiveFocusNode.dispose();
    _firstGoalTitleFocusNode.dispose();
    _detailedDescriptionFocusNode.dispose();
    _workingFrequencyFocusNode.dispose();
    _constraintsFocusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    // Validation Logic
    if (_currentIndex == 0 && (_nameController.text.trim().isEmpty || _mainObjectiveController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text('Please fill in your Name and Main Objective.')),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      return;
    }
    
    if (_currentIndex == 1 && _firstGoalTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text('Please enter your Goal Title.')),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      return;
    }

    if (_currentIndex == 2 && _detailedDescriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text('Please provide a detailed description of your goal motivations.')),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      return;
    }

    _saveDraft();

    if (_currentIndex < 4) {
      setState(() => _currentIndex++);
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Pass data to the Welcome screen
      context.go('/welcome', extra: {
        'name': _nameController.text.trim(),
        'mainObjective': _mainObjectiveController.text.trim(),
        'goalTitle': _firstGoalTitleController.text.trim(),
        'category': category,
        'timeframe': timeframe,
        'priority': priority,
        'detailedDescription': _detailedDescriptionController.text.trim(),
        'preferredTime': preferredTime,
        'targetDuration': targetDuration,
        'workingFrequency': _workingFrequencyController.text.trim(),
        'preferredDays': preferredDays.join(', '),
        'constraints': _constraintsController.text.trim(),
        'progressStyle': progressStyle,
        'reminderPref': reminderPref,
      });
    }
  }

  InputDecoration _inputDeco(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF64748B), size: 20) : null,
      filled: true,
      fillColor: Colors.white.withOpacity(0.75),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.9), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.9), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF1E293B), width: 1.5),
      ),
    );
  }

  InputDecoration _smallDeco(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
      filled: true,
      fillColor: Colors.white.withOpacity(0.75),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.9), width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.9), width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E293B), width: 1.5)),
    );
  }

  Widget _buildSmallNumberInput(String label) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: _smallDeco(label),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
    );
  }

  Future<void> _pickTime(BuildContext context, String currentVal, ValueChanged<String> onSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E293B),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (context.mounted) {
        final localizations = MaterialLocalizations.of(context);
        final formattedTime = localizations.formatTimeOfDay(picked, alwaysUse24HourFormat: false);
        onSelected(formattedTime);
        _saveDraft();
      }
    }
  }

  Widget _buildTimePickerField(String label, String value, VoidCallback onTap) {
    return TextFormField(
      key: ValueKey(value),
      initialValue: value,
      readOnly: true,
      onTap: onTap,
      decoration: _smallDeco(label, hint: '--:--'),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
    );
  }

  Widget _buildCard({required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildFieldTile({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    VoidCallback? onChanged,
  }) {
    final isFocused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFocused ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
          width: isFocused ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? const Color(0xFF6366F1).withOpacity(0.12)
                : const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: isFocused ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isFocused
                    ? const Color(0xFFEEF2FF)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFocused
                      ? const Color(0xFFC7D2FE)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Icon(
                icon,
                color: isFocused
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF64748B),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isFocused
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: keyboardType,
                    maxLines: maxLines,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: hintText,
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                    onChanged: (_) {
                      onChanged?.call();
                      _saveDraft();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(26.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.95), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.06),
              blurRadius: 36,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Badge & Icon
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_pin_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Step badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'STEP 1 OF 5 • DIGITAL IDENTITY',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4F46E5),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              'Who Are You?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Craft your digital identity to personalize your AI coaching experience.',
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 26),
            
            // Avatar Selector Header
            Row(
              children: [
                const Icon(Icons.palette_outlined, size: 16, color: Color(0xFF6366F1)),
                const SizedBox(width: 6),
                const Text(
                  'CHOOSE YOUR AVATAR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Avatar Options Row
            SizedBox(
              height: 94,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: avatarProfiles.length,
                itemBuilder: (context, index) {
                  final profile = avatarProfiles[index];
                  final isSelected = selectedAvatarIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedAvatarIndex = index);
                      _saveDraft();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.only(right: 12),
                      width: 76,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                              )
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.white, const Color(0xFFF8FAFC)],
                              ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF4F46E5).withOpacity(0.25),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                )
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            profile['icon'] as IconData,
                            size: 30,
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            profile['name'] as String,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Name Field Tile
            _buildFieldTile(
              label: 'Your Full Name',
              controller: _nameController,
              focusNode: _nameFocusNode,
              icon: Icons.badge_outlined,
              hintText: 'Enter your name',
            ),
            const SizedBox(height: 14),

            // Main Objective Field Tile
            _buildFieldTile(
              label: 'Core Life Objective',
              controller: _mainObjectiveController,
              focusNode: _mainObjectiveFocusNode,
              icon: Icons.auto_awesome_rounded,
              hintText: 'e.g. Master AI Engineering & Build a Startup',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstGoalStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(26.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.95), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.06),
              blurRadius: 36,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Badge & Icon
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Step badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'STEP 2 OF 5 • GOAL BLUEPRINT',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4F46E5),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              'Your First Big Goal',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Define the major milestone you want AI to break down for you.',
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Goal Title Field Tile
            _buildFieldTile(
              label: 'Goal Title',
              controller: _firstGoalTitleController,
              focusNode: _firstGoalTitleFocusNode,
              icon: Icons.lightbulb_outline_rounded,
              hintText: 'e.g. Learn Conversational Spanish',
            ),
            
            const SizedBox(height: 22),

            // Category Section Header
            Row(
              children: [
                const Icon(Icons.category_outlined, size: 16, color: Color(0xFF6366F1)),
                const SizedBox(width: 6),
                const Text(
                  'SELECT GOAL CATEGORY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category Cards Wrap
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final isSelected = category == cat;
                final icon = categoryIcons[cat] ?? Icons.label_outline_rounded;
                return GestureDetector(
                  onTap: () {
                    setState(() => category = cat);
                    _saveDraft();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.8 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFF4F46E5).withOpacity(0.18)
                              : const Color(0xFF0F172A).withOpacity(0.02),
                          blurRadius: isSelected ? 10 : 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color: isSelected ? Colors.white : const Color(0xFF4F46E5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            
            // Timeframe & Priority Cards
            Row(
              children: [
                // Timeframe Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF6366F1)),
                            const SizedBox(width: 5),
                            const Text(
                              'TIMEFRAME',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: timeframe,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 18),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            items: ['1 Month', '3 Months', '6 Months', '1 Year', 'Custom']
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => timeframe = val);
                                _saveDraft();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Priority Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFFEF4444)),
                            const SizedBox(width: 5),
                            const Text(
                              'PRIORITY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: priority,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 18),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            items: ['High', 'Medium', 'Standard']
                                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => priority = val);
                                _saveDraft();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (timeframe == 'Custom') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildSmallNumberInput('Years')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSmallNumberInput('Months')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSmallNumberInput('Days')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedDescriptionStep() {
    final isFocused = _detailedDescriptionFocusNode.hasFocus;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(26.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.95), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.06),
              blurRadius: 36,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Badge & Icon
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Step badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'STEP 3 OF 5 • CORE MOTIVATION',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4F46E5),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              'Detailed Description',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Why do you want to achieve this? Deep context allows AI to structure accurate daily habits.',
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Large Multi-line Field Tile
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isFocused ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                  width: isFocused ? 1.8 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isFocused
                        ? const Color(0xFF6366F1).withOpacity(0.12)
                        : const Color(0xFF0F172A).withOpacity(0.03),
                    blurRadius: isFocused ? 16 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isFocused ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isFocused ? const Color(0xFFC7D2FE) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Icon(
                            Icons.edit_note_rounded,
                            color: isFocused ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'WHY IS THIS GOAL ESSENTIAL TO YOU?',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: isFocused ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _detailedDescriptionController,
                      focusNode: _detailedDescriptionFocusNode,
                      maxLines: 6,
                      minLines: 4,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A),
                        height: 1.45,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: 'Share your background, what success looks like, and what drives you to accomplish this milestone...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFCBD5E1),
                          height: 1.4,
                        ),
                      ),
                      onChanged: (_) => _saveDraft(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Tip note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, size: 16, color: Color(0xFFF59E0B)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Required: AI uses these details to generate targeted milestones.',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(26.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.95), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.06),
              blurRadius: 36,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Badge & Icon
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.alarm_on_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Step badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'STEP 4 OF 5 • SCHEDULE & ROUTINE',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4F46E5),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              'Your Schedule & Routine',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Define when and how long you focus so AI schedules realistic habits.',
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Time of Day & Duration Cards (Side by side)
            Row(
              children: [
                // Preferred Time
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.wb_sunny_outlined, size: 14, color: Color(0xFF6366F1)),
                            SizedBox(width: 5),
                            Text(
                              'TIME OF DAY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: preferredTime,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 18),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            items: ['Morning', 'Afternoon', 'Evening', 'Custom']
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => preferredTime = val);
                                _saveDraft();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Duration
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 14, color: Color(0xFF10B981)),
                            SizedBox(width: 5),
                            Text(
                              'DURATION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: targetDuration,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 18),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            items: ['15 mins', '30 mins', '45 mins', '60 mins', 'Custom']
                                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => targetDuration = val);
                                _saveDraft();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (preferredTime == 'Custom') ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildTimePickerField('Start Time', customStartTime, () {
                      _pickTime(context, customStartTime, (time) => setState(() => customStartTime = time));
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimePickerField('End Time', customEndTime, () {
                      _pickTime(context, customEndTime, (time) => setState(() => customEndTime = time));
                    }),
                  ),
                ],
              ),
            ],
            if (targetDuration == 'Custom') ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _buildSmallNumberInput('Hours')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSmallNumberInput('Mins')),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Working Frequency Field Tile
            _buildFieldTile(
              label: 'Target Frequency',
              controller: _workingFrequencyController,
              focusNode: _workingFrequencyFocusNode,
              icon: Icons.repeat_rounded,
              hintText: 'e.g. 3 times a week',
            ),
            const SizedBox(height: 22),

            // Preferred Days Header
            const Row(
              children: [
                Icon(Icons.date_range_outlined, size: 16, color: Color(0xFF6366F1)),
                SizedBox(width: 6),
                Text(
                  'ACTIVE DAYS OF THE WEEK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Day Selector Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
                final isSelected = preferredDays.contains(day);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected ? preferredDays.remove(day) : preferredDays.add(day);
                    });
                    _saveDraft();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.8 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFF4F46E5).withOpacity(0.18)
                              : const Color(0xFF0F172A).withOpacity(0.02),
                          blurRadius: isSelected ? 10 : 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizationStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(26.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.95), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.06),
              blurRadius: 36,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Badge & Icon
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Step badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'STEP 5 OF 5 • AI COACH CONFIG',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4F46E5),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              'Personalization',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'AI uses these constraints & accountability styles to craft your ideal roadmap.',
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Personal Constraints Field Tile
            _buildFieldTile(
              label: 'Personal Constraints (Optional)',
              controller: _constraintsController,
              focusNode: _constraintsFocusNode,
              icon: Icons.flight_takeoff_rounded,
              hintText: 'e.g. Travel frequently, free mostly on weekends',
            ),
            const SizedBox(height: 20),

            // Tracking Style Section Header
            const Row(
              children: [
                Icon(Icons.insights_rounded, size: 16, color: Color(0xFF6366F1)),
                SizedBox(width: 6),
                Text(
                  'ACCOUNTABILITY STYLE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tracking Style Selection Cards (Strict vs Flexible)
            Row(
              children: [
                // Strict Card
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => progressStyle = 'Strict');
                      _saveDraft();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: progressStyle == 'Strict'
                            ? const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)])
                            : null,
                        color: progressStyle == 'Strict' ? null : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: progressStyle == 'Strict' ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                          width: progressStyle == 'Strict' ? 1.8 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: progressStyle == 'Strict'
                                ? const Color(0xFF4F46E5).withOpacity(0.18)
                                : const Color(0xFF0F172A).withOpacity(0.02),
                            blurRadius: progressStyle == 'Strict' ? 10 : 4,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.gavel_rounded,
                                size: 18,
                                color: progressStyle == 'Strict' ? Colors.white : const Color(0xFF4F46E5),
                              ),
                              const Spacer(),
                              if (progressStyle == 'Strict')
                                const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF10B981)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Strict',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: progressStyle == 'Strict' ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Rigid discipline, streak lock',
                            style: TextStyle(
                              fontSize: 11,
                              color: progressStyle == 'Strict' ? Colors.white.withOpacity(0.7) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Flexible Card
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => progressStyle = 'Flexible');
                      _saveDraft();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: progressStyle == 'Flexible'
                            ? const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)])
                            : null,
                        color: progressStyle == 'Flexible' ? null : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: progressStyle == 'Flexible' ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                          width: progressStyle == 'Flexible' ? 1.8 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: progressStyle == 'Flexible'
                                ? const Color(0xFF4F46E5).withOpacity(0.18)
                                : const Color(0xFF0F172A).withOpacity(0.02),
                            blurRadius: progressStyle == 'Flexible' ? 10 : 4,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.spa_rounded,
                                size: 18,
                                color: progressStyle == 'Flexible' ? Colors.white : const Color(0xFF10B981),
                              ),
                              const Spacer(),
                              if (progressStyle == 'Flexible')
                                const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF10B981)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Flexible',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: progressStyle == 'Flexible' ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Adaptive buffer & pacing',
                            style: TextStyle(
                              fontSize: 11,
                              color: progressStyle == 'Flexible' ? Colors.white.withOpacity(0.7) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Reminders Section Header
            const Row(
              children: [
                Icon(Icons.notifications_outlined, size: 16, color: Color(0xFF6366F1)),
                SizedBox(width: 6),
                Text(
                  'REMINDER CADENCE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Reminders Dropdown Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: reminderPref,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  items: ['Daily Reminders', 'Milestone Only', 'Gentle Nudges']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => reminderPref = val);
                      _saveDraft();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      if (ApiService.currentUserId != null) {
        context.go('/home');
      } else {
        context.go('/register');
      }
    }
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
            _handleBack();
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: AmbientWatercolorBackground(
              child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
                        onPressed: _handleBack,
                        tooltip: 'Back',
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Row(
                          children: List.generate(
                            5,
                            (index) => Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 5,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  color: _currentIndex >= index
                                      ? const Color(0xFF1E293B)
                                      : Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: _currentIndex >= index
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF1E293B).withOpacity(0.2),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : [],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Users CANNOT swipe past validation
                    children: [
                      _buildIdentityStep(),
                      _buildFirstGoalStep(),
                      _buildDetailedDescriptionStep(),
                      _buildRoutineStep(),
                      _buildPersonalizationStep(),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
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
                                _currentIndex == 4 ? 'Build My Plan with AI' : 'Next Step',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentIndex == 4 ? Icons.auto_awesome_rounded : Icons.arrow_forward_rounded,
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
}
