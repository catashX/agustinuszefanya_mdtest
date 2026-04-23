import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<UserEntity>>> getUsers();
}
