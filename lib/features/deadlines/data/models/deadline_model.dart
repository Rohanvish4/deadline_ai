import '../../domain/entities/deadline_entity.dart';

class DeadlineModel extends DeadlineEntity {
  const DeadlineModel({
    required super.deadlineId,
    required super.title,
    super.courseCode,
    super.courseName,
    required super.type,
    required super.dueDate,
    super.dueTime,
    super.weight,
    super.description,
    required super.isHardDeadline,
    required super.status,
    required super.reminderSchedule,
    super.priorityScore,
    required super.createdAt,
  });

  factory DeadlineModel.fromJson(Map<String, dynamic> json) {
    return DeadlineModel(
      deadlineId: json['deadlineId'] as String,
      title: json['title'] as String,
      courseCode: json['courseCode'] as String?,
      courseName: json['courseName'] as String?,
      type: _parseType(json['type'] as String),
      dueDate: json['dueDate'] as String,
      dueTime: json['dueTime'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      description: json['description'] as String?,
      isHardDeadline: json['isHardDeadline'] as bool? ?? true,
      status: json['status'] as String? ?? 'active',
      reminderSchedule: (json['reminderSchedule'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      priorityScore: (json['priorityScore'] as num?)?.toDouble(),
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  static DeadlineType _parseType(String type) {
    return DeadlineType.values.firstWhere(
      (e) => e.name == type.toLowerCase(),
      orElse: () => DeadlineType.other,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deadlineId': deadlineId,
      'title': title,
      'courseCode': courseCode,
      'courseName': courseName,
      'type': type.name,
      'dueDate': dueDate,
      'dueTime': dueTime,
      'weight': weight,
      'description': description,
      'isHardDeadline': isHardDeadline,
      'status': status,
      'reminderSchedule': reminderSchedule,
      'priorityScore': priorityScore,
      'createdAt': createdAt,
    };
  }
}
