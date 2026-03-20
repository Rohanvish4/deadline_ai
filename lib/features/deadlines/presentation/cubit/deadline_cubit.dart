import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/deadline_repository.dart';
import '../../../syllabus_ingestion/domain/entities/extracted_deadline_entity.dart';
import 'deadline_state.dart';

class DeadlineCubit extends Cubit<DeadlineState> {
  final DeadlineRepository deadlineRepository;

  DeadlineCubit({required this.deadlineRepository}) : super(const DeadlineState());

  Future<void> fetchDeadlines() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await deadlineRepository.getDeadlines();

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (deadlines) => emit(state.copyWith(isLoading: false, deadlines: deadlines)),
    );
  }

  Future<void> confirmExtractedDeadlines(List<ExtractedDeadlineEntity> deadlines) async {
    if (deadlines.isEmpty) {
      emit(state.copyWith(errorMessage: 'No extracted deadlines to confirm'));
      return;
    }

    emit(state.copyWith(isConfirming: true, errorMessage: null));

    final result = await deadlineRepository.confirmExtractedDeadlines(deadlines);

    result.fold(
      (failure) => emit(state.copyWith(isConfirming: false, errorMessage: failure.message)),
      (response) {
        emit(state.copyWith(isConfirming: false, confirmResponse: response));
        fetchDeadlines(); // Refresh list after confirmation
      },
    );
  }

  Future<void> fetchClashes({bool withPlan = false}) async {
    emit(state.copyWith(isLoadingClashes: true, errorMessage: null));
    final result = await deadlineRepository.getClashes(withPlan: withPlan);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingClashes: false,
          errorMessage: failure.message,
        ),
      ),
      (clashes) => emit(
        state.copyWith(
          isLoadingClashes: false,
          clashes: clashes,
        ),
      ),
    );
  }

  Future<void> generatePace({
    required String deadlineId,
    double hoursPerDay = 3,
  }) async {
    emit(state.copyWith(isLoadingPace: true, errorMessage: null));

    final result = await deadlineRepository.generatePaceSessions(
      deadlineId: deadlineId,
      hoursPerDay: hoursPerDay,
    );

    result.fold(
      (failure) => emit(state.copyWith(isLoadingPace: false, errorMessage: failure.message)),
      (sessions) => emit(state.copyWith(isLoadingPace: false, paceSessions: sessions)),
    );
  }
}
