# Backend Connection Faults & Disconnection Audit Report

> **Project:** GoalFlow (Flutter Mobile App + Express/Prisma PostgreSQL Backend)  
> **Audit Date:** August 16, 2026  
> **Status:** Complete System Analysis

---

## Executive Summary

A comprehensive code analysis of the **entire GoalFlow codebase** (all 19 Flutter frontend screens, 3 service providers, and all backend Express/Prisma route controllers) was conducted. 

While the core Authentication, AI Onboarding, and initial Goal creation pipelines are connected to the backend, **multiple critical features and entire screens remain disconnected, relying on in-memory state or hardcoded static mockup data.**

---

## 1. Screen-by-Screen Connection Audit

### ❌ 1. Profile Screen (`lib/screens/profile_screen.dart`) — **90% Disconnected**
* **Line 124:** Name `'Vedav'` is hardcoded string instead of `ApiService.currentUserData['name']`.
* **Line 126:** Email `'vedav@example.com'` is hardcoded string instead of `ApiService.currentUserData['email']`.
* **Lines 133–138:** Stats summary (`'12'` Goals Done, `'184'` Actions, `'5'` Day Streak) are completely hardcoded static strings.
* **Line 174:** Log Out button `context.go('/welcome')` simply navigates away; it **never clears session variables** (`ApiService.currentUserId = null`), nor calls any logout endpoint.
* **Backend Missing:** No backend endpoint exists to calculate or return user statistics (completed goals count, total actions executed, active streaks).

---

### ❌ 2. Action Completion & Checkboxes (`lib/screens/goal_details_screen.dart`) — **Disconnected**
* **Lines 310–313:**
  ```dart
  onTap: () {
    action.status = isCompleted ? ActionStatus.upcoming : ActionStatus.completed;
    provider.notifyListeners();
  }
  ```
  Tapping the checkbox to complete an action item **only mutates the local Dart object in memory**.
* **Fault:** It **never makes an HTTP request** to the backend (`PATCH /api/actions/:id` or `PUT /api/goals/...`).
* **Consequence:** If you check off 5 actions and restart the app or navigate away, **all completed tasks reset to uncompleted**.
* **Backend Missing:** No controller exists in `backend/src/routes/goals.ts` to update individual `ActionItem` status.

---

### ❌ 3. Milestone Creation (`lib/screens/create_milestone_screen.dart`) — **100% Disconnected**
* **Lines 28–42:**
  ```dart
  final newMilestone = Milestone(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: _titleController.text,
    goalId: widget.goalId,
  );
  provider.goals[index].milestones.add(newMilestone);
  ```
* **Fault:** Adding a milestone only appends it to the in-memory array.
* **Consequence:** New milestones created by the user are never sent to the PostgreSQL database and disappear upon app restart.
* **Backend Missing:** No `POST /api/milestones` endpoint exists in the backend.

---

### ❌ 4. Manual Action Creation (`lib/screens/create_action_screen.dart`) — **100% Disconnected**
* **Lines 32–40:**
  ```dart
  final newAction = ActionItem(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: _titleController.text,
    goalId: widget.goalId,
    status: ActionStatus.upcoming,
  );
  Provider.of<GoalProvider>(context, listen: false).addActionToGoal(widget.goalId, newAction);
  ```
* **Fault:** `addActionToGoal` only modifies `goal.standaloneActions.add(action)`.
* **Consequence:** Manually created actions are never persisted in PostgreSQL.
* **Backend Missing:** No `POST /api/actions` or `POST /api/goals/:id/actions` endpoint exists.

---

### ❌ 5. Goal Deletion from Details Screen (`lib/screens/goal_details_screen.dart`) — **Disconnected (Commented Out)**
* **Lines 106–109:**
  ```dart
  // In a real app, delete from provider here.
  // provider.deleteGoal(widget.goalId);
  context.pop();
  context.go('/home');
  ```
* **Fault:** The final 30-second countdown confirmation button closes the modal and redirects to `/home` **without calling `provider.deleteGoal()`** or `ApiService.deleteGoal()`.
* **Consequence:** Goals cannot be deleted from the Details screen.

---

### ❌ 6. Weekly Reflection Screen (`lib/screens/reflection_screen.dart`) — **100% Disconnected**
* **Line 19:** `final bool _isReflectionDay = false;` is hardcoded.
* **Lines 120–124:** Output stats (`'18'` Completed, `'3'` Missed, `'85%'` Progress) are hardcoded mock strings.
* **Lines 159–194:** The "Save Reflection" button runs a fake delay `await Future.delayed(const Duration(seconds: 2));` and immediately routes to `/reflection-log`.
* **Backend Missing:** There is **no `Reflection` table** in Prisma schema (`prisma/schema.prisma`), and no backend route to store or fetch reflection notes.

---

### ❌ 7. Journey Echoes / Reflection Log (`lib/screens/reflection_log_screen.dart`) — **100% Disconnected**
* **Lines 18–35:** Hardcoded dictionary `_monthlyLogs` with 3 pre-written AI summaries from "Oct 2026".
* **Fault:** Completely static mock data. No API calls or database connections exist.

---

### ❌ 8. Progress Screen (`lib/screens/progress_screen.dart`) — **100% Disconnected**
* **Line 32:** `value: 0.82` (82% circular progress) is hardcoded.
* **Line 60:** `value: 5/6` (5 out of 6 planned actions) is hardcoded.
* **Fault:** Does not read from `GoalProvider` or the backend.

---

### ❌ 9. Settings Screen (`lib/screens/settings_screen.dart`) — **Partial Disconnection**
* **Lines 129–131:** Account Details dialog shows hardcoded `'Name: Test User'` and `'Email: test@example.com'`.
* **Line 107:** Dark Mode toggle modifies in-memory `ThemeProvider` but does not persist to local storage (`SharedPreferences`) or backend.
* **Line 174:** Data Export button is a placeholder with an empty callback `onTap: () {}`.

---

### ❌ 10. Notification Preferences (`lib/screens/notification_preferences_screen.dart`) — **100% Disconnected**
* **Lines 13–15:** Switches (`_dailyReminders`, `_weeklyReflection`, `_milestoneAchieved`) only update local widget state via `setState`.
* **Fault:** Preferences are not sent to any backend route or persisted locally.

---

### ❌ 11. Goals List Screen (`lib/screens/goals_list_screen.dart`) — **Partial Disconnection**
* **Lines 229–234:** Progress circle on goal cards hardcoded to `value: 0.65` and text `'65%'`.
* **Line 175:** Completed Tab `_selectedTabIndex == 1` returns an empty list `[]` instead of filtering completed goals.

---

### ❌ 12. Calendar Screen (`lib/screens/calendar_screen.dart`) — **Partial Disconnection**
* **Line 160:** Status dot color on the 7-day strip is hardcoded to `'planned'`.
* **Fault:** Does not query historical days to indicate completed vs missed days.

---

## 2. Infrastructure & Architectural Faults

### ⚠️ 13. Hardcoded Local IP Address (`lib/services/api_service.dart`)
* **Line 8:** `static const String baseUrl = 'http://192.168.1.7:3000/api';`
* **Fault:** Hardcoded to a specific local Wi-Fi IP address. If the laptop Wi-Fi reconnects or changes subnet, or when deploying to Vercel/production, the app loses connection.

### ⚠️ 14. Session & Auth Token Persistence Missing
* **Line 10:** `static String? currentUserId;`
* **Fault:** Auth state is stored in a static Dart in-memory variable. If the Android OS terminates or reloads the application, `currentUserId` resets to `null`, requiring re-login.

### ⚠️ 15. Insecure Password Storage & Authentication Bypass
* **`backend/src/routes/auth.ts` Line 11 & Line 41:**
  * User passwords are not hashed with `bcrypt`.
  * Login route checks `email` but accepts **any password**:
    ```ts
    // For Hackathon MVP, accept any password matching the email
    res.status(200).json({ message: 'Login successful', user });
    ```
  * No JWT tokens are issued or validated on protected goal/action routes.

### ⚠️ 16. Missing Database Schema Models (`backend/prisma/schema.prisma`)
The PostgreSQL schema is missing tables for features displayed in the UI:
1. `Reflection` / `WeeklyReflection` (Prompt responses & AI syntheses)
2. `UserPreference` (Notification flags & theme settings)
3. `StreakRecord` (Daily login & completion tracking)

---

## 3. Connection Status Matrix

| Component / Screen | Frontend File | Backend Route | Database Model | Status |
| :--- | :--- | :--- | :--- | :--- |
| **User Registration** | `register_screen.dart` | `POST /api/auth/register` | `User` | ✅ Connected |
| **User Login** | `login_screen.dart` | `POST /api/auth/login` | `User` | ✅ Connected |
| **AI Onboarding Slides** | `onboarding_screen.dart` | `POST /api/ai/generate-onboarding` | `GoalBlueprint` | ✅ Connected |
| **AI 30-Day Plan Generation** | `ai_generation_screen.dart` | `POST /api/ai/generate-onboarding` | `Goal`, `ActionItem` | ✅ Connected |
| **Goal Retrieval (Home)** | `home_dashboard_screen.dart`| `GET /api/goals/user/:userId` | `Goal`, `ActionItem` | ✅ Connected |
| **Action Completion Toggle**| `goal_details_screen.dart` | *None* | `ActionItem` | ❌ In-Memory Only |
| **Milestone Creation** | `create_milestone_screen.dart` | *None* | `Milestone` | ❌ In-Memory Only |
| **Action Creation** | `create_action_screen.dart` | *None* | `ActionItem` | ❌ In-Memory Only |
| **Goal Deletion (Details)**| `goal_details_screen.dart` | `DELETE /api/goals/:id` | `Goal` | ❌ Commented Out |
| **Profile Stats & Info** | `profile_screen.dart` | *None* | *None* | ❌ Hardcoded Mock |
| **Weekly Reflection** | `reflection_screen.dart` | *None* | *None* | ❌ Hardcoded Mock |
| **Reflection Logs (Echoes)**| `reflection_log_screen.dart` | *None* | *None* | ❌ Hardcoded Mock |
| **Progress Analytics** | `progress_screen.dart` | *None* | *None* | ❌ Hardcoded Mock |
| **Notification Settings** | `notification_preferences_screen.dart` | *None* | *None* | ❌ Local State Only |
| **Account Details Modal** | `settings_screen.dart` | *None* | `User` | ❌ Hardcoded Mock |

---

## Recommended Remediation Plan

1. **Priority 1 (Action Persistence):** Add `PATCH /api/goals/actions/:id` in `backend/src/routes/goals.ts` and call it on checkbox tap in Flutter so action completion persists to PostgreSQL.
2. **Priority 2 (Milestone & Action Creation):** Implement `POST /api/goals/:id/milestones` and `POST /api/goals/:id/actions` endpoints and connect the creation screens.
3. **Priority 3 (Profile & Settings Sync):** Bind `profile_screen.dart` and `settings_screen.dart` directly to `ApiService.currentUserData` and compute real statistics from `GoalProvider`.
4. **Priority 4 (Goal Deletion):** Uncomment `provider.deleteGoal(widget.goalId)` in `goal_details_screen.dart`.
5. **Priority 5 (Session Persistence):** Add `shared_preferences` to Flutter to persist `currentUserId` between app restarts.
