import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/usecases/get_users_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetUsersUseCase getUsersUseCase;

  HomeBloc({required this.getUsersUseCase}) : super(HomeInitial()) {
    on<FetchUsers>(_onFetchUsers);
    on<SearchUsers>(_onSearchUsers);
    on<FilterUsersByStatus>(_onFilterUsersByStatus);
  }

  Future<void> _onFetchUsers(FetchUsers event, Emitter<HomeState> emit) async {
    final currentState = state;
    String? currentQuery;
    bool? currentFilter;

    if (currentState is HomeLoaded) {
      currentQuery = currentState.searchQuery;
      currentFilter = currentState.filterVerified;
    }

    emit(HomeLoading());
    final result = await getUsersUseCase(NoParams());
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (users) {
        if (currentQuery != null || currentFilter != null) {
          final filtered = _applyFilters(users, currentQuery ?? '', currentFilter);
          emit(HomeLoaded(
            allUsers: users,
            displayedUsers: filtered,
            searchQuery: currentQuery ?? '',
            filterVerified: currentFilter,
          ));
        } else {
          emit(HomeLoaded(allUsers: users, displayedUsers: users));
        }
      },
    );
  }

  void _onSearchUsers(SearchUsers event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final filteredList = _applyFilters(
        currentState.allUsers,
        event.query,
        currentState.filterVerified,
      );
      emit(currentState.copyWith(
        displayedUsers: filteredList,
        searchQuery: event.query,
      ));
    }
  }

  void _onFilterUsersByStatus(FilterUsersByStatus event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final filteredList = _applyFilters(
        currentState.allUsers,
        currentState.searchQuery,
        event.isVerified,
      );
      
      // If we are passing null, we must use clearFilter: true 
      // otherwise copyWith will keep the old value if we passed null
      if (event.isVerified == null) {
        emit(currentState.copyWith(
          displayedUsers: filteredList,
          clearFilter: true,
        ));
      } else {
        emit(currentState.copyWith(
          displayedUsers: filteredList,
          filterVerified: event.isVerified,
        ));
      }
    }
  }

  List<UserEntity> _applyFilters(List<UserEntity> users, String query, bool? filterVerified) {
    return users.where((user) {
      final matchesQuery = user.name.toLowerCase().contains(query.toLowerCase()) ||
          user.email.toLowerCase().contains(query.toLowerCase());
      final matchesFilter = filterVerified == null || user.isEmailVerified == filterVerified;
      return matchesQuery && matchesFilter;
    }).toList();
  }
}
