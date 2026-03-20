import 'package:dartz/dartz.dart';
import 'package:deadline_ai/core/errors/failures.dart';
import 'package:deadline_ai/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, void>> signUp({
    required String email,
    required String password,
    required String fullName,
  });
  Future<Either<Failure, void>> confirmSignUp({
    required String email,
    required String code,
  });
  Future<Either<Failure, void>> resendConfirmationCode({
    required String email,
  });
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> logout();
}
