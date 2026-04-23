import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class FetchUsers extends HomeEvent {}

class SearchUsers extends HomeEvent {
  final String query;

  const SearchUsers(this.query);

  @override
  List<Object> get props => [query];
}

class FilterUsersByStatus extends HomeEvent {
  final bool? isVerified; // null means all

  const FilterUsersByStatus(this.isVerified);

  @override
  List<Object> get props => [isVerified ?? false];
}
