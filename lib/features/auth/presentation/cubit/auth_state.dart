import 'package:deadline_ai/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSubmitting extends AuthState {
  const AuthSubmitting();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user.id, user.displayName];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthMessage extends AuthState {
  final String message;

  const AuthMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthAwaitingVerification extends AuthState {
  final String email;
  final String message;

  const AuthAwaitingVerification({
    required this.email,
    required this.message,
  });

  @override
  List<Object?> get props => [email, message];
}
