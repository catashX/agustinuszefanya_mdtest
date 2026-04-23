import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:agustinuszefanya_mdtest/core/usecase/usecase.dart';
import 'package:agustinuszefanya_mdtest/features/auth/domain/entities/user_entity.dart';
import 'package:agustinuszefanya_mdtest/features/home/domain/repositories/home_repository.dart';
import 'package:agustinuszefanya_mdtest/features/home/domain/usecases/get_users_usecase.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late MockHomeRepository mockRepository;
  late GetUsersUseCase usecase;

  setUp(() {
    mockRepository = MockHomeRepository();
    usecase = GetUsersUseCase(mockRepository);
  });

  final tUsersList = [
    const UserEntity(id: '1', email: 'test1@test.com', name: 'Test 1', isEmailVerified: true),
    const UserEntity(id: '2', email: 'test2@test.com', name: 'Test 2', isEmailVerified: false),
  ];

  test('should get list of users from the repository', () async {
    when(() => mockRepository.getUsers())
        .thenAnswer((_) async => Right(tUsersList));

    final result = await usecase(NoParams());

    expect(result, Right(tUsersList));
    verify(() => mockRepository.getUsers());
    verifyNoMoreInteractions(mockRepository);
  });
}
