import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.isEmailVerified,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, email, name, isEmailVerified, createdAt, updatedAt];
}
