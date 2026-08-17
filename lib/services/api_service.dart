import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goalflow/models/goal.dart';

class ApiService {
  // Use your computer's Wi-Fi IP so the physical phone can connect
  static const String baseUrl = 'http://192.168.1.7:3000/api';

  static String? currentUserId;
  static Map<String, dynamic>? currentUserData;

  // ==========================================
  // SESSION PERSISTENCE
  // ==========================================

  /// Call this once at app startup (in router) to restore session from device
  static Future<bool> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final userDataJson = prefs.getString('userData');
      if (userId != null && userId.isNotEmpty) {
        currentUserId = userId;
        if (userDataJson != null && userDataJson.isNotEmpty) {
          try {
            currentUserData = json.decode(userDataJson) as Map<String, dynamic>;
          } catch (_) {
            currentUserData = {'id': userId, 'name': 'Goal Getter'};
          }
        } else {
          currentUserData = {'id': userId, 'name': 'Goal Getter'};
        }
        return true; // session restored
      }
    } catch (e) {
      print('loadSession error: $e');
    }
    return false; // no session
  }

  static Future<void> saveSession(String userId, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('userData', json.encode(userData));
    currentUserId = userId;
    currentUserData = userData;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userData');
    await prefs.remove('onboarding_completed');
    await prefs.remove('onboarding_draft');
    currentUserId = null;
    currentUserData = null;
  }

  static Future<void> saveOnboardingDraft(Map<String, dynamic> draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onboarding_draft', json.encode(draft));
  }

  static Future<Map<String, dynamic>?> loadOnboardingDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftStr = prefs.getString('onboarding_draft');
    if (draftStr != null) {
      try {
        return json.decode(draftStr) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  static Future<void> clearOnboardingDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_draft');
  }

  static Future<void> setOnboardingCompleted(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', val);
  }

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  // ==========================================
  // AUTHENTICATION ROUTES
  // ==========================================

  Future<String?> registerUser(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        await ApiService.saveSession(data['user']['id'], data['user']);
        return null; // Success
      }
      final err = json.decode(response.body);
      return err['error'] ?? 'Server returned ${response.statusCode}';
    } catch (e) {
      return 'Network Error: $e';
    }
  }

  /// Returns null on success, or an error message string on failure.
  Future<String?> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await ApiService.saveSession(data['user']['id'], data['user']);
        return null; // success
      }
      // Parse the backend error message (e.g. "Incorrect password")
      try {
        final err = json.decode(response.body);
        return err['error'] ?? 'Login failed (${response.statusCode})';
      } catch (_) {
        return 'Login failed (${response.statusCode})';
      }
    } catch (e) {
      return 'Network error — check your connection';
    }
  }

  // ==========================================
  // GOAL ROUTES
  // ==========================================

  Future<List<Goal>> fetchGoals() async {
    if (currentUserId == null) {
      await ApiService.loadSession();
    }
    if (currentUserId == null) {
      return [];
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/goals/user/$currentUserId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((j) => Goal.fromJson(j)).toList();
      } else {
        throw Exception('Failed to load goals (${response.statusCode})');
      }
    } catch (e) {
      print('Error in fetchGoals: $e');
      return [];
    }
  }

  Future<Goal> createGoal(Goal goal) async {
    final response = await http.post(
      Uri.parse('$baseUrl/goals'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        ...goal.toJson(),
        'userId': currentUserId,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return Goal.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create goal');
    }
  }

  Future<void> deleteGoal(String goalId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/goals/$goalId'),
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete goal');
    }
  }

  // ==========================================
  // ACTION ITEM ROUTES
  // ==========================================

  /// Update the status of a single action item (persists to Supabase)
  Future<void> updateActionStatus(String actionId, String status) async {
    try {
      await http.patch(
        Uri.parse('$baseUrl/actions/$actionId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      print('updateActionStatus error: $e');
    }
  }

  /// Create a manual action item for a goal (persists to Supabase)
  Future<void> createAction({
    required String goalId,
    required String title,
    String priority = 'medium',
    String? milestoneId,
  }) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/goals/$goalId/actions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'priority': priority,
          if (milestoneId != null) 'milestoneId': milestoneId,
        }),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      print('createAction error: $e');
    }
  }

  // ==========================================
  // MILESTONE ROUTES
  // ==========================================

  /// Create a milestone for a goal (persists to Supabase)
  Future<void> createMilestone({
    required String goalId,
    required String title,
  }) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/goals/$goalId/milestones'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title}),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      print('createMilestone error: $e');
    }
  }

  // ==========================================
  // AI ROUTES
  // ==========================================

  Future<Map<String, dynamic>> generateAIOnboarding(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/generate-onboarding'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': currentUserId,
        'title': data['goalTitle'] ?? '',
        'description': data['mainObjective'] ?? '',
        'detailedDescription': data['detailedDescription'] ?? '',
        'timeframe': data['timeframe'] ?? '3 Months',
        'category': data['category'] ?? 'General',
        'priority': data['priority'] ?? 'Medium',
        'routine': {
          'preferredTime': data['preferredTime'] ?? '',
          'targetDuration': data['targetDuration'] ?? '',
          'workingFrequency': data['workingFrequency'] ?? '',
          'preferredDays': data['preferredDays'] ?? '',
        },
        'personalization': {
          'constraints': data['constraints'] ?? '',
          'progressStyle': data['progressStyle'] ?? '',
          'reminderPref': data['reminderPref'] ?? '',
        }
      }),
    ).timeout(const Duration(minutes: 5));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to generate AI onboarding flow: ${response.body}');
    }
  }

  /// Call the backend to generate a personalized AI push notification for a specific routine window and phase
  Future<Map<String, dynamic>?> generateAINotification({String timeSlot = 'morning', String phase = 'start'}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/generate-notification'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': currentUserId,
          'timeSlot': timeSlot,
          'phase': phase,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['notification'] as Map<String, dynamic>?;
      }
    } catch (e) {
      print('generateAINotification error: $e');
    }
    return null;
  }

  /// Call the backend AI to synthesize the user's weekly reflection inputs into an intelligent Journey Echo
  Future<String?> synthesizeReflection({
    required String well,
    required String difficult,
    required String improve,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/synthesize-reflection'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': currentUserId,
          'well': well,
          'difficult': difficult,
          'improve': improve,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['summary']?.toString();
      }
    } catch (e) {
      print('synthesizeReflection error: $e');
    }
    return null;
  }

  /// Fetch structured 4-point AI coaching briefing for today's focus action
  Future<List<String>> getActionBriefing({
    required String actionTitle,
    required String goalTitle,
    String category = 'General',
    String description = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/action-briefing'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'actionTitle': actionTitle,
          'goalTitle': goalTitle,
          'category': category,
          'description': description,
        }),
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['briefing'] != null && data['briefing']['points'] != null) {
          final List<dynamic> rawPoints = data['briefing']['points'];
          return rawPoints.map((p) => p.toString()).toList();
        }
      }
    } catch (e) {
      print('getActionBriefing error: $e');
    }
    return [
      '🎯 Purpose & Objective: Build foundational muscle memory and habit consistency today.',
      '⚡ Key Techniques: Focus on deliberate execution and eliminating distractions.',
      '📝 Practice Drill: Dedicate 15 undisturbed minutes to execute this task thoroughly.',
      '💡 Coach\'s Pro-Tip: Small daily wins compound into exponential mastery. Stay focused!'
    ];
  }
}
