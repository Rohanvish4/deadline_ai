import 'package:dartz/dartz.dart';
import 'package:deadline_ai/core/errors/failures.dart';
import '../entities/squad_entity.dart';

abstract class SquadRepository {
  Future<Either<Failure, SquadEntity>> createSquad(String name);
  Future<Either<Failure, SquadEntity>> joinSquad(String inviteCode);
  Future<Either<Failure, List<SquadEntity>>> listSquads();
  Future<Either<Failure, List<SquadBoardMemberEntity>>> getSquadBoard(String squadId);
  Future<Either<Failure, void>> leaveSquad(String squadId);
}
