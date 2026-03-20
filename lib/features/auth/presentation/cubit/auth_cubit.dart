import 'package:deadline_ai/core/network/api_client.dart';
import 'package:deadline_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  final ApiClient apiClient;

  AuthCubit({required this.authRepository, required this.apiClient})
      : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        if (user == null) {
          apiClient.setAuthToken(null);
          emit(const AuthUnauthenticated());
        } else {
          apiClient.setAuthToken(user.token);
          emit(AuthAuthenticated(user));
        }
      },
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.trim().isEmpty || fullName.trim().isEmpty) {
      emit(const AuthError('Email, password and full name are required'));
      return;
    }
    if (!_isValidEmail(normalizedEmail)) {
      emit(const AuthError('Please enter a valid email address'));
      return;
    }
    if (password.length < 8) {
      emit(const AuthError('Password must be at least 8 characters'));
      return;
    }

    emit(const AuthSubmitting());
    final result = await authRepository.signUp(
      email: normalizedEmail,
      password: password,
      fullName: fullName.trim(),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(
        AuthAwaitingVerification(
          email: normalizedEmail,
          message: 'Signup successful. OTP sent to your email.',
        ),
      ),
    );
  }

  Future<void> confirmSignUp({
    required String email,
    required String code,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || code.trim().isEmpty) {
      emit(const AuthError('Email and verification code are required'));
      return;
    }
    if (!_isValidEmail(normalizedEmail)) {
      emit(const AuthError('Please enter a valid email address'));
      return;
    }

    emit(const AuthSubmitting());
    final result = await authRepository.confirmSignUp(
      email: normalizedEmail,
      code: code.trim(),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthMessage('Email verified. You can login now.')),
    );
  }

  Future<void> resendConfirmationCode({required String email}) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      emit(const AuthError('Email is required'));
      return;
    }
    if (!_isValidEmail(normalizedEmail)) {
      emit(const AuthError('Please enter a valid email address'));
      return;
    }

    emit(const AuthSubmitting());
    final result = await authRepository.resendConfirmationCode(
      email: normalizedEmail,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthMessage('Verification code sent again to your email.')),
    );
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.trim().isEmpty) {
      emit(const AuthError('Email and password are required'));
      return;
    }
    if (!_isValidEmail(normalizedEmail)) {
      emit(const AuthError('Please enter a valid email address'));
      return;
    }

    emit(const AuthSubmitting());
    final result = await authRepository.signInWithEmail(
      email: normalizedEmail,
      password: password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        apiClient.setAuthToken(user.token);
        emit(AuthAuthenticated(user));
      },
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> logout() async {
    final result = await authRepository.logout();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {
        apiClient.setAuthToken(null);
        emit(const AuthUnauthenticated());
      },
    );
  }
}
