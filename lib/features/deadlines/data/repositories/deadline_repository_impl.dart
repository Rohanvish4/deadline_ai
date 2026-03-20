import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/deadline_entity.dart';
import '../../domain/repositories/deadline_repository.dart';
import '../../../syllabus_ingestion/domain/entities/extracted_deadline_entity.dart';
import '../datasources/deadline_remote_datasource.dart';

class DeadlineRepositoryImpl implements DeadlineRepository {
  final DeadlineRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DeadlineRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<DeadlineEntity>>> getDeadlines({
    String? from,
    String? to,
    String? status,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final deadlines = await remoteDataSource.getDeadlines(
        from: from,
        to: to,
        status: status,
      );
      return Right(deadlines);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> confirmExtractedDeadlines(
    List<ExtractedDeadlineEntity> deadlines,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final payload = deadlines
          .map(
            (d) => {
              'title': d.title,
              'courseCode': d.courseCode,
              'courseName': d.courseName,
              'type': d.type.name,
              'dueDate': d.dueDate,
              'dueTime': d.dueTime,
              'weight': d.weight,
              'description': d.description,
              'isHardDeadline': d.isHardDeadline,
            },
          )
          .toList();

      final response = await remoteDataSource.confirmDeadlines(payload);
      return Right(response);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ClashEntity>>> getClashes({bool withPlan = false}) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final clashes = await remoteDataSource.getClashes(withPlan: withPlan);
      return Right(clashes);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaceSessionEntity>>> generatePaceSessions({
    required String deadlineId,
    double hoursPerDay = 3,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final sessions = await remoteDataSource.generatePaceSessions(
        deadlineId: deadlineId,
        hoursPerDay: hoursPerDay,
      );
      return Right(sessions);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
