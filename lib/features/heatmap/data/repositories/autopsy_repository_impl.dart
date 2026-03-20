import 'package:dartz/dartz.dart';
import 'package:deadline_ai/core/errors/failures.dart';
import 'package:deadline_ai/core/network/network_info.dart';
import 'package:deadline_ai/features/heatmap/data/datasources/autopsy_remote_datasource.dart';
import 'package:deadline_ai/features/heatmap/domain/repositories/autopsy_repository.dart';

class AutopsyRepositoryImpl implements AutopsyRepository {
  final AutopsyRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AutopsyRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> submitAutopsy({
    required String deadlineId,
    required bool completedOnTime,
    required int satisfaction,
    String? whatWentWell,
    String? whatWentWrong,
    String? lessonsLearned,
    bool? wouldChangeApproach,
    double? hoursSpent,
    int? startedDaysBefore,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final data = await remoteDataSource.submitAutopsy(
        deadlineId: deadlineId,
        completedOnTime: completedOnTime,
        satisfaction: satisfaction,
        whatWentWell: whatWentWell,
        whatWentWrong: whatWentWrong,
        lessonsLearned: lessonsLearned,
        wouldChangeApproach: wouldChangeApproach,
        hoursSpent: hoursSpent,
        startedDaysBefore: startedDaysBefore,
      );

      return Right(data);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
