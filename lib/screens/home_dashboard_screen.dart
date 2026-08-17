import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:goalflow/services/goal_provider.dart';
import 'package:goalflow/models/action_item.dart';
import 'package:goalflow/models/goal.dart';
import 'package:goalflow/widgets/ambient_watercolor_background.dart';
import 'package:goalflow/services/api_service.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    // Fetch fresh goals from Supabase and restore session data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (ApiService.currentUserId == null || ApiService.currentUserData == null) {
        await ApiService.loadSession();
        if (mounted) setState(() {});
      }
      if (mounted) {
        Provider.of<GoalProvider>(context, listen: false).fetchGoals();
      }
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
        currentIndex: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: selectedColor,
        unselectedItemColor: Colors.grey.shade400,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) context.push('/goals');
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

  Widget _buildUpcomingRow(BuildContext context, String time, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1120) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1E293B).withOpacity(isDark ? 0.2 : 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFF1E293B).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(time, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final userName = ApiService.currentUserData?['name'] ?? 'User';

    final hour = DateTime.now().hour;
    final String greeting;
    if (hour < 12) {
      greeting = 'Good morning,';
    } else if (hour < 17) {
      greeting = 'Good afternoon,';
    } else {
      greeting = 'Good evening,';
    }

    return PopScope(
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: AmbientWatercolorBackground(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(greeting, style: const TextStyle(fontSize: 16, color: Color(0xFF64748B))),
                          Text(userName, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textColor)),
                        ],
                      ),
                      // AI Notification Center Button
                      GestureDetector(
                        onTap: () => context.push('/notifications'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF1E293B).withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Icon(Icons.notifications_active_rounded, color: textColor, size: 22),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: Colors.purpleAccent, shape: BoxShape.circle),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: Consumer<GoalProvider>(
                    builder: (context, provider, child) {
                      final allGoals = provider.goals;
                      final now = DateTime.now();
                      final allActions = allGoals.expand((g) => g.allActions).toList();

                      final activeGoal = allGoals.isNotEmpty ? allGoals.first : null;
                      final sortedActions = activeGoal != null ? List<ActionItem>.from(activeGoal.allActions) : <ActionItem>[];
                      sortedActions.sort((a, b) {
                        if (a.dueDate == null && b.dueDate == null) return 0;
                        if (a.dueDate == null) return 1;
                        if (b.dueDate == null) return -1;
                        return a.dueDate!.compareTo(b.dueDate!);
                      });

                      // Today's primary action is strictly the current day's action (Day 1)
                      final todayPrimaryAction = sortedActions.isNotEmpty ? sortedActions.first : null;
                      final isTodayCompleted = todayPrimaryAction?.status == ActionStatus.completed;
                      final upcomingActions = sortedActions.skip(1).take(5).toList();

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Today's Actions (Single Primary Card)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Focus on Today', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
                                  if (todayPrimaryAction != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isTodayCompleted 
                                            ? Colors.greenAccent.withOpacity(0.15) 
                                            : Colors.blueAccent.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isTodayCompleted ? 'DAY 1 COMPLETED' : 'DAY 1 • TODAY',
                                        style: TextStyle(
                                          color: isTodayCompleted ? Colors.greenAccent : Colors.blueAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: todayPrimaryAction == null
                                  ? Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF0B1120) : Colors.white.withOpacity(0.95),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white, width: 2),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.flag_rounded, color: Colors.blueAccent, size: 36),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Create a goal to get your daily action plan!',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text('Your Day 1 action will appear right here.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                        ],
                                      ),
                                    )
                                  : isTodayCompleted
                                      ? GestureDetector(
                                          onTap: () => context.push('/today-action-details/${todayPrimaryAction.id}'),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF0B1120).withOpacity(0.7) : Colors.white.withOpacity(0.85),
                                              borderRadius: BorderRadius.circular(24),
                                              border: Border.all(color: Colors.greenAccent.withOpacity(0.4), width: 2),
                                              boxShadow: [
                                                BoxShadow(color: Colors.greenAccent.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 6)),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(24),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(20.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.all(6),
                                                            decoration: const BoxDecoration(
                                                              color: Colors.greenAccent,
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: const Icon(Icons.check_rounded, color: Colors.black, size: 14),
                                                          ),
                                                          const SizedBox(width: 10),
                                                          const Text(
                                                            'DAY 1 COMPLETED',
                                                            style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                                                          ),
                                                          const Spacer(),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                            decoration: BoxDecoration(
                                                              color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: const Text(
                                                              'DAY 2 UNLOCKS TOMORROW',
                                                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 12),
                                                      Text(
                                                        todayPrimaryAction.title,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                                          decoration: TextDecoration.lineThrough,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 12),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          const Text('🎉 Goal progress locked in!', style: TextStyle(fontSize: 12, color: Colors.greenAccent, fontWeight: FontWeight.w700)),
                                                          Text('Tap to review briefing', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () => context.push('/today-action-details/${todayPrimaryAction.id}'),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF0B1120) : Colors.white.withOpacity(0.95),
                                              borderRadius: BorderRadius.circular(24),
                                              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white, width: 2),
                                              boxShadow: [
                                                BoxShadow(color: const Color(0xFF1E293B).withOpacity(isDark ? 0.2 : 0.06), blurRadius: 20, offset: const Offset(0, 8)),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(24),
                                              child: Dismissible(
                                                key: Key('today_${todayPrimaryAction.id}'),
                                                direction: DismissDirection.horizontal,
                                                onDismissed: (_) async {
                                                  provider.toggleActionStatus(todayPrimaryAction.id, ActionStatus.completed);
                                                  await ApiService().updateActionStatus(todayPrimaryAction.id, 'completed');
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: const Text('🎉 Day 1 Action Completed! Awesome start!'),
                                                        backgroundColor: Colors.green.shade600,
                                                        duration: const Duration(seconds: 2),
                                                      ),
                                                    );
                                                  }
                                                },
                                                background: Container(
                                                  color: Colors.green.shade500,
                                                  alignment: Alignment.centerLeft,
                                                  padding: const EdgeInsets.only(left: 24),
                                                  child: const Row(
                                                    children: [
                                                      Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
                                                      SizedBox(width: 8),
                                                      Text('Completed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                    ],
                                                  ),
                                                ),
                                                secondaryBackground: Container(
                                                  color: Colors.green.shade500,
                                                  alignment: Alignment.centerRight,
                                                  padding: const EdgeInsets.only(right: 24),
                                                  child: const Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      Text('Completed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                      SizedBox(width: 8),
                                                      Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
                                                    ],
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(20.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.all(6),
                                                            decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFF1E293B).withOpacity(0.08), shape: BoxShape.circle),
                                                            child: Icon(Icons.bolt_rounded, color: Colors.amber.shade600, size: 16),
                                                          ),
                                                          const SizedBox(width: 10),
                                                          Expanded(
                                                            child: Text(
                                                              activeGoal?.title ?? 'Active Goal', 
                                                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600), 
                                                              maxLines: 1, 
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                            decoration: BoxDecoration(
                                                              color: isDark ? Colors.purpleAccent.withOpacity(0.2) : const Color(0xFF7C3AED).withOpacity(0.1),
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Icon(Icons.auto_awesome_rounded, size: 10, color: isDark ? Colors.purpleAccent : const Color(0xFF7C3AED)),
                                                                const SizedBox(width: 4),
                                                                Text('AI Briefing', style: TextStyle(color: isDark ? Colors.purpleAccent : const Color(0xFF7C3AED), fontSize: 10, fontWeight: FontWeight.bold)),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 14),
                                                      Text(todayPrimaryAction.title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                                                      const SizedBox(height: 14),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF64748B)),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                todayPrimaryAction.estimatedDuration != null ? 'Est. ${todayPrimaryAction.estimatedDuration!.inMinutes}m' : 'Est. 30m',
                                                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                                              ),
                                                            ],
                                                          ),
                                                          Text(
                                                            'Tap for Drills • Swipe to Done',
                                                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                            ),
                            
                            const SizedBox(height: 32),
                            // Active Goals Summary with Progress Circle
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text('Active Goals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: allGoals.isEmpty
                                  ? Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF0B1120) : Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white, width: 2),
                                      ),
                                      child: Column(
                                        children: [
                                          const Text('No active goals yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                          const SizedBox(height: 8),
                                          const Text('Start your journey by setting up your first goal with AI guidance.', textAlign: TextAlign.center),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () => context.push('/onboarding'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF1E293B),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            child: const Text('Start AI Onboarding', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      children: allGoals.map((g) {
                                        final totalGoalDays = g.totalTimelineDays;
                                        final completedCount = g.allActions.where((a) => a.status == ActionStatus.completed).length;
                                        final pct = totalGoalDays > 0 ? (completedCount / totalGoalDays).clamp(0.0, 1.0) : 0.0;
                                        final pctText = (pct * 100).toStringAsFixed(pct > 0 && pct < 0.1 ? 1 : 0);
                                        
                                        return GestureDetector(
                                          onTap: () => context.push('/goal-details/${g.id}'),
                                          child: Container(
                                            margin: const EdgeInsets.only(bottom: 16),
                                            padding: const EdgeInsets.all(22),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                              borderRadius: BorderRadius.circular(28),
                                              boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                        decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                                        child: Text(g.category.toUpperCase(), style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                                      ),
                                                      const SizedBox(height: 12),
                                                      Text(g.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                                      const SizedBox(height: 8),
                                                      Text('$completedCount of $totalGoalDays days completed', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                // Circular Progress Ring Indicator
                                                SizedBox(
                                                  width: 58,
                                                  height: 58,
                                                  child: Stack(
                                                    fit: StackFit.expand,
                                                    children: [
                                                      CircularProgressIndicator(
                                                        value: pct,
                                                        strokeWidth: 5,
                                                        backgroundColor: Colors.white.withOpacity(0.15),
                                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                                                      ),
                                                      Center(
                                                        child: Text(
                                                          '$pctText%',
                                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                            ),
                            
                            const SizedBox(height: 32),
                            // Upcoming Actions
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Upcoming', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
                                  TextButton(onPressed: () => context.push('/calendar'), child: const Text('View Calendar', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)))),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: upcomingActions.isNotEmpty
                                  ? Column(
                                      children: upcomingActions.map((action) {
                                        return _buildUpcomingRow(context, 'Next', action.title);
                                      }).toList(),
                                    )
                                  : const Center(child: Text("No upcoming tasks", style: TextStyle(color: Color(0xFF64748B)))),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }
}
