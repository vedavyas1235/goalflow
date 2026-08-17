import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goalflow/widgets/ambient_watercolor_background.dart';

class ReflectionLogScreen extends StatefulWidget {
  const ReflectionLogScreen({super.key});

  @override
  State<ReflectionLogScreen> createState() => _ReflectionLogScreenState();
}

class _ReflectionLogScreenState extends State<ReflectionLogScreen> {
  int _selectedMonthIndex = 0;
  final int _totalMonths = 3;
  List<Map<String, String>> _realLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRealLogs();
  }

  Future<void> _loadRealLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('saved_journey_reflections');
      if (jsonStr != null) {
        final List<dynamic> raw = json.decode(jsonStr);
        _realLogs = raw.map((item) {
          String summary = item['summary']?.toString() ?? '';
          
          // Unescape newlines and quotes
          summary = summary.replaceAll(r'\n', '\n').replaceAll(r'\"', '"');

          // If JSON object format leaked, extract the inner summary
          if (summary.trim().startsWith('{') && summary.contains('"summary"')) {
            try {
              final parsed = json.decode(summary);
              if (parsed is Map && parsed['summary'] != null) {
                summary = parsed['summary'].toString();
              }
            } catch (_) {}
          }

          // If it was the old raw questionnaire fallback, clean it up into a clean summary
          if (summary.contains('Progress & Momentum:')) {
            final lines = summary
                .replaceAll('Progress & Momentum:', '')
                .replaceAll('Obstacles Encountered:', '')
                .replaceAll('Focus Strategy for Next Week:', '')
                .split('\n')
                .map((l) => l.trim())
                .where((l) => l.isNotEmpty)
                .join(' ');
            summary = 'Reflection Insights: $lines';
          }

          return {
            'date': item['date']?.toString() ?? 'Weekly Reflection',
            'summary': summary.trim(),
          };
        }).toList();
      }
    } catch (e) {
      print('Error loading reflections: $e');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteLog(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('saved_journey_reflections');
      if (jsonStr != null) {
        List<dynamic> list = json.decode(jsonStr);
        if (index >= 0 && index < list.length) {
          list.removeAt(index);
          await prefs.setString('saved_journey_reflections', json.encode(list));
          await _loadRealLogs();
        }
      }
    } catch (e) {
      print('Error deleting log: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    final currentLogs = _selectedMonthIndex == 0 ? _realLogs : <Map<String, String>>[];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AmbientWatercolorBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 24.0, top: 20.0, bottom: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Journey Echoes',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: -0.5),
                    ),
                  ],
                ),
              ),

              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Your AI-synthesized reflections over time.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),

              // Month Selector Strip
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _totalMonths,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedMonthIndex == index;
                    
                    // Determine month label
                    final String monthLabel;
                    switch (index) {
                      case 0: monthLabel = '1st Month'; break;
                      case 1: monthLabel = '2nd Month'; break;
                      case 2: monthLabel = '3rd Month'; break;
                      default: monthLabel = '${index + 1}th Month'; break;
                    }

                    return GestureDetector(
                      onTap: () => setState(() => _selectedMonthIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? textColor : (isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? textColor : (isDark ? Colors.white.withOpacity(0.1) : Colors.white), width: 2),
                          boxShadow: isSelected ? [BoxShadow(color: textColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
                        ),
                        child: Center(
                          child: Text(
                            monthLabel,
                            style: TextStyle(
                              color: isSelected ? Theme.of(context).scaffoldBackgroundColor : textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Logs List or Empty State
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : currentLogs.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock_clock_rounded, size: 56, color: isDark ? Colors.white24 : Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  Text(
                                    _selectedMonthIndex == 0
                                        ? 'No Journey Echoes yet.'
                                        : 'You haven\'t reached this month yet.',
                                    style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF1E293B), fontSize: 17, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _selectedMonthIndex == 0
                                        ? 'Complete your weekly reflection after Day 7 to generate your first AI echo!'
                                        : 'Keep completing your daily actions to unlock upcoming months.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: currentLogs.length,
                            itemBuilder: (context, index) {
                              final log = currentLogs[index];
                              return _buildLogCard(
                                context, 
                                index, 
                                log['date'] ?? 'Weekly Reflection', 
                                log['summary'] ?? ''
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, int index, String date, String summary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1120) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.purpleAccent, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  date,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent.withOpacity(0.7)),
                tooltip: 'Delete Log',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Text('Delete Reflection?', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
                      content: Text('Are you sure you want to remove this reflection log?', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B))),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            _deleteLog(index);
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            summary,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
