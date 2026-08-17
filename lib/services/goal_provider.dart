import 'package:flutter/material.dart';
import 'package:goalflow/models/goal.dart';
import 'package:goalflow/models/action_item.dart';
import 'package:goalflow/services/api_service.dart';

class GoalProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _goals = await _apiService.fetchGoals();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal(Goal goal) async {
    try {
      final newGoal = await _apiService.createGoal(goal);
      _goals.add(newGoal);
      notifyListeners();
    } catch (e) {
      print("Failed to add goal: $e");
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await _apiService.deleteGoal(goalId);
      _goals.removeWhere((g) => g.id == goalId);
      notifyListeners();
    } catch (e) {
      print("Failed to delete goal: $e");
    }
  }

  // Placeholder for updating goals and actions locally
  void updateGoalLocally(Goal updatedGoal) {
    final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      _goals[index] = updatedGoal;
      notifyListeners();
    }
  }

  void addActionToGoal(String goalId, ActionItem action) {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _goals[index];
      goal.standaloneActions.add(action);
      notifyListeners();
    }
  }

  void toggleActionStatus(String actionId, ActionStatus newStatus) {
    for (var goal in _goals) {
      for (var action in goal.allActions) {
        if (action.id == actionId) {
          action.status = newStatus;
        }
      }
    }
    notifyListeners();
  }
}
