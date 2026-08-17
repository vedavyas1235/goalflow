import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:goalflow/services/goal_provider.dart';
import 'package:goalflow/services/api_service.dart';
import 'package:goalflow/models/action_item.dart';
import 'package:goalflow/widgets/ambient_watercolor_background.dart';

class GoalDetailsScreen extends StatefulWidget {
  final String goalId;
  const GoalDetailsScreen({super.key, required this.goalId});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  void _showDeleteWarning(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete Goal?', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        content: Text(
          'If you delete this goal, the application will automatically delete all milestones and actions regarding this. You will have to completely start from onboarding for this goal.',
          style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              _showDeleteTimer(context);
            },
            child: const Text('Delete Anyway', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteTimer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        int countdown = 30;
        Timer? timer;

        return StatefulBuilder(
          builder: (context, setState) {
            if (timer == null) {
              timer = Timer.periodic(const Duration(seconds: 1), (t) {
                if (countdown > 0) {
                  setState(() => countdown--);
                } else {
                  t.cancel();
                }
              });
            }

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('Final Confirmation', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'This action is irreversible.',
                    style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B), fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  if (countdown > 0)
                    Text(
                      'Delete unlocks in $countdown s',
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    context.pop();
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: countdown > 0
                      ? null
                      : () {
                          timer?.cancel();
                          Provider.of<GoalProvider>(context, listen: false).deleteGoal(widget.goalId);
                          context.pop();
                          context.go('/home');
                        },
                  child: Text(
                    'Delete Forever',
                    style: TextStyle(
                      color: countdown > 0 ? Colors.grey.withOpacity(0.5) : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: Consumer<GoalProvider>(
        builder: (context, provider, child) {
          final goal = provider.goals.firstWhere(
            (g) => g.id == widget.goalId,
            orElse: () => throw Exception('Goal not found'),
          );

          final completedActions = goal.allActions.where((a) => a.status == ActionStatus.completed).length;
          final totalGoalDays = goal.totalTimelineDays;
          final progress = totalGoalDays > 0 ? (completedActions / totalGoalDays).clamp(0.0, 1.0) : 0.0;

          final sortedActions = List<ActionItem>.from(goal.allActions);
          sortedActions.sort((a, b) {
            if (a.dueDate == null && b.dueDate == null) return 0;
            if (a.dueDate == null) return 1;
            if (b.dueDate == null) return -1;
            return a.dueDate!.compareTo(b.dueDate!);
          });

          return AmbientWatercolorBackground(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 100,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                    onPressed: () => context.pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.edit_rounded, color: textColor),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      onPressed: () => _showDeleteWarning(context),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
                    title: Text(
                      'Goal Details',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Goal Header Info
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFF1E293B).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            goal.category.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          goal.title,
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textColor, height: 1.1),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          goal.description,
                          style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : const Color(0xFF64748B), height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Progress Analytics Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF1E293B).withOpacity(isDark ? 0.4 : 0.2), blurRadius: 20, offset: const Offset(0, 10))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Overall Progress', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                    child: const Text('ON TRACK', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 80,
                                    width: 80,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CircularProgressIndicator(
                                          value: progress,
                                          strokeWidth: 8,
                                          backgroundColor: Colors.white.withOpacity(0.1),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                                        ),
                                        Center(
                                          child: Builder(builder: (context) {
                                            final pctText = (progress * 100).toStringAsFixed(progress > 0 && progress < 0.1 ? 1 : 0);
                                            return Text('$pctText%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18));
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('$completedActions of $totalGoalDays', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        const Text('Days Completed', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                        
                        // Actions Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Actions (Month 1 • 30 Days)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
                            IconButton(
                              icon: Icon(Icons.add_circle_rounded, color: textColor),
                              onPressed: () => context.push('/create-action/${goal.id}'),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (sortedActions.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.0),
                              child: Text('No actions yet. Break this goal down!', style: TextStyle(color: Color(0xFF64748B))),
                            ),
                          )
                        else
                          ...List.generate(sortedActions.length, (index) {
                            final action = sortedActions[index];
                            final dayNumber = index + 1;
                            final isCompleted = action.status == ActionStatus.completed;
                            final now = DateTime.now();
                            final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
                            final isFuture = action.dueDate != null && action.dueDate!.isAfter(todayEnd);
                            final isToday = action.dueDate != null && 
                                action.dueDate!.year == now.year && 
                                action.dueDate!.month == now.month && 
                                action.dueDate!.day == now.day;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0B1120) : Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isToday 
                                      ? Colors.blueAccent.withOpacity(0.5) 
                                      : (isDark ? Colors.white.withOpacity(0.08) : Colors.white), 
                                  width: isToday ? 2 : 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1E293B).withOpacity(isDark ? 0.2 : 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Checkbox / Lock Icon
                                  GestureDetector(
                                    onTap: () async {
                                      if (isFuture) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Scheduled for Day $dayNumber (${action.dueDate!.day}/${action.dueDate!.month}). Focus on today\'s task first!'),
                                            backgroundColor: isDark ? Colors.grey.shade800 : const Color(0xFF1E293B),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                        return;
                                      }

                                      final newStatus = isCompleted ? ActionStatus.upcoming : ActionStatus.completed;
                                      provider.toggleActionStatus(action.id, newStatus);
                                      // Persist to Supabase
                                      await ApiService().updateActionStatus(
                                        action.id,
                                        newStatus == ActionStatus.completed ? 'completed' : 'pending',
                                      );
                                    },
                                    child: isFuture
                                        ? Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey.withOpacity(0.12),
                                            ),
                                            child: Icon(
                                              Icons.lock_outline_rounded,
                                              size: 16,
                                              color: Colors.grey.shade400,
                                            ),
                                          )
                                        : Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isCompleted ? Colors.greenAccent.withOpacity(0.2) : Colors.transparent,
                                              border: Border.all(
                                                color: isCompleted ? Colors.greenAccent : (isDark ? Colors.white.withOpacity(0.3) : const Color(0xFF1E293B).withOpacity(0.3)),
                                                width: 2,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.check_rounded,
                                              size: 16,
                                              color: isCompleted ? Colors.green : Colors.transparent,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Day Badge & Title
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isToday 
                                                    ? Colors.blueAccent.withOpacity(0.15) 
                                                    : (isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'DAY $dayNumber${isToday ? ' • TODAY' : ''}',
                                                style: TextStyle(
                                                  color: isToday ? Colors.blueAccent : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                            if (action.dueDate != null) ...[
                                              const SizedBox(width: 8),
                                              Text(
                                                '${action.dueDate!.day}/${action.dueDate!.month}',
                                                style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 11),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          action.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: isCompleted ? const Color(0xFF64748B) : textColor,
                                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          
                        const SizedBox(height: 100), // padding for FAB
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-milestone/${widget.goalId}'),
        backgroundColor: textColor,
        icon: Icon(Icons.add, color: bgColor),
        label: Text('Add Milestone', style: TextStyle(color: bgColor, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
