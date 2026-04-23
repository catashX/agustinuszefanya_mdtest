import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<UserEntity> allUsers;
  final List<UserEntity> displayedUsers;
  final String searchQuery;
  final bool? filterVerified;

  const HomeLoaded({
    required this.allUsers,
    required this.displayedUsers,
    this.searchQuery = '',
    this.filterVerified,
  });

  HomeLoaded copyWith({
    List<UserEntity>? allUsers,
    List<UserEntity>? displayedUsers,
    String? searchQuery,
    bool? filterVerified,
    bool clearFilter = false,
  }) {
    return HomeLoaded(
      allUsers: allUsers ?? this.allUsers,
      displayedUsers: displayedUsers ?? this.displayedUsers,
      searchQuery: searchQuery ?? this.searchQuery,
      filterVerified: clearFilter ? null : (filterVerified ?? this.filterVerified),
    );
  }

  @override
  List<Object> get props => [
        allUsers,
        displayedUsers,
        searchQuery,
        filterVerified ?? false,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
