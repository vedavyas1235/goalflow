import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:goalflow/services/goal_provider.dart';
import 'package:goalflow/theme/app_theme.dart';
import 'package:goalflow/widgets/ambient_watercolor_background.dart';

class GoalsListScreen extends StatefulWidget {
  const GoalsListScreen({super.key});

  @override
  State<GoalsListScreen> createState() => _GoalsListScreenState();
}

class _GoalsListScreenState extends State<GoalsListScreen> {
  int _selectedTabIndex = 0; // 0 = Active, 1 = Completed

  @override
  void initState() {
    super.initState();
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
        currentIndex: 1, // Goals is index 1
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: selectedColor,
        unselectedItemColor: Colors.grey.shade400,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) context.push('/home');
          if (index == 2) context.push('/calendar');
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final activeTabColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final inactiveTabColor = Colors.transparent;
    final activeTextColor = isDark ? Colors.white : const Color(0xFF1E293B);

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
                    Text('My Goals', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5)),
                    Container(
                      decoration: BoxDecoration(
                        color: textColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: textColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.add_rounded, color: Theme.of(context).scaffoldBackgroundColor),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              title: Text('Focus Warning', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                              content: Text(
                                'It is highly recommended to complete one goal at a time so that you can focus completely on it. This helps you build discipline and achieve true mastery.',
                                style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B), height: 1.5),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => context.pop(), // "Okay" - do nothing but close
                                  child: const Text('Okay', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.pop();
                                    context.push('/create-goal');
                                  },
                                  child: const Text('Continue Anyway', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFF1E293B).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTabIndex = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 0 ? activeTabColor : inactiveTabColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: _selectedTabIndex == 0 ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : [],
                            ),
                            child: Center(
                              child: Text('Active', style: TextStyle(fontWeight: FontWeight.bold, color: _selectedTabIndex == 0 ? activeTextColor : const Color(0xFF64748B))),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTabIndex = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 1 ? activeTabColor : inactiveTabColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: _selectedTabIndex == 1 ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : [],
                            ),
                            child: Center(
                              child: Text('Completed', style: TextStyle(fontWeight: FontWeight.bold, color: _selectedTabIndex == 1 ? activeTextColor : const Color(0xFF64748B))),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Goal List
              Expanded(
                child: Consumer<GoalProvider>(
                  builder: (context, provider, child) {
                    final goals = provider.goals;
                    // Mock filter: In a real app we would check a `status` field on Goal
                    // For now, we assume all goals are active.
                    final filteredGoals = _selectedTabIndex == 0 ? goals : [];

                    if (filteredGoals.isEmpty) {
                      return const Center(child: Text('No goals found in this section.', style: TextStyle(color: Color(0xFF64748B))));
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: filteredGoals.length,
                      itemBuilder: (context, index) {
                        final goal = filteredGoals[index];
                        return GestureDetector(
                          onTap: () => context.push('/goal-details/${goal.id}'),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0B1120) : Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white, width: 2),
                              boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withOpacity(isDark ? 0.2 : 0.06), blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: Row(
                              children: [
                                // Icon/Category
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFF1E293B).withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(Icons.school_rounded, color: textColor, size: 28),
                                ),
                                const SizedBox(width: 16),
                                // Text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(goal.category, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5)),
                                      const SizedBox(height: 4),
                                      Text(goal.title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Builder(builder: (context) {
                                        final total = goal.totalTimelineDays;
                                        final completed = goal.allActions.where((a) => a.status.toString().contains('completed')).length;
                                        return Text('$completed of $total days completed', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)));
                                      }),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Progress Ring
                                Builder(builder: (context) {
                                  final total = goal.totalTimelineDays;
                                  final completed = goal.allActions.where((a) => a.status.toString().contains('completed')).length;
                                  final pct = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
                                  final pctText = (pct * 100).toStringAsFixed(pct > 0 && pct < 0.1 ? 1 : 0);
                                  return SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CircularProgressIndicator(
                                          value: pct,
                                          strokeWidth: 4,
                                          backgroundColor: textColor.withOpacity(0.1),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                                        ),
                                        Center(child: Text('$pctText%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor))),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
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
