import 'package:deadline_ai/features/syllabus_ingestion/domain/entities/extracted_deadline_entity.dart';

class ExtractedDeadlineModel extends ExtractedDeadlineEntity {
  const ExtractedDeadlineModel({
    required super.title,
    required super.course,
    required super.date,
    required super.confidence,
  });

  factory ExtractedDeadlineModel.fromJson(Map<String, dynamic> json) {
    return ExtractedDeadlineModel(
      title: json['title'] ?? '',
      course: json['course'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }
}
