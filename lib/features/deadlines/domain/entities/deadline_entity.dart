enum DeadlineType {
  exam,
  midterm,
  quiz,
  assignment,
  project,
  lab,
  presentation,
  other,
}

class DeadlineEntity {
  final String deadlineId;
  final String title;
  final String? courseCode;
  final String? courseName;
  final DeadlineType type;
  final String dueDate;
  final String? dueTime;
  final double? weight;
  final String? description;
  final bool isHardDeadline;
  final String status;
  final List<String> reminderSchedule;
  final double? priorityScore;
  final String createdAt;

  const DeadlineEntity({
    required this.deadlineId,
    required this.title,
    this.courseCode,
    this.courseName,
    required this.type,
    required this.dueDate,
    this.dueTime,
    this.weight,
    this.description,
    required this.isHardDeadline,
    required this.status,
    required this.reminderSchedule,
    this.priorityScore,
    required this.createdAt,
  });
}
