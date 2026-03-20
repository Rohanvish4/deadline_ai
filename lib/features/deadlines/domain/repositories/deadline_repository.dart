import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/deadline_entity.dart';
import '../../../syllabus_ingestion/domain/entities/extracted_deadline_entity.dart';

class ClashEntity {
  final Map<String, dynamic> deadlineA;
  final Map<String, dynamic> deadlineB;
  final int daysBetween;
  final double combinedWeight;
  final String severity;
  final Map<String, dynamic>? rescuePlan;

  const ClashEntity({
    required this.deadlineA,
    required this.deadlineB,
    required this.daysBetween,
    required this.combinedWeight,
    required this.severity,
    this.rescuePlan,
  });
}

class PaceSessionEntity {
  final String sessionId;
  final String date;
  final double durationHours;
  final String topic;
  final List<String> goals;

  const PaceSessionEntity({
    required this.sessionId,
    required this.date,
    required this.durationHours,
    required this.topic,
    required this.goals,
  });
}

abstract class DeadlineRepository {
  Future<Either<Failure, List<DeadlineEntity>>> getDeadlines({
    String? from,
    String? to,
    String? status,
  });

  Future<Either<Failure, Map<String, dynamic>>> confirmExtractedDeadlines(
    List<ExtractedDeadlineEntity> deadlines,
  );

  Future<Either<Failure, List<ClashEntity>>> getClashes({bool withPlan = false});

  Future<Either<Failure, List<PaceSessionEntity>>> generatePaceSessions({
    required String deadlineId,
    double hoursPerDay = 3,
  });
}
