import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:agustinuszefanya_mdtest/core/errors/failures.dart';
import 'package:agustinuszefanya_mdtest/core/usecase/usecase.dart';
import 'package:agustinuszefanya_mdtest/features/auth/domain/entities/user_entity.dart';
import 'package:agustinuszefanya_mdtest/features/home/domain/usecases/get_users_usecase.dart';
import 'package:agustinuszefanya_mdtest/features/home/presentation/bloc/home_bloc.dart';
import 'package:agustinuszefanya_mdtest/features/home/presentation/bloc/home_event.dart';
import 'package:agustinuszefanya_mdtest/features/home/presentation/bloc/home_state.dart';

class MockGetUsersUseCase extends Mock implements GetUsersUseCase {}
class FakeNoParams extends Fake implements NoParams {}

void main() {
  late HomeBloc bloc;
  late MockGetUsersUseCase mockGetUsersUseCase;

  setUpAll(() {
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockGetUsersUseCase = MockGetUsersUseCase();
    bloc = HomeBloc(getUsersUseCase: mockGetUsersUseCase);
  });

  final tUsersList = [
    const UserEntity(id: '1', email: 'test1@test.com', name: 'Zefanya', isEmailVerified: true),
    const UserEntity(id: '2', email: 'test2@test.com', name: 'Agustinus', isEmailVerified: false),
  ];

  test('initial state should be HomeInitial', () {
    expect(bloc.state, equals(HomeInitial()));
  });

  blocTest<HomeBloc, HomeState>(
    'should emit [HomeLoading, HomeLoaded] when data is gotten successfully',
    build: () {
      when(() => mockGetUsersUseCase(any()))
          .thenAnswer((_) async => Right(tUsersList));
      return bloc;
    },
    act: (bloc) => bloc.add(FetchUsers()),
    expect: () => [
      HomeLoading(),
      HomeLoaded(allUsers: tUsersList, displayedUsers: tUsersList),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'should emit [HomeLoading, HomeError] when getting data fails',
    build: () {
      when(() => mockGetUsersUseCase(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Server Error')));
      return bloc;
    },
    act: (bloc) => bloc.add(FetchUsers()),
    expect: () => [
      HomeLoading(),
      const HomeError('Server Error'),
    ],
  );
}
