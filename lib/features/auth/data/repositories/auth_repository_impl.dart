import 'package:dartz/dartz.dart';
import 'package:deadline_ai/core/errors/failures.dart';
import 'package:deadline_ai/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:deadline_ai/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:deadline_ai/features/auth/domain/entities/user_entity.dart';
import 'package:deadline_ai/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final saved = await localDataSource.getSavedUser();
      if (saved == null) return const Right(null);
      return Right(
        UserEntity(
          id: saved['id']!,
          displayName: saved['displayName']!,
          token: saved['token']!,
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      await remoteDataSource.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: _mapAuthError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> confirmSignUp({
    required String email,
    required String code,
  }) async {
    try {
      await remoteDataSource.confirmSignUp(email: email, code: code);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: _mapAuthError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> resendConfirmationCode({
    required String email,
  }) async {
    try {
      await remoteDataSource.resendConfirmationCode(email: email);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: _mapAuthError(e)));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final authData = await remoteDataSource.signIn(
        email: email,
        password: password,
      );
      final user = UserEntity(
        id: authData['id'] ?? '',
        displayName: authData['displayName'] ?? email,
        token: authData['token'] ?? '',
      );

      if (user.id.isEmpty || user.token.isEmpty) {
        return const Left(UnknownFailure(message: 'Invalid token payload from Cognito'));
      }

      await localDataSource.saveUser(
        id: user.id,
        displayName: user.displayName,
        token: user.token,
      );
      return Right(user);
    } catch (e) {
      return Left(UnknownFailure(message: _mapAuthError(e)));
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

  String _mapAuthError(Object error) {
    final raw = error.toString();
    final lower = raw.toLowerCase();

    if (lower.contains('usernameexistsexception')) {
      return 'Account already exists. Please login or verify your email.';
    }
    if (lower.contains('usernotfoundexception')) {
      return 'No account found with this email.';
    }
    if (lower.contains('notauthorizedexception')) {
      return 'Incorrect email or password.';
    }
    if (lower.contains('usernotconfirmedexception')) {
      return 'Email not verified. Please verify using the code sent to your email.';
    }
    if (lower.contains('codemismatchexception')) {
      return 'Verification code is invalid.';
    }
    if (lower.contains('expiredcodeexception')) {
      return 'Verification code has expired. Request a new code.';
    }
    if (lower.contains('invalidpasswordexception')) {
      return 'Password must be at least 8 characters and include letters and digits.';
    }
    if (lower.contains('network') || lower.contains('socket')) {
      return 'Network error. Please check your internet connection.';
    }

    return raw;
  }
}
