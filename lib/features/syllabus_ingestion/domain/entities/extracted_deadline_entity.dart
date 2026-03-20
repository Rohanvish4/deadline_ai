class ExtractedDeadlineEntity {
  final String title;
  final String course;
  final DateTime date;
  final double confidence;

  const ExtractedDeadlineEntity({
    required this.title,
    required this.course,
    required this.date,
    required this.confidence,
  });
}
