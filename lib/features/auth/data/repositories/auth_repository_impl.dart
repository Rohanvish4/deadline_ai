import 'package:dartz/dartz.dart';
import 'package:deadline_ai/core/errors/failures.dart';
import 'package:deadline_ai/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:deadline_ai/features/auth/domain/entities/user_entity.dart';
import 'package:deadline_ai/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final saved = await localDataSource.getSavedUser();
      if (saved == null) return const Right(null);
      return Right(UserEntity(id: saved['id']!, displayName: saved['displayName']!));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInDemo() async {
    try {
      const user = UserEntity(id: 'demo-user', displayName: 'Demo Student');
      await localDataSource.saveUser(id: user.id, displayName: user.displayName);
      return const Right(user);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearUser();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
