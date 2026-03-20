import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deadline_ai/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:deadline_ai/features/auth/presentation/cubit/auth_state.dart';
import 'package:deadline_ai/features/squad/data/datasources/squad_remote_datasource.dart';
import 'package:deadline_ai/features/squad/domain/repositories/squad_repository.dart';
import 'squad_state.dart';

class SquadCubit extends Cubit<SquadState> {
  final SquadRepository squadRepository;
  final SquadRemoteDataSource squadRemoteDataSource;
  final AuthCubit authCubit;
  StreamSubscription? _socketSubscription;

  SquadCubit({
    required this.squadRepository,
    required this.squadRemoteDataSource,
    required this.authCubit,
  }) : super(const SquadState());

  Future<void> loadSquads() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await squadRepository.listSquads();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (squads) => emit(state.copyWith(isLoading: false, squads: squads)),
    );
  }

  Future<void> createSquad(String name) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await squadRepository.createSquad(name);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (_) => loadSquads(),
    );
  }

  Future<void> joinSquad(String inviteCode) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await squadRepository.joinSquad(inviteCode);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (_) => loadSquads(),
    );
  }

  Future<void> openBoard(String squadId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, activeSquadId: squadId));
    final result = await squadRepository.getSquadBoard(squadId);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (board) {
        emit(state.copyWith(isLoading: false, board: board));
        _connectSocket(squadId);
      },
    );
  }

  Future<void> leaveActiveSquad() async {
    final squadId = state.activeSquadId;
    if (squadId == null) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await squadRepository.leaveSquad(squadId);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (_) {
        _disconnectSocket();
        emit(const SquadState());
        loadSquads();
      },
    );
  }

  void sendLiveUpdate(String message) {
    if (message.trim().isEmpty) return;
    squadRemoteDataSource.sendBroadcast({'message': message.trim()});
  }

  void _connectSocket(String squadId) {
    final authState = authCubit.state;
    if (authState is! AuthAuthenticated) return;

    _disconnectSocket();
    _socketSubscription = squadRemoteDataSource
        .connectToSquad(userId: authState.user.id, squadId: squadId)
        .listen((event) {
      emit(
        state.copyWith(
          liveMessages: [...state.liveMessages, event.toString()],
        ),
      );
    });
  }

  void _disconnectSocket() {
    _socketSubscription?.cancel();
    _socketSubscription = null;
    squadRemoteDataSource.disconnect();
  }

  @override
  Future<void> close() {
    _disconnectSocket();
    return super.close();
  }
}
