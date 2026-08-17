enum RoutineType {
  daily,
  specificDays,
}

class Routine {
  final RoutineType type;
  final List<int> daysOfWeek; // 1 = Monday, 7 = Sunday
  final String? preferredTime; 
  final Duration? durationPerSession;

  Routine({
    this.type = RoutineType.daily,
    this.daysOfWeek = const [],
    this.preferredTime,
    this.durationPerSession,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      type: RoutineType.values.firstWhere(
        (e) => e.toString() == 'RoutineType.${json['type']}',
        orElse: () => RoutineType.daily,
      ),
      daysOfWeek: json['daysOfWeek'] != null ? List<int>.from(json['daysOfWeek']) : [],
      preferredTime: json['preferredTime'] as String?,
      durationPerSession: json['durationPerSessionMins'] != null 
          ? Duration(minutes: json['durationPerSessionMins'] as int) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'daysOfWeek': daysOfWeek,
      'preferredTime': preferredTime,
      'durationPerSessionMins': durationPerSession?.inMinutes,
    };
  }
}
