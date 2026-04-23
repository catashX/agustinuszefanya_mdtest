import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/home_repository.dart';

class GetUsersUseCase implements UseCase<List<UserEntity>, NoParams> {
  final HomeRepository repository;

  GetUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(NoParams params) async {
    return await repository.getUsers();
  }
}
