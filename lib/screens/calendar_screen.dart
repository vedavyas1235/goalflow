import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:goalflow/services/goal_provider.dart';
import 'package:goalflow/models/action_item.dart';
import 'package:goalflow/models/goal.dart';
import 'package:goalflow/services/api_service.dart';
import 'package:goalflow/widgets/ambient_watercolor_background.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedDayIndex = 0; // Today is first!
  late List<DateTime> _weekDates;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    // Start from Today and generate the next 7 days
    _weekDates = List.generate(7, (index) => today.add(Duration(days: index)));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GoalProvider>(context, listen: false).fetchGoals();
    });
  }

  Widget _buildBottomNav(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B1120).withOpacity(0.9) : Colors.white.withOpacity(0.9);
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2);
    final selectedColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 2, // Calendar is index 2
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: selectedColor,
        unselectedItemColor: Colors.grey.shade400,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) context.push('/home');
          if (index == 1) context.push('/goals');
          if (index == 3) context.push('/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded, size: 28), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.flag_rounded, size: 28), label: 'Goals'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded, size: 28), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded, size: 28), label: 'Profile'),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'missed':
        return Colors.redAccent;
      case 'planned':
        return const Color(0xFF1E293B);
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AmbientWatercolorBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 20.0, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Schedule', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5)),
                    IconButton(
                      icon: Icon(Icons.pie_chart_rounded, color: textColor),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              backgroundColor: cardColor,
                              title: Text('Weekly Reflection', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                              content: Text(
                                'The weekly reflection is only available once every week on your designated reflection day. You can access it from your Profile tab when it becomes available.',
                                style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    )
                  ],
                ),
              ),

              // Calendar Strip
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _weekDates.length,
                  itemBuilder: (context, index) {
                    final date = _weekDates[index];
                    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    final dayLabel = dayLabels[date.weekday - 1];
                    final dateLabel = date.day.toString();
                    final isSelected = _selectedDayIndex == index;
                    
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDayIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 65,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? textColor : (isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6)),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: isSelected ? textColor : (isDark ? Colors.white.withOpacity(0.1) : Colors.white), width: 2),
                          boxShadow: isSelected ? [BoxShadow(color: textColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(dayLabel, style: TextStyle(color: isSelected ? Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7) : const Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 8),
                            Text(dateLabel, style: TextStyle(color: isSelected ? Theme.of(context).scaffoldBackgroundColor : textColor, fontWeight: FontWeight.w900, fontSize: 18)),
                            const SizedBox(height: 8),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFF3B82F6),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Agenda List
              Expanded(
                child: Consumer<GoalProvider>(
                  builder: (context, provider, child) {
                    final selectedDate = _weekDates[_selectedDayIndex];
                    final actions = provider.goals.expand((g) => g.allActions).where((a) {
                      if (a.dueDate == null) return false;
                      final due = a.dueDate!;
                      return due.year == selectedDate.year &&
                             due.month == selectedDate.month &&
                             due.day == selectedDate.day;
                    }).toList();

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Agenda', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                          const SizedBox(height: 16),
                          
                          if (actions.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.0),
                                child: Text('No actions scheduled for this day.', style: TextStyle(color: Color(0xFF64748B))),
                              ),
                            )
                          else
                            ...actions.map((action) {
                              Goal? parentGoal;
                              try {
                                parentGoal = provider.goals.firstWhere((g) => g.id == action.goalId);
                              } catch (_) {
                                parentGoal = provider.goals.isNotEmpty ? provider.goals.first : null;
                              }
                              final parentTitle = parentGoal?.title ?? 'Goal';
                              final isCompleted = action.status == ActionStatus.completed;
                              final now = DateTime.now();
                              final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
                              final isFuture = action.dueDate != null && action.dueDate!.isAfter(todayEnd);
                              
                              return GestureDetector(
                                onTap: () async {
                                  if (isFuture) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Scheduled for ${action.dueDate!.day}/${action.dueDate!.month}. Focus on today\'s tasks first!'),
                                        backgroundColor: isDark ? Colors.grey.shade800 : const Color(0xFF1E293B),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                    return;
                                  }

                                  // Toggle completion status with live sync
                                  final newStatus = isCompleted ? ActionStatus.upcoming : ActionStatus.completed;
                                  provider.toggleActionStatus(action.id, newStatus);
                                  await ApiService().updateActionStatus(action.id, newStatus == ActionStatus.completed ? 'completed' : 'pending');
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0B1120) : Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white, width: 2),
                                    boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withOpacity(isDark ? 0.2 : 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    leading: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('09:00', style: TextStyle(fontWeight: FontWeight.bold, color: isCompleted ? Colors.grey : textColor)),
                                        const Text('AM', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                    title: Text(
                                      action.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isCompleted ? const Color(0xFF64748B) : textColor,
                                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    subtitle: Text(parentTitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                    trailing: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      child: isFuture
                                          ? Icon(Icons.lock_outline_rounded, color: Colors.grey.shade400, size: 22)
                                          : Icon(
                                              isCompleted ? Icons.check_circle_rounded : Icons.circle_outlined,
                                              key: ValueKey(isCompleted),
                                              color: isCompleted ? Colors.green : Colors.grey.shade400,
                                              size: 26,
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            })
                        ],
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }
}
