import 'package:deadline_ai/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _HomeTab(onUploadTap: () => context.push('/upload')),
      const _SimpleTab(title: 'Squads', subtitle: 'Shared board comes next.'),
      const _SimpleTab(title: 'Heatmap', subtitle: 'Stress heatmap comes next.'),
      _ProfileTab(onLogout: () => context.read<AuthCubit>().logout()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('DeadlineAI')),
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.group_outlined), label: 'Squad'),
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Heatmap'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final VoidCallback onUploadTap;

  const _HomeTab({required this.onUploadTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Primary flow ready',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Start by uploading syllabus PDFs and testing extraction review.'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onUploadTap,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Syllabus PDFs'),
          ),
        ],
      ),
    );
  }
}

class _SimpleTab extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SimpleTab({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final VoidCallback onLogout;

  const _ProfileTab({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: onLogout,
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
      ),
    );
  }
}
