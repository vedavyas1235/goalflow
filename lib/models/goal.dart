import 'package:goalflow/models/milestone.dart';
import 'package:goalflow/models/routine.dart';
import 'package:goalflow/models/action_item.dart';

class Goal {
  final String id;
  final String title;
  final String description;
  final String category;
  final Priority priority;
  final DateTime startDate;
  final DateTime? targetDate;
  final Routine? routine;
  List<Milestone> milestones;
  List<ActionItem> standaloneActions;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.priority = Priority.medium,
    required this.startDate,
    this.targetDate,
    this.routine,
    List<Milestone>? milestones,
    List<ActionItem>? standaloneActions,
  })  : milestones = milestones ?? [],
        standaloneActions = standaloneActions ?? [];

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      priority: Priority.values.firstWhere(
        (e) => e.name.toLowerCase() == json['priority']?.toString().toLowerCase(),
        orElse: () => Priority.medium,
      ),
      startDate: json['startDate'] != null 
          ? (DateTime.tryParse(json['startDate']) ?? DateTime.now()).toLocal()
          : DateTime.now(),
      targetDate: json['targetDate'] != null 
          ? DateTime.tryParse(json['targetDate'])?.toLocal() 
          : null,
      routine: json['routine'] != null ? Routine.fromJson(json['routine']) : null,
      milestones: json['milestones'] != null
          ? (json['milestones'] as List).map((i) => Milestone.fromJson(i)).toList()
          : [],
      standaloneActions: json['actions'] != null
          ? (json['actions'] as List)
              .where((a) => a['milestoneId'] == null)
              .map((i) => ActionItem.fromJson(i))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'routine': routine?.toJson(),
    };
  }


  // Helper method to get all actions (standalone + inside milestones)
  List<ActionItem> get allActions {
    final actions = List<ActionItem>.from(standaloneActions);
    for (var milestone in milestones) {
      actions.addAll(milestone.actions);
    }
    return actions;
  }

  /// Calculates total days for the entire goal (e.g. 90 days for 3 months, 180 days for 6 months)
  int get totalTimelineDays {
    if (targetDate != null) {
      final diff = targetDate!.difference(startDate).inDays;
      if (diff > 0) return diff;
    }
    final lower = '$title $description $category'.toLowerCase();
    if (lower.contains('6 month') || lower.contains('6-month') || lower.contains('6m') || lower.contains('180')) {
      return 180;
    }
    if (lower.contains('1 year') || lower.contains('12 month') || lower.contains('365')) {
      return 365;
    }
    if (lower.contains('1 month') || lower.contains('30 day')) {
      return 30;
    }
    if (lower.contains('3 month') || lower.contains('3-month') || lower.contains('90 day') || lower.contains('3m')) {
      return 90;
    }
    return 90; // Default 3 months
  }
}
