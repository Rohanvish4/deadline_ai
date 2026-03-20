import 'package:deadline_ai/features/syllabus_ingestion/domain/entities/extracted_deadline_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

class SyllabusIngestionState extends Equatable {
  final List<PlatformFile> files;
  final List<ExtractedDeadlineEntity> extractedDeadlines;
  final bool isLoading;
  final String? errorMessage;

  const SyllabusIngestionState({
    this.files = const [],
    this.extractedDeadlines = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SyllabusIngestionState copyWith({
    List<PlatformFile>? files,
    List<ExtractedDeadlineEntity>? extractedDeadlines,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SyllabusIngestionState(
      files: files ?? this.files,
      extractedDeadlines: extractedDeadlines ?? this.extractedDeadlines,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [files, extractedDeadlines, isLoading, errorMessage];
}
