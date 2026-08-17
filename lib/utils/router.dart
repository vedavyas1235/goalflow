import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:goalflow/screens/splash_screen.dart';
import 'package:goalflow/screens/login_screen.dart';
import 'package:goalflow/screens/register_screen.dart';
import 'package:goalflow/screens/onboarding_screen.dart';
import 'package:goalflow/screens/welcome_splash_screen.dart';
import 'package:goalflow/screens/goals_list_screen.dart';
import 'package:goalflow/screens/create_goal_screen.dart';
import 'package:goalflow/screens/goal_details_screen.dart';
import 'package:goalflow/screens/home_dashboard_screen.dart';
import 'package:goalflow/screens/calendar_screen.dart';
import 'package:goalflow/screens/reflection_screen.dart';
import 'package:goalflow/screens/reflection_log_screen.dart';
import 'package:goalflow/screens/progress_screen.dart';
import 'package:goalflow/screens/profile_screen.dart';
import 'package:goalflow/screens/create_milestone_screen.dart';
import 'package:goalflow/screens/create_action_screen.dart';
import 'package:goalflow/screens/settings_screen.dart';
import 'package:goalflow/screens/notification_preferences_screen.dart';
import 'package:goalflow/screens/ai_generation_screen.dart';
import 'package:goalflow/screens/today_action_detail_screen.dart';

CustomTransitionPage _buildSmoothPage(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

/// Build a new GoRouter with the correct initial location determined at startup.
/// Session checking is done in main() before runApp(), so no async redirect needed.
GoRouter buildRouter(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const RegisterScreen()),
      ),
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const SplashScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const OnboardingScreen()),
      ),
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          return _buildSmoothPage(context, state, WelcomeSplashScreen(onboardingData: extraData));
        },
      ),
      GoRoute(
        path: '/ai-generation',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          return _buildSmoothPage(context, state, AiGenerationScreen(onboardingData: extraData));
        },
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const HomeDashboardScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const LoginScreen()),
      ),
      GoRoute(
        path: '/goals',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const GoalsListScreen()),
      ),
      GoRoute(
        path: '/create-goal',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const CreateGoalScreen()),
      ),
      GoRoute(
        path: '/create-milestone/:goalId',
        pageBuilder: (context, state) {
          final goalId = state.pathParameters['goalId']!;
          return _buildSmoothPage(context, state, CreateMilestoneScreen(goalId: goalId));
        },
      ),
      GoRoute(
        path: '/create-action/:goalId',
        pageBuilder: (context, state) {
          final goalId = state.pathParameters['goalId']!;
          return _buildSmoothPage(context, state, CreateActionScreen(goalId: goalId));
        },
      ),
      GoRoute(
        path: '/goal-details/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildSmoothPage(context, state, GoalDetailsScreen(goalId: id));
        },
      ),
      GoRoute(
        path: '/calendar',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const CalendarScreen()),
      ),
      GoRoute(
        path: '/reflection',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const ReflectionScreen()),
      ),
      GoRoute(
        path: '/reflection-log',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const ReflectionLogScreen()),
      ),
      GoRoute(
        path: '/progress',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const ProgressScreen()),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const ProfileScreen()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const SettingsScreen()),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const NotificationPreferencesScreen()),
      ),
      GoRoute(
        path: '/today-action-details/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _buildSmoothPage(context, state, TodayActionDetailScreen(actionId: id));
        },
      ),
    ],
  );
}
