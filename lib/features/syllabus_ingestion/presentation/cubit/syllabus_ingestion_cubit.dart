import 'package:deadline_ai/features/syllabus_ingestion/domain/repositories/syllabus_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'syllabus_ingestion_state.dart';

class SyllabusIngestionCubit extends Cubit<SyllabusIngestionState> {
  final SyllabusRepository syllabusRepository;

  SyllabusIngestionCubit({required this.syllabusRepository})
      : super(const SyllabusIngestionState());

  Future<void> pickPdfFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    emit(state.copyWith(files: result.files, errorMessage: null));
  }

  Future<void> extractDeadlines() async {
    if (state.files.isEmpty) {
      emit(state.copyWith(errorMessage: 'Please pick at least one PDF file'));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await syllabusRepository.extractDeadlines(state.files);

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (deadlines) => emit(
        state.copyWith(
          isLoading: false,
          extractedDeadlines: deadlines,
          errorMessage: null,
        ),
      ),
    );
  }
}
