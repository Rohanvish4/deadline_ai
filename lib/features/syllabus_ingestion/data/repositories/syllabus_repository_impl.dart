import 'package:dartz/dartz.dart';
import 'package:deadline_ai/core/errors/failures.dart';
import 'package:deadline_ai/core/network/network_info.dart';
import 'package:deadline_ai/features/syllabus_ingestion/data/datasources/syllabus_remote_datasource.dart';
import 'package:deadline_ai/features/syllabus_ingestion/domain/entities/extracted_deadline_entity.dart';
import 'package:deadline_ai/features/syllabus_ingestion/domain/repositories/syllabus_repository.dart';
import 'package:file_picker/file_picker.dart';

class SyllabusRepositoryImpl implements SyllabusRepository {
  final SyllabusRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SyllabusRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ExtractedDeadlineEntity>>> extractDeadlines(List<PlatformFile> files) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final deadlines = await remoteDataSource.extractDeadlines(files);
      return Right(deadlines);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
