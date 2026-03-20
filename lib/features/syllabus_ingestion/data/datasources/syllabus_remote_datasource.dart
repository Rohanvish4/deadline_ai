import 'package:deadline_ai/features/syllabus_ingestion/data/models/extracted_deadline_model.dart';
import 'package:file_picker/file_picker.dart';

abstract class SyllabusRemoteDataSource {
  Future<List<ExtractedDeadlineModel>> extractDeadlines(List<PlatformFile> files);
}

class SyllabusRemoteDataSourceImpl implements SyllabusRemoteDataSource {
  @override
  Future<List<ExtractedDeadlineModel>> extractDeadlines(List<PlatformFile> files) async {
    await Future.delayed(const Duration(seconds: 2));

    return files
        .map(
          (file) => ExtractedDeadlineModel(
            title: 'Assignment from ${file.name}',
            course: 'Sample Course',
            date: DateTime.now().add(const Duration(days: 7)),
            confidence: 0.92,
          ),
        )
        .toList();
  }
}
