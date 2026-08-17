enum ActionStatus {
  upcoming,
  inProgress,
  completed,
  missed,
  skipped,
}

enum Priority {
  low,
  medium,
  high,
}

class ActionItem {
  final String id;
  final String title;
  final String description;
  final String goalId;
  final String? milestoneId;
  final DateTime? dueDate;
  final String? preferredTime; // e.g. "Morning", "14:00"
  final Duration? estimatedDuration;
  final Priority priority;
  ActionStatus status;

  ActionItem({
    required this.id,
    required this.title,
    this.description = '',
    required this.goalId,
    this.milestoneId,
    this.dueDate,
    this.preferredTime,
    this.estimatedDuration,
    this.priority = Priority.medium,
    this.status = ActionStatus.upcoming,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['dueDate'] != null) {
      try {
        parsedDate = DateTime.parse(json['dueDate']).toLocal();
      } catch (_) {}
    }

    Duration? parsedDuration;
    if (json['estimatedDuration'] != null) {
      final val = json['estimatedDuration'];
      if (val is num) {
        parsedDuration = Duration(minutes: val.toInt());
      }
    }

    ActionStatus parsedStatus = ActionStatus.upcoming;
    final statusStr = json['status']?.toString().toLowerCase() ?? '';
    if (statusStr == 'completed') {
      parsedStatus = ActionStatus.completed;
    } else if (statusStr == 'inprogress' || statusStr == 'in_progress') {
      parsedStatus = ActionStatus.inProgress;
    } else if (statusStr == 'missed') {
      parsedStatus = ActionStatus.missed;
    } else if (statusStr == 'skipped') {
      parsedStatus = ActionStatus.skipped;
    } else {
      parsedStatus = ActionStatus.upcoming;
    }

    Priority parsedPriority = Priority.medium;
    final prioStr = json['priority']?.toString().toLowerCase() ?? '';
    if (prioStr == 'high') {
      parsedPriority = Priority.high;
    } else if (prioStr == 'low') {
      parsedPriority = Priority.low;
    }

    return ActionItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      goalId: json['goalId']?.toString() ?? '',
      milestoneId: json['milestoneId']?.toString(),
      dueDate: parsedDate,
      preferredTime: json['preferredTime']?.toString(),
      estimatedDuration: parsedDuration,
      priority: parsedPriority,
      status: parsedStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'goalId': goalId,
      'milestoneId': milestoneId,
      'dueDate': dueDate?.toIso8601String(),
      'preferredTime': preferredTime,
      'estimatedDuration': estimatedDuration?.inMinutes,
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
    };
  }
}
