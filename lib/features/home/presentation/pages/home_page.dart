import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../dependency_injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(FetchUsers()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
            )
          ],
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          },
          child: Column(
            children: [
              _buildUserInfo(),
              const Divider(),
              _buildSearchAndFilter(),
              Expanded(
                child: _buildUserList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, ${state.user.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Status: ', style: const TextStyle(fontSize: 16)),
                    Chip(
                      label: Text(state.user.isEmailVerified ? 'Verified' : 'Not Verified'),
                      backgroundColor: state.user.isEmailVerified ? Colors.green.shade100 : Colors.red.shade100,
                    ),
                  ],
                ),
                if (!state.user.isEmailVerified) ...[
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(SendVerificationEmailRequested());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verification email sent')),
                      );
                    },
                    child: const Text('Resend Verification Email'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(CheckVerificationStatusRequested());
                    },
                    child: const Text('Refresh Status'),
                  ),
                ]
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildSearchAndFilter() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search by Name or Email',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    context.read<HomeBloc>().add(SearchUsers(value));
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: state.filterVerified == null,
                      onSelected: (selected) {
                        if (selected) context.read<HomeBloc>().add(const FilterUsersByStatus(null));
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Verified'),
                      selected: state.filterVerified == true,
                      onSelected: (selected) {
                        if (selected) context.read<HomeBloc>().add(const FilterUsersByStatus(true));
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Not Verified'),
                      selected: state.filterVerified == false,
                      onSelected: (selected) {
                        if (selected) context.read<HomeBloc>().add(const FilterUsersByStatus(false));
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildUserList() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is HomeError) {
          return Center(child: Text(state.message));
        } else if (state is HomeLoaded) {
          final users = state.displayedUsers;
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(child: Text(user.name.substring(0, 1).toUpperCase())),
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: Icon(
                  user.isEmailVerified ? Icons.check_circle : Icons.cancel,
                  color: user.isEmailVerified ? Colors.green : Colors.red,
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}
