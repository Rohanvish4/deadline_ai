import '../../domain/entities/extracted_deadline_entity.dart';

class DeadlineModel extends ExtractedDeadlineEntity {
  const DeadlineModel({
    required super.title,
    super.courseCode,
    super.courseName,
    required super.type,
    required super.dueDate,
    super.dueTime,
    super.weight,
    super.description,
    required super.isHardDeadline,
    required super.confidence,
  });

  factory DeadlineModel.fromJson(Map<String, dynamic> json) {
    return DeadlineModel(
      title: json['title'] as String,
      courseCode: json['course_code'] as String?,
      courseName: json['course_name'] as String?,
      type: _parseType(json['type'] as String),
      dueDate: json['due_date'] as String,
      dueTime: json['due_time'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      description: json['description'] as String?,
      isHardDeadline: json['is_hard_deadline'] as bool? ?? true,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
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
      'title': title,
      'course_code': courseCode,
      'course_name': courseName,
      'type': type.name,
      'due_date': dueDate,
      'due_time': dueTime,
      'weight': weight,
      'description': description,
      'is_hard_deadline': isHardDeadline,
      'confidence': confidence,
    };
  }
}
