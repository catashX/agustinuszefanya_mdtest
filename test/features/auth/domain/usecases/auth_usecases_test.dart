import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:agustinuszefanya_mdtest/core/usecase/usecase.dart';
import 'package:agustinuszefanya_mdtest/features/auth/domain/entities/user_entity.dart';
import 'package:agustinuszefanya_mdtest/features/auth/domain/repositories/auth_repository.dart';
import 'package:agustinuszefanya_mdtest/features/auth/domain/usecases/auth_usecases.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase loginUseCase;
  late RegisterUseCase registerUseCase;
  late SendEmailVerificationUseCase sendEmailVerificationUseCase;
  late ResetPasswordUseCase resetPasswordUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepository);
    registerUseCase = RegisterUseCase(mockRepository);
    sendEmailVerificationUseCase = SendEmailVerificationUseCase(mockRepository);
    resetPasswordUseCase = ResetPasswordUseCase(mockRepository);
  });

  const tUser = UserEntity(
    id: '1',
    email: 'test@test.com',
    name: 'Test',
    isEmailVerified: false,
  );

  test('should login user from the repository', () async {
    when(() => mockRepository.login(any(), any()))
        .thenAnswer((_) async => const Right(tUser));

    final result = await loginUseCase(const LoginParams(email: 'test@test.com', password: 'password'));

    expect(result, const Right(tUser));
    verify(() => mockRepository.login('test@test.com', 'password'));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should register user from the repository', () async {
    when(() => mockRepository.register(any(), any(), any()))
        .thenAnswer((_) async => const Right(tUser));

    final result = await registerUseCase(const RegisterParams(name: 'Test', email: 'test@test.com', password: 'password'));

    expect(result, const Right(tUser));
    verify(() => mockRepository.register('Test', 'test@test.com', 'password'));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should send verification email from repository', () async {
    when(() => mockRepository.sendEmailVerification())
        .thenAnswer((_) async => const Right(null));

    final result = await sendEmailVerificationUseCase(NoParams());

    expect(result, const Right(null));
    verify(() => mockRepository.sendEmailVerification());
  });

  test('should reset password from repository', () async {
    when(() => mockRepository.resetPassword(any()))
        .thenAnswer((_) async => const Right(null));

    final result = await resetPasswordUseCase('test@test.com');

    expect(result, const Right(null));
    verify(() => mockRepository.resetPassword('test@test.com'));
  });
}
