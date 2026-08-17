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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: ApiService.currentUserData?['name'] ?? '');
    _mainObjectiveController = TextEditingController();
    _firstGoalTitleController = TextEditingController();
    _detailedDescriptionController = TextEditingController();
    _workingFrequencyController = TextEditingController(text: '3 times a week');
    _constraintsController = TextEditingController();

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
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    // Validation Logic
    if (_currentIndex == 0 && (_nameController.text.trim().isEmpty || _mainObjectiveController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in your Name and Main Objective.'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    
    if (_currentIndex == 1 && _firstGoalTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Goal Title.'), backgroundColor: Colors.redAccent),
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

  Widget _buildIdentityStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFffffff), Color(0xFFF8FAFC)],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withOpacity(0.06),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF3B82F6)],
              ).createShader(bounds),
              child: const Text(
                'Who Are You?',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Let\'s craft your digital identity.',
              style: TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            
            // Avatar Selector
            const Text('Choose Your Avatar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: avatarIcons.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedAvatarIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedAvatarIndex = index);
                      _saveDraft();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.only(right: 16),
                      width: isSelected ? 72 : 64,
                      height: isSelected ? 72 : 64,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1E293B), Color(0xFF334155)],
                              )
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.white, Colors.white.withOpacity(0.8)],
                              ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF1E293B).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                )
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                      ),
                      child: Icon(
                        avatarIcons[index],
                        size: isSelected ? 32 : 28,
                        color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 36),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Full Name',
                  labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: Icon(Icons.person_rounded, color: Color(0xFF1E293B)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                onChanged: (_) => _saveDraft(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: TextFormField(
                controller: _mainObjectiveController,
                decoration: const InputDecoration(
                  labelText: 'Main Life Objective',
                  hintText: 'e.g. Master a New Skill',
                  hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
                  labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: Icon(Icons.auto_awesome_rounded, color: Color(0xFF1E293B)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                onChanged: (_) => _saveDraft(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstGoalStep() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.track_changes_rounded, size: 48, color: Color(0xFF1E293B)),
          const SizedBox(height: 12),
          const Text(
            'Your First Big Goal',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          TextFormField(
            controller: _firstGoalTitleController,
            decoration: _inputDeco('Goal Title (e.g. Learn Spanish)', icon: Icons.flag_rounded),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            onChanged: (_) => _saveDraft(),
          ),
          
          const SizedBox(height: 20),
          const Text('Category:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) {
              final isSelected = category == cat;
              return ChoiceChip(
                label: Text(cat, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.w600, fontSize: 13)),
                selected: isSelected,
                selectedColor: const Color(0xFF1E293B),
                backgroundColor: Colors.white.withOpacity(0.7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: isSelected ? const Color(0xFF1E293B) : Colors.white.withOpacity(0.9)),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => category = cat);
                    _saveDraft();
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: timeframe,
                  decoration: _inputDeco('Timeframe'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  dropdownColor: Colors.white,
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
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: priority,
                  decoration: _inputDeco('Priority'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  dropdownColor: Colors.white,
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
    );
  }

  Widget _buildDetailedDescriptionStep() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.description_rounded, size: 48, color: Color(0xFF1E293B)),
          const SizedBox(height: 12),
          const Text(
            'Detailed Description',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Why do you want to achieve this? What is the core motivation behind this goal?',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          TextFormField(
            controller: _detailedDescriptionController,
            maxLines: 6,
            decoration: _inputDeco('Tell us more about your motivations...'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1E293B), height: 1.4),
            onChanged: (_) => _saveDraft(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineStep() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.calendar_month_rounded, size: 48, color: Color(0xFF1E293B)),
          const SizedBox(height: 12),
          const Text(
            'Your Schedule & Routine',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Define when and how long you focus.',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: preferredTime,
                  decoration: _inputDeco('Preferred Time'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  dropdownColor: Colors.white,
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
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: targetDuration,
                  decoration: _inputDeco('Duration'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  dropdownColor: Colors.white,
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
          if (preferredTime == 'Custom') ...[
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSmallNumberInput('Hours')),
                const SizedBox(width: 12),
                Expanded(child: _buildSmallNumberInput('Mins')),
              ],
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: _workingFrequencyController,
            decoration: _inputDeco('Frequency (e.g. 3 times a week)', icon: Icons.repeat_rounded),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            onChanged: (_) => _saveDraft(),
          ),
          const SizedBox(height: 18),
          const Text('Preferred Days:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
              final isSelected = preferredDays.contains(day);
              return FilterChip(
                label: Text(day, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold)),
                selected: isSelected,
                selectedColor: const Color(0xFF1E293B),
                backgroundColor: Colors.white.withOpacity(0.6),
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: isSelected ? const Color(0xFF1E293B) : Colors.white.withOpacity(0.8)),
                onSelected: (selected) {
                  setState(() {
                    selected ? preferredDays.add(day) : preferredDays.remove(day);
                  });
                  _saveDraft();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizationStep() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.tune_rounded, size: 48, color: Color(0xFF1E293B)),
          const SizedBox(height: 12),
          const Text(
            'Personalization',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'AI uses these constraints to craft your daily routine.',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _constraintsController,
            decoration: _inputDeco('Personal Constraints (e.g. Travel often)', icon: Icons.flight_takeoff_rounded),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            onChanged: (_) => _saveDraft(),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: progressStyle,
            decoration: _inputDeco('Tracking Style', icon: Icons.insights_rounded),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            dropdownColor: Colors.white,
            items: ['Strict', 'Flexible']
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => progressStyle = val);
                _saveDraft();
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: reminderPref,
            decoration: _inputDeco('Reminders', icon: Icons.notifications_rounded),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            dropdownColor: Colors.white,
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
        ],
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
