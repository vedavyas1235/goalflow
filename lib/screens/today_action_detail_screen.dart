import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goalflow/models/action_item.dart';
import 'package:goalflow/models/goal.dart';
import 'package:goalflow/services/goal_provider.dart';
import 'package:goalflow/services/api_service.dart';
import 'package:goalflow/widgets/ambient_watercolor_background.dart';

class TodayActionDetailScreen extends StatefulWidget {
  final String actionId;
  const TodayActionDetailScreen({super.key, required this.actionId});

  @override
  State<TodayActionDetailScreen> createState() => _TodayActionDetailScreenState();
}

class _TodayActionDetailScreenState extends State<TodayActionDetailScreen> {
  List<String>? _aiPoints;
  bool _isLoadingAi = true;

  @override
  void initState() {
    super.initState();
    _loadOrFetchAiBriefing();
  }

  Future<void> _loadOrFetchAiBriefing() async {
    final now = DateTime.now();
    final cacheKey = 'ai_briefing_${widget.actionId}_${now.year}_${now.month}_${now.day}';

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedList = prefs.getStringList(cacheKey);

      if (cachedList != null && cachedList.isNotEmpty) {
        if (mounted) {
          setState(() {
            _aiPoints = cachedList;
            _isLoadingAi = false;
          });
        }
        return;
      }
    } catch (_) {}

    // Not cached for today, query backend AI
    final provider = Provider.of<GoalProvider>(context, listen: false);
    final allActions = provider.goals.expand((g) => g.allActions).toList();
    ActionItem? action;
    Goal? parentGoal;

    try {
      action = allActions.firstWhere((a) => a.id == widget.actionId);
    } catch (_) {
      action = allActions.isNotEmpty ? allActions.first : null;
    }

    if (action != null) {
      try {
        parentGoal = provider.goals.firstWhere((g) => g.id == action!.goalId);
      } catch (_) {
        parentGoal = provider.goals.isNotEmpty ? provider.goals.first : null;
      }
    }

    final points = await ApiService().getActionBriefing(
      actionTitle: action?.title ?? 'Daily Focus Task',
      goalTitle: parentGoal?.title ?? 'Personal Goal Mastery',
      category: parentGoal?.category ?? 'General',
      description: parentGoal?.description ?? '',
    );

    // Save to SharedPreferences for the rest of today
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(cacheKey, points);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _aiPoints = points;
        _isLoadingAi = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final cardColor = isDark ? const Color(0xFF0F172A).withOpacity(0.95) : Colors.white.withOpacity(0.95);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<GoalProvider>(
        builder: (context, provider, child) {
          final allActions = provider.goals.expand((g) => g.allActions).toList();
          ActionItem? action;
          Goal? parentGoal;

          try {
            action = allActions.firstWhere((a) => a.id == widget.actionId);
          } catch (_) {
            action = allActions.isNotEmpty ? allActions.first : null;
          }

          if (action != null) {
            try {
              parentGoal = provider.goals.firstWhere((g) => g.id == action!.goalId);
            } catch (_) {
              parentGoal = provider.goals.isNotEmpty ? provider.goals.first : null;
            }
          }

          if (action == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Task not found.'),
                  TextButton(onPressed: () => context.pop(), child: const Text('Back')),
                ],
              ),
            );
          }

          final isCompleted = action.status == ActionStatus.completed;

          return AmbientWatercolorBackground(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 90,
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
                      'Focus on Today',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Goal Category Pill & Goal Title
                        if (parentGoal != null) ...[
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  parentGoal.category.toUpperCase(),
                                  style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  parentGoal.title,
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Action Title Card
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E293B), Color(0xFF334155)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF1E293B).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isCompleted ? Colors.greenAccent.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isCompleted ? Icons.check_circle_rounded : Icons.bolt_rounded,
                                      color: isCompleted ? Colors.greenAccent : Colors.amber,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isCompleted ? 'DAY 1 • COMPLETED' : 'DAY 1 • TODAY\'S ACTION',
                                    style: TextStyle(
                                      color: isCompleted ? Colors.greenAccent : Colors.amber,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                action.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Icon(Icons.schedule_rounded, size: 16, color: Colors.white.withOpacity(0.7)),
                                  const SizedBox(width: 6),
                                  Text(
                                    action.estimatedDuration != null
                                        ? 'Estimated Time: ${action.estimatedDuration!.inMinutes} mins'
                                        : 'Estimated Time: 30 mins',
                                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // AI Coach Briefing Section
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.blueAccent]),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'AI DAILY BRIEFING & DRILL PLAN',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.purpleAccent : const Color(0xFF7C3AED),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (_isLoadingAi)
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.white, width: 2),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: isDark ? Colors.purpleAccent : const Color(0xFF7C3AED),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Synthesizing today\'s tactical briefing...',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'AI Coach is analyzing lesson breakdown and drills',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          )
                        else if (_aiPoints != null)
                          ..._aiPoints!.map((point) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1E293B).withOpacity(isDark ? 0.2 : 0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Text(
                                point,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                  height: 1.5,
                                ),
                              ),
                            );
                          }),

                        const SizedBox(height: 32),

                        // Action Button (Completed vs Mark Completed toggle)
                        if (isCompleted)
                          OutlinedButton.icon(
                            onPressed: () async {
                              provider.toggleActionStatus(action!.id, ActionStatus.upcoming);
                              await ApiService().updateActionStatus(action.id, 'pending');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Action marked as pending / incomplete.'),
                                    backgroundColor: Colors.amber.shade700,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                                context.pop();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.amber.shade700, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            icon: Icon(Icons.undo_rounded, color: Colors.amber.shade700),
                            label: Text(
                              'Mark as Incomplete (Undo)',
                              style: TextStyle(
                                color: Colors.amber.shade700,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: () async {
                              provider.toggleActionStatus(action!.id, ActionStatus.completed);
                              await ApiService().updateActionStatus(action.id, 'completed');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('🎉 Day 1 Action Completed! Fantastic discipline!'),
                                    backgroundColor: Colors.green.shade600,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                                context.pop();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: textColor,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 4,
                            ),
                            icon: Icon(
                              Icons.check_rounded,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            label: Text(
                              'Mark as Completed',
                              style: TextStyle(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
