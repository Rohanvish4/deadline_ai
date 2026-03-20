import '../../domain/entities/deadline_entity.dart';
import '../../domain/repositories/deadline_repository.dart';

class DeadlineState {
  final bool isLoading;
  final List<DeadlineEntity> deadlines;
  final String? errorMessage;
  final bool isConfirming;
  final Map<String, dynamic>? confirmResponse;
  final List<ClashEntity> clashes;
  final List<PaceSessionEntity> paceSessions;
  final bool isLoadingClashes;
  final bool isLoadingPace;

  const DeadlineState({
    this.isLoading = false,
    this.deadlines = const [],
    this.errorMessage,
    this.isConfirming = false,
    this.confirmResponse,
    this.clashes = const [],
    this.paceSessions = const [],
    this.isLoadingClashes = false,
    this.isLoadingPace = false,
  });

  DeadlineState copyWith({
    bool? isLoading,
    List<DeadlineEntity>? deadlines,
    String? errorMessage,
    bool? isConfirming,
    Map<String, dynamic>? confirmResponse,
    List<ClashEntity>? clashes,
    List<PaceSessionEntity>? paceSessions,
    bool? isLoadingClashes,
    bool? isLoadingPace,
  }) {
    return DeadlineState(
      isLoading: isLoading ?? this.isLoading,
      deadlines: deadlines ?? this.deadlines,
      errorMessage: errorMessage,
      isConfirming: isConfirming ?? this.isConfirming,
      confirmResponse: confirmResponse ?? this.confirmResponse,
      clashes: clashes ?? this.clashes,
      paceSessions: paceSessions ?? this.paceSessions,
      isLoadingClashes: isLoadingClashes ?? this.isLoadingClashes,
      isLoadingPace: isLoadingPace ?? this.isLoadingPace,
    );
  }
}
