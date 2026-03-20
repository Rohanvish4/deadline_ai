import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deadline_ai/features/heatmap/domain/repositories/autopsy_repository.dart';
import 'autopsy_state.dart';

class AutopsyCubit extends Cubit<AutopsyState> {
  final AutopsyRepository autopsyRepository;

  AutopsyCubit({required this.autopsyRepository}) : super(const AutopsyState());

  Future<void> submitAutopsy({
    required String deadlineId,
    required bool completedOnTime,
    required int satisfaction,
    String? whatWentWell,
    String? whatWentWrong,
    String? lessonsLearned,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    final result = await autopsyRepository.submitAutopsy(
      deadlineId: deadlineId,
      completedOnTime: completedOnTime,
      satisfaction: satisfaction,
      whatWentWell: whatWentWell,
      whatWentWrong: whatWentWrong,
      lessonsLearned: lessonsLearned,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        ),
      ),
      (data) => emit(state.copyWith(isSubmitting: false, response: data)),
    );
  }
}
