import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:goalflow/services/goal_provider.dart';
import 'package:goalflow/widgets/ambient_watercolor_background.dart';
import 'package:goalflow/widgets/dynamic_ai_push_banner.dart';
import 'package:goalflow/services/api_service.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  bool _startWindowPush = true;
  bool _midWindowPush = true;
  bool _closingWindowPush = true;
  bool _overdueEveningPush = true;
  bool _weeklyReflection = true;
  bool _milestoneAchieved = true;

  String? _testingSlot;

  Future<void> _triggerTestPush(String slot, String phase, String label) async {
    setState(() => _testingSlot = phase);
    try {
      final notif = await ApiService().generateAINotification(timeSlot: slot, phase: phase);
      if (mounted && notif != null) {
        DynamicAiPushBanner.show(
          context,
          title: notif['title']?.toString() ?? 'GoalFlow • AI Coach',
          body: notif['body']?.toString() ?? 'Keep up your amazing momentum today!',
          timeLabel: notif['timeLabel']?.toString() ?? label,
        );
      } else if (mounted) {
        DynamicAiPushBanner.show(
          context,
          title: 'GoalFlow • $label',
          body: phase == 'start'
              ? 'Rise and conquer! Today\'s goal action plan is primed and ready. Take step 1!'
              : phase == 'midpoint'
              ? 'Midway check: Keep your streak alive! Complete today\'s action item.'
              : phase == 'window_closing'
              ? 'Final window alert: Finish your action before your focus block closes!'
              : 'Evening check-in: Complete today\'s habit tonight to maintain your streak!',
          timeLabel: label,
        );
      }
    } catch (_) {
      if (mounted) {
        DynamicAiPushBanner.show(
          context,
          title: 'GoalFlow • $label',
          body: 'Stay focused on your targets today!',
          timeLabel: label,
        );
      }
    } finally {
      if (mounted) setState(() => _testingSlot = null);
    }
  }

  Widget _buildTriggerCard({
    required BuildContext context,
    required String time,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool value,
    required ValueChanged<bool> onChanged,
    required String slotKey,
    required String phaseKey,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF0F172A).withOpacity(0.9) : Colors.white.withOpacity(0.95);
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final isTesting = _testingSlot == phaseKey;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: value ? accentColor.withOpacity(0.35) : borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(isDark ? 0.15 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'AI TRIGGER',
                            style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: subtitleColor)),
                  ],
                ),
              ),
              Switch(
                value: value,
                activeColor: Colors.white,
                activeTrackColor: accentColor,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
                onChanged: onChanged,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(subtitle, style: TextStyle(fontSize: 12, color: subtitleColor, height: 1.4)),
          const SizedBox(height: 14),
          // Test AI Push Trigger Button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: isTesting ? null : () => _triggerTestPush(slotKey, phaseKey, '$time $title'),
              style: TextButton.styleFrom(
                backgroundColor: accentColor.withOpacity(0.12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: isTesting 
                  ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: accentColor))
                  : Icon(Icons.auto_awesome_rounded, color: accentColor, size: 16),
              label: Text(
                isTesting ? 'Synthesizing AI Push...' : 'Preview AI Push',
                style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleSwitch({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white.withOpacity(0.9);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.white, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.white70 : const Color(0xFF1E293B), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: subtitleColor)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF3B82F6),
            onChanged: onChanged,
          ),
        ],
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
        child: Consumer<GoalProvider>(
          builder: (context, provider, child) {
            final goal = provider.goals.isNotEmpty ? provider.goals.first : null;
            final isMorning = true; // Default routine preference

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
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
                      'AI Notification Center',
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
                        // Routine Banner
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E293B), Color(0xFF334155)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.purpleAccent.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.purpleAccent, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'ACTIVE ROUTINE SCHEDULE',
                                    style: TextStyle(color: Colors.purpleAccent, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                goal != null ? 'Focus: ${goal.title}' : 'Smart Routine Push Engine',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isMorning 
                                    ? 'Morning Focus Window (6:00 AM – 12:00 PM). Pushes are scheduled across 3 stages and automatically stop once today\'s task is completed!'
                                    : 'Afternoon Focus Window (12:00 PM – 5:00 PM). Pushes automatically stop once today\'s task is completed!',
                                style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        Text(
                          'YOUR ROUTINE AI PUSH TRIGGERS',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.purpleAccent : const Color(0xFF7C3AED),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Trigger 1: Kickoff
                        _buildTriggerCard(
                          context: context,
                          time: '6:00 AM',
                          title: 'Window Kickoff Push',
                          subtitle: 'Daily focus task intention, priming, and kickoff prompt.',
                          icon: Icons.wb_sunny_rounded,
                          accentColor: Colors.amber.shade600,
                          value: _startWindowPush,
                          slotKey: 'morning',
                          phaseKey: 'start',
                          onChanged: (v) => setState(() => _startWindowPush = v),
                        ),

                        // Trigger 2: Mid-Window Check
                        _buildTriggerCard(
                          context: context,
                          time: '9:00 AM',
                          title: 'Mid-Session Momentum Nudge',
                          subtitle: 'Checks if today\'s action is completed. Stops if already done; otherwise sends a focus booster.',
                          icon: Icons.bolt_rounded,
                          accentColor: Colors.cyanAccent.shade700,
                          value: _midWindowPush,
                          slotKey: 'morning',
                          phaseKey: 'midpoint',
                          onChanged: (v) => setState(() => _midWindowPush = v),
                        ),

                        // Trigger 3: Final Window Warning
                        _buildTriggerCard(
                          context: context,
                          time: '11:00 AM',
                          title: 'Window Closing Alert',
                          subtitle: '1-hour warning before morning window closes if action item remains pending.',
                          icon: Icons.timer_outlined,
                          accentColor: Colors.orangeAccent.shade700,
                          value: _closingWindowPush,
                          slotKey: 'morning',
                          phaseKey: 'window_closing',
                          onChanged: (v) => setState(() => _closingWindowPush = v),
                        ),

                        // Trigger 4: Overdue Evening Alert
                        _buildTriggerCard(
                          context: context,
                          time: '6:00 PM',
                          title: 'Evening Overdue Catch-Up',
                          subtitle: 'Sent only if today\'s action is still incomplete. Prompts a quick 15-min evening wrap-up to protect your streak.',
                          icon: Icons.nights_stay_rounded,
                          accentColor: Colors.purpleAccent,
                          value: _overdueEveningPush,
                          slotKey: 'morning',
                          phaseKey: 'evening_overdue',
                          onChanged: (v) => setState(() => _overdueEveningPush = v),
                        ),

                        const SizedBox(height: 24),
                        Text(
                          'OTHER NOTIFICATIONS',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white70 : const Color(0xFF64748B),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildSimpleSwitch(
                          context: context,
                          title: 'Weekly Reflection Prompt',
                          subtitle: '48-hour window unlock notification on Day 7',
                          icon: Icons.auto_stories_rounded,
                          value: _weeklyReflection,
                          onChanged: (v) => setState(() => _weeklyReflection = v),
                        ),

                        _buildSimpleSwitch(
                          context: context,
                          title: 'Milestone Celebrations',
                          subtitle: 'Celebrate when you complete a major milestone',
                          icon: Icons.emoji_events_rounded,
                          value: _milestoneAchieved,
                          onChanged: (v) => setState(() => _milestoneAchieved = v),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
