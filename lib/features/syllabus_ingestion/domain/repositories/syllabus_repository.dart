import 'package:dartz/dartz.dart';
import 'package:deadline_ai/core/errors/failures.dart';
import 'package:deadline_ai/features/syllabus_ingestion/domain/entities/extracted_deadline_entity.dart';
import 'package:file_picker/file_picker.dart';

abstract class SyllabusRepository {
  Future<Either<Failure, List<ExtractedDeadlineEntity>>> extractDeadlines(PlatformFile file);
}
