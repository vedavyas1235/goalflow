import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goalflow/services/api_service.dart';
import 'package:goalflow/widgets/ambient_watercolor_background.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({super.key});

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  final _wellController = TextEditingController();
  final _difficultController = TextEditingController();
  final _improveController = TextEditingController();

  // Reflection is available — unlocked for demo
  final bool _isReflectionDay = true;

  @override
  void dispose() {
    _wellController.dispose();
    _difficultController.dispose();
    _improveController.dispose();
    super.dispose();
  }

  Widget _buildTextField(BuildContext context, String label, String hint, TextEditingController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16)),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          maxLines: 3,
          style: TextStyle(color: textColor, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0xFF64748B).withOpacity(0.5)),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.white.withOpacity(0.8),
            contentPadding: const EdgeInsets.all(20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: textColor, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(BuildContext context, String value, String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AmbientWatercolorBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 80,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
                title: Text(
                  'Weekly Reflection',
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stats Summary
                    Text('This Week\'s Output', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatBox(context, '18', 'Completed', Colors.green),
                        const SizedBox(width: 12),
                        _buildStatBox(context, '3', 'Missed', Colors.redAccent),
                        const SizedBox(width: 12),
                        _buildStatBox(context, '85%', 'Progress', isDark ? Colors.blueAccent : const Color(0xFF1E293B)),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Reflection Questions
                    Text('Self Reflection', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
                    const SizedBox(height: 24),
                    
                    _buildTextField(
                      context,
                      'What went well this week?',
                      'e.g. I was very consistent with my morning reading...',
                      _wellController,
                    ),
                    const SizedBox(height: 24),
                    
                    _buildTextField(
                      context,
                      'What made things difficult?',
                      'e.g. I struggled to find time after work...',
                      _difficultController,
                    ),
                    const SizedBox(height: 24),
                    
                    _buildTextField(
                      context,
                      'What would you like to improve next week?',
                      'e.g. I will try to wake up 30 minutes earlier...',
                      _improveController,
                    ),
                    const SizedBox(height: 40),

                    // Save Button
                    GestureDetector(
                      onTap: () async {
                        if (_wellController.text.trim().isEmpty || _difficultController.text.trim().isEmpty || _improveController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please answer all 3 reflection questions.'), backgroundColor: Colors.redAccent),
                          );
                          return;
                        }

                        // Show AI synthesis loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            content: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(color: isDark ? Colors.white : const Color(0xFF1E293B)),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Synthesizing your journey...',
                                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'AI is creating your weekly log',
                                    style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );

                        // Call backend AI to synthesize the reflection
                        String? aiSummary;
                        try {
                          aiSummary = await ApiService().synthesizeReflection(
                            well: _wellController.text.trim(),
                            difficult: _difficultController.text.trim(),
                            improve: _improveController.text.trim(),
                          );
                        } catch (e) {
                          print('synthesizeReflection error: $e');
                        }

                        final finalSummary = (aiSummary != null && aiSummary.isNotEmpty)
                            ? aiSummary
                            : "Progress & Momentum:\n${_wellController.text.trim()}\n\nObstacles Encountered:\n${_difficultController.text.trim()}\n\nFocus Strategy for Next Week:\n${_improveController.text.trim()}";

                        // Save real AI synthesized reflection to SharedPreferences
                        try {
                          final prefs = await SharedPreferences.getInstance();
                          final existingJson = prefs.getString('saved_journey_reflections');
                          List<dynamic> list = existingJson != null ? json.decode(existingJson) : [];
                          final now = DateTime.now();
                          final dateStr = 'Week ${list.length + 1}: ${now.day}/${now.month}/${now.year}';
                          list.insert(0, {
                            'date': dateStr,
                            'summary': finalSummary,
                            'monthIndex': 0,
                          });
                          await prefs.setString('saved_journey_reflections', json.encode(list));
                        } catch (e) {
                          print('Error saving reflection: $e');
                        }

                        if (context.mounted) {
                          context.pop(); // Close dialog
                          context.pushReplacement('/reflection-log'); // Go to log
                        }
                      },
                      child: Opacity(
                        opacity: _isReflectionDay ? 1.0 : 0.5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: _isReflectionDay ? textColor : Colors.grey,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: _isReflectionDay ? [BoxShadow(color: textColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))] : [],
                          ),
                          child: Center(
                            child: Text(
                              _isReflectionDay ? 'Save Reflection' : 'Unavailable Today',
                              style: TextStyle(
                                color: Theme.of(context).scaffoldBackgroundColor, 
                                fontSize: 18, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
