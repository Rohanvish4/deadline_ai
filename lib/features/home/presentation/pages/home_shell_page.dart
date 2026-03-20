import 'package:deadline_ai/features/deadlines/presentation/cubit/deadline_cubit.dart';
import 'package:deadline_ai/features/deadlines/presentation/cubit/deadline_state.dart';
import 'package:deadline_ai/features/heatmap/presentation/pages/heatmap_page.dart';
import 'package:deadline_ai/features/profile/presentation/pages/profile_page.dart';
import 'package:deadline_ai/features/squad/presentation/pages/squad_page.dart';
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
  void initState() {
    super.initState();
    context.read<DeadlineCubit>().fetchDeadlines();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _HomeTab(onUploadTap: () => context.push('/upload')),
      const SquadPage(),
      const HeatmapPage(),
      const ProfilePage(),
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
    return BlocBuilder<DeadlineCubit, DeadlineState>(
      builder: (context, state) {
        final deadlines = state.deadlines;
        return RefreshIndicator(
          onRefresh: () => context.read<DeadlineCubit>().fetchDeadlines(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text('Track deadlines, detect clashes and plan sessions.'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.event_note,
                      title: 'Total deadlines',
                      value: '${deadlines.length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.warning_amber_rounded,
                      title: 'Clashes',
                      value: '${state.clashes.length}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onUploadTap,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload syllabus PDF'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: state.isLoadingClashes
                    ? null
                    : () => context.read<DeadlineCubit>().fetchClashes(withPlan: true),
                icon: const Icon(Icons.auto_graph),
                label: Text(state.isLoadingClashes ? 'Analyzing...' : 'Analyze clashes'),
              ),
              const SizedBox(height: 16),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (deadlines.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No deadlines yet. Upload your syllabus to get started.'),
                  ),
                )
              else
                ...deadlines.take(8).map(
                      (deadline) => Card(
                        child: ListTile(
                          title: Text(deadline.title),
                          subtitle: Text(
                            '${deadline.courseCode ?? deadline.courseName ?? 'General'} • ${deadline.dueDate}',
                          ),
                          trailing: Text(
                            (deadline.priorityScore ?? 0).toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 10),
            Text(title),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

