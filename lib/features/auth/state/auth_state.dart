import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  const AuthState({
    required this.isLoading,
    required this.isAuthenticated,
    this.user,
    this.error,
  });

  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
    );
  }

  factory AuthState.initial() {
    return const AuthState(
      isLoading: true,
      isAuthenticated: false,
    );
  }

  factory AuthState.authenticated(User user) {
    return AuthState(
      isLoading: false,
      isAuthenticated: true,
      user: user,
    );
  }

  factory AuthState.unauthenticated() {
    return const AuthState(
      isLoading: false,
      isAuthenticated: false,
    );
  }
}
