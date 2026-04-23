import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:agustinuszefanya_mdtest/core/errors/failures.dart';
import 'package:agustinuszefanya_mdtest/core/usecase/usecase.dart';
import 'package:agustinuszefanya_mdtest/features/auth/domain/entities/user_entity.dart';
import 'package:agustinuszefanya_mdtest/features/auth/domain/usecases/auth_usecases.dart';
import 'package:agustinuszefanya_mdtest/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agustinuszefanya_mdtest/features/auth/presentation/bloc/auth_event.dart';
import 'package:agustinuszefanya_mdtest/features/auth/presentation/bloc/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}
class MockSendEmailVerificationUseCase extends Mock implements SendEmailVerificationUseCase {}
class MockCheckVerificationStatusUseCase extends Mock implements CheckVerificationStatusUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}
class MockGoogleSignInUseCase extends Mock implements GoogleSignInUseCase {}

class FakeLoginParams extends Fake implements LoginParams {}

void main() {
  late AuthBloc bloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockResetPasswordUseCase mockResetPasswordUseCase;
  late MockSendEmailVerificationUseCase mockSendEmailVerificationUseCase;
  late MockCheckVerificationStatusUseCase mockCheckVerificationStatusUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockGoogleSignInUseCase mockGoogleSignInUseCase;

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockResetPasswordUseCase = MockResetPasswordUseCase();
    mockSendEmailVerificationUseCase = MockSendEmailVerificationUseCase();
    mockCheckVerificationStatusUseCase = MockCheckVerificationStatusUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockGoogleSignInUseCase = MockGoogleSignInUseCase();

    bloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      resetPasswordUseCase: mockResetPasswordUseCase,
      sendEmailVerificationUseCase: mockSendEmailVerificationUseCase,
      checkVerificationStatusUseCase: mockCheckVerificationStatusUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      googleSignInUseCase: mockGoogleSignInUseCase,
    );
  });

  const tUser = UserEntity(
    id: '1',
    email: 'test@test.com',
    name: 'Test User',
    isEmailVerified: true,
  );

  test('initial state should be AuthInitial', () {
    expect(bloc.state, equals(AuthInitial()));
  });

  blocTest<AuthBloc, AuthState>(
    'should emit [AuthLoading, Authenticated] when LoginRequested is successful',
    build: () {
      when(() => mockLoginUseCase(any()))
          .thenAnswer((_) async => const Right(tUser));
      return bloc;
    },
    act: (bloc) => bloc.add(const LoginRequested('test@test.com', 'password')),
    expect: () => [
      AuthLoading(),
      const Authenticated(tUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'should emit [AuthLoading, AuthError] when LoginRequested fails',
    build: () {
      when(() => mockLoginUseCase(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Server Error')));
      return bloc;
    },
    act: (bloc) => bloc.add(const LoginRequested('test@test.com', 'password')),
    expect: () => [
      AuthLoading(),
      const AuthError('Server Error'),
    ],
  );
}
