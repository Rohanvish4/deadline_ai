import 'package:deadline_ai/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:deadline_ai/features/auth/presentation/cubit/auth_state.dart';
import 'package:deadline_ai/features/deadlines/presentation/cubit/deadline_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final authed = state is AuthAuthenticated ? state.user : null;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(authed?.displayName ?? 'Unknown user'),
                subtitle: Text('User ID: ${authed?.id ?? '-'}'),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.read<DeadlineCubit>().fetchDeadlines(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh deadlines'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.read<AuthCubit>().logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
