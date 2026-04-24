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
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'Community',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 24),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                },
              ),
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
            } else if (state is Authenticated) {
              // Re-fetch users to sync with the latest verification status from Firestore
              context.read<HomeBloc>().add(FetchUsers());
            }
          },
          child: Column(
            children: [
              _buildUserInfo(),
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
          final user = state.user;
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back,',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: user.isEmailVerified ? Colors.greenAccent.withOpacity(0.2) : Colors.orangeAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: user.isEmailVerified ? Colors.greenAccent : Colors.orangeAccent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        user.isEmailVerified ? 'Verified' : 'Unverified',
                        style: TextStyle(
                          color: user.isEmailVerified ? Colors.greenAccent : Colors.orangeAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!user.isEmailVerified) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<AuthBloc>().add(SendVerificationEmailRequested());
                          },
                          icon: const Icon(Icons.mark_email_unread_outlined, size: 18),
                          label: const Text('Verify Email'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2575FC),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(CheckVerificationStatusRequested());
                        },
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        tooltip: 'Refresh status',
                      ),
                    ],
                  ),
                ],
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search friends...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    onChanged: (value) {
                      context.read<HomeBloc>().add(SearchUsers(value));
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool?>(
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Colors.white,
                      selectedBackgroundColor: Colors.blueAccent,
                      selectedForegroundColor: Colors.white,
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[200]!, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    segments: const [
                      ButtonSegment<bool?>(
                        value: null,
                        label: Text('All', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      ButtonSegment<bool?>(
                        value: true,
                        label: Text('Verified', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      ButtonSegment<bool?>(
                        value: false,
                        label: Text('Unverified', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                    selected: {state.filterVerified},
                    showSelectedIcon: false,
                    onSelectionChanged: (Set<bool?> newSelection) {
                      context.read<HomeBloc>().add(FilterUsersByStatus(newSelection.first));
                    },
                  ),
                ),
                const SizedBox(height: 16),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(state.message, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        } else if (state is HomeLoaded) {
          final users = state.displayedUsers;
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No users found.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              // Filter out users with placeholder data if needed, but let's just show them styled
              if (user.name == '-' || user.name.isEmpty) {
                return const SizedBox.shrink(); 
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    user.email,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: user.isEmailVerified ? Colors.green[50] : Colors.grey[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      user.isEmailVerified ? Icons.check_circle : Icons.help_outline,
                      color: user.isEmailVerified ? Colors.green : Colors.grey[400],
                      size: 20,
                    ),
                  ),
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
