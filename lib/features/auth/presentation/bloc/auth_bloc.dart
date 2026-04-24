import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final SendEmailVerificationUseCase sendEmailVerificationUseCase;
  final CheckVerificationStatusUseCase checkVerificationStatusUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GoogleSignInUseCase googleSignInUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.resetPasswordUseCase,
    required this.sendEmailVerificationUseCase,
    required this.checkVerificationStatusUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.googleSignInUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<SendVerificationEmailRequested>(_onSendVerificationEmailRequested);
    on<CheckVerificationStatusRequested>(_onCheckVerificationStatusRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatusRequested>(_onCheckAuthStatusRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    debugPrint('AuthBloc: LoginRequested for ${event.email}');
    emit(AuthLoading());
    final result = await loginUseCase(LoginParams(email: event.email, password: event.password));
    result.fold(
      (failure) {
        debugPrint('AuthBloc: Login Failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        debugPrint('AuthBloc: Login Success: ${user.email}');
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    debugPrint('AuthBloc: RegisterRequested for ${event.email}');
    emit(AuthLoading());
    final result = await registerUseCase(RegisterParams(name: event.name, email: event.email, password: event.password));
    result.fold(
      (failure) {
        debugPrint('AuthBloc: Register Failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        debugPrint('AuthBloc: Register Success: ${user.email}');
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onResetPasswordRequested(ResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await resetPasswordUseCase(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(PasswordResetEmailSent()),
    );
  }

  Future<void> _onSendVerificationEmailRequested(SendVerificationEmailRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await sendEmailVerificationUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(VerificationEmailSent()),
    );
  }

  Future<void> _onCheckVerificationStatusRequested(CheckVerificationStatusRequested event, Emitter<AuthState> emit) async {
    if (state is Authenticated) {
      final currentUser = (state as Authenticated).user;
      final result = await checkVerificationStatusUseCase(NoParams());
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (isVerified) {
          // If verified status changed, emit new state
          if (currentUser.isEmailVerified != isVerified) {
            emit(Authenticated(currentUser.copyWith(isEmailVerified: isVerified)));
          }
        },
      );
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await logoutUseCase(NoParams());
    emit(Unauthenticated());
  }

  Future<void> _onCheckAuthStatusRequested(CheckAuthStatusRequested event, Emitter<AuthState> emit) async {
    debugPrint('AuthBloc: CheckAuthStatusRequested');
    emit(AuthLoading());
    final result = await getCurrentUserUseCase(NoParams());
    result.fold(
      (failure) {
        debugPrint('AuthBloc: CheckAuthStatus Failed: ${failure.message}');
        emit(Unauthenticated());
      },
      (user) {
        if (user != null) {
          debugPrint('AuthBloc: CheckAuthStatus - Authenticated: ${user.email}');
          emit(Authenticated(user));
        } else {
          debugPrint('AuthBloc: CheckAuthStatus - Unauthenticated');
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await googleSignInUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }
}
