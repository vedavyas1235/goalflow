import 'package:goalflow/models/action_item.dart';

class Milestone {
  final String id;
  final String title;
  final String goalId;
  List<ActionItem> actions;

  Milestone({
    required this.id,
    required this.title,
    required this.goalId,
    List<ActionItem>? actions,
  }) : actions = actions ?? [];

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'] as String,
      title: json['title'] as String,
      goalId: json['goalId'] as String,
      actions: json['actions'] != null
          ? (json['actions'] as List).map((i) => ActionItem.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'goalId': goalId,
      'actions': actions.map((a) => a.toJson()).toList(),
    };
  }
}
