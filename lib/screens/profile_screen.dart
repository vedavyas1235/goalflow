import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:goalflow/services/api_service.dart';
import 'package:goalflow/services/goal_provider.dart';
import 'package:goalflow/models/action_item.dart';
import 'package:goalflow/widgets/ambient_watercolor_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
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
        currentIndex: 3, // Profile is index 3
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
          if (index == 2) context.push('/calendar');
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

  Widget _buildListTile(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white.withOpacity(0.9);
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.white;
    final iconBgColor = isDark ? Colors.white.withOpacity(0.05) : const Color(0xFF1E293B).withOpacity(0.05);
    final iconColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withOpacity(isDark ? 0.2 : 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor))),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    // Real user data from session
    final userName = ApiService.currentUserData?['name'] ?? 'User';
    final userEmail = ApiService.currentUserData?['email'] ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AmbientWatercolorBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 20.0, bottom: 24),
                child: Text('Profile', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5)),
              ),

              Expanded(
                child: Consumer<GoalProvider>(
                  builder: (context, provider, child) {
                    // Compute real stats from GoalProvider
                    final allActions = provider.goals.expand((g) => g.allActions).toList();
                    final completedGoals = provider.goals.where((g) {
                      final total = g.allActions.length;
                      if (total == 0) return false;
                      final done = g.allActions.where((a) => a.status == ActionStatus.completed).length;
                      return done == total;
                    }).length;
                    final totalActions = allActions.where((a) => a.status == ActionStatus.completed).length;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // User Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                            ),
                            child: Column(
                              children: [
                                const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white24,
                                  child: Icon(Icons.person_rounded, size: 40, color: Colors.white),
                                ),
                                const SizedBox(height: 16),
                                Text(userName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(userEmail, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),

                                const SizedBox(height: 32),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatNode(completedGoals.toString(), 'Goals Done'),
                                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                                    _buildStatNode(totalActions.toString(), 'Completed'),
                                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                                    _buildStatNode(provider.goals.length.toString(), 'Active Goals'),
                                  ],
                                )
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          _buildListTile(
                            context,
                            title: 'Weekly Reflection',
                            icon: Icons.pie_chart_rounded,
                            onTap: () => context.push('/reflection'),
                          ),
                          _buildListTile(
                            context,
                            title: 'Journey Echoes',
                            icon: Icons.auto_awesome_rounded,
                            onTap: () => context.push('/reflection-log'),
                          ),
                          _buildListTile(
                            context,
                            title: 'Notification Preferences',
                            icon: Icons.notifications_active_rounded,
                            onTap: () => context.push('/notifications'),
                          ),
                          _buildListTile(
                            context,
                            title: 'Settings',
                            icon: Icons.settings_rounded,
                            onTap: () => context.push('/settings'),
                          ),

                          const SizedBox(height: 40),

                          TextButton.icon(
                            onPressed: () async {
                              await ApiService.clearSession(); // clear SharedPreferences
                              if (context.mounted) context.go('/register');
                            },
                            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                            label: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
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
    );
  }

  Widget _buildStatNode(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
