import 'package:dartz/dartz.dart';
import 'package:deadline_ai/core/errors/failures.dart';
import 'package:deadline_ai/core/network/network_info.dart';
import 'package:deadline_ai/features/squad/data/datasources/squad_remote_datasource.dart';
import 'package:deadline_ai/features/squad/domain/entities/squad_entity.dart';
import 'package:deadline_ai/features/squad/domain/repositories/squad_repository.dart';

class SquadRepositoryImpl implements SquadRepository {
  final SquadRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SquadRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, SquadEntity>> createSquad(String name) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final data = await remoteDataSource.createSquad(name);
      return Right(
        SquadEntity(
          squadId: data['squadId'] as String,
          name: data['name'] as String,
          inviteCode: (data['inviteCode'] as String?) ?? '',
          memberCount: (data['memberCount'] as int?) ?? 1,
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SquadEntity>> joinSquad(String inviteCode) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final data = await remoteDataSource.joinSquad(inviteCode);
      return Right(
        SquadEntity(
          squadId: data['squadId'] as String,
          name: data['name'] as String,
          inviteCode: inviteCode,
          memberCount: (data['memberCount'] as int?) ?? 0,
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SquadEntity>>> listSquads() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final squads = await remoteDataSource.listSquads();
      return Right(
        squads
            .map(
              (item) => SquadEntity(
                squadId: item['squadId'] as String,
                name: item['name'] as String,
                inviteCode: (item['inviteCode'] as String?) ?? '',
                memberCount: (item['memberCount'] as int?) ?? 0,
              ),
            )
            .toList(),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SquadBoardMemberEntity>>> getSquadBoard(String squadId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final board = await remoteDataSource.getSquadBoard(squadId);
      return Right(
        board
            .map(
              (item) => SquadBoardMemberEntity(
                userId: item['userId'] as String,
                displayName: (item['displayName'] as String?) ?? item['userId'] as String,
                deadlines: ((item['deadlines'] as List<dynamic>?) ?? const [])
                    .map((deadline) => Map<String, dynamic>.from(deadline as Map))
                    .toList(),
              ),
            )
            .toList(),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveSquad(String squadId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await remoteDataSource.leaveSquad(squadId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
