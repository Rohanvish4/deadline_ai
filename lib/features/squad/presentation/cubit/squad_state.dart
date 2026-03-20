import 'package:deadline_ai/features/squad/domain/entities/squad_entity.dart';

class SquadState {
  final bool isLoading;
  final String? errorMessage;
  final List<SquadEntity> squads;
  final List<SquadBoardMemberEntity> board;
  final String? activeSquadId;
  final List<String> liveMessages;

  const SquadState({
    this.isLoading = false,
    this.errorMessage,
    this.squads = const [],
    this.board = const [],
    this.activeSquadId,
    this.liveMessages = const [],
  });

  SquadState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<SquadEntity>? squads,
    List<SquadBoardMemberEntity>? board,
    String? activeSquadId,
    List<String>? liveMessages,
  }) {
    return SquadState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      squads: squads ?? this.squads,
      board: board ?? this.board,
      activeSquadId: activeSquadId ?? this.activeSquadId,
      liveMessages: liveMessages ?? this.liveMessages,
    );
  }
}
