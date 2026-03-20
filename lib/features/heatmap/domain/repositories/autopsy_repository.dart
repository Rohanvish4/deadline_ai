import 'package:dartz/dartz.dart';
import 'package:deadline_ai/core/errors/failures.dart';

abstract class AutopsyRepository {
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
  });
}
