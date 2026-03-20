import 'package:deadline_ai/features/deadlines/presentation/cubit/deadline_cubit.dart';
import 'package:deadline_ai/features/deadlines/presentation/cubit/deadline_state.dart';
import 'package:deadline_ai/features/heatmap/presentation/cubit/autopsy_cubit.dart';
import 'package:deadline_ai/features/heatmap/presentation/cubit/autopsy_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HeatmapPage extends StatefulWidget {
  const HeatmapPage({super.key});

  @override
  State<HeatmapPage> createState() => _HeatmapPageState();
}

class _HeatmapPageState extends State<HeatmapPage> {
  final _deadlineIdController = TextEditingController();
  final _wellController = TextEditingController();
  final _wrongController = TextEditingController();
  int _satisfaction = 3;
  bool _completedOnTime = true;

  @override
  void dispose() {
    _deadlineIdController.dispose();
    _wellController.dispose();
    _wrongController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AutopsyCubit, AutopsyState>(
          listenWhen: (previous, current) => previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
            if (state.response != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Autopsy submitted')), 
              );
            }
          },
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Stress & Insight',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text('Detect clashes and submit post-deadline autopsies.'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: BlocBuilder<DeadlineCubit, DeadlineState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Clash analysis',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: state.isLoadingClashes
                                ? null
                                : () => context.read<DeadlineCubit>().fetchClashes(withPlan: true),
                            child: Text(state.isLoadingClashes ? 'Analyzing...' : 'Run'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (state.clashes.isEmpty)
                        const Text('No clashes loaded yet.')
                      else
                        ...state.clashes.take(3).map(
                              (clash) => ListTile(
                                dense: true,
                                title: Text('${clash.deadlineA['title']} vs ${clash.deadlineB['title']}'),
                                subtitle: Text(
                                  '${clash.daysBetween} day gap • ${clash.combinedWeight.toStringAsFixed(0)}% weight',
                                ),
                                trailing: Text(clash.severity),
                              ),
                            ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: BlocBuilder<AutopsyCubit, AutopsyState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Deadline autopsy',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _deadlineIdController,
                        decoration: const InputDecoration(labelText: 'Deadline ID'),
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile.adaptive(
                        value: _completedOnTime,
                        title: const Text('Completed on time'),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) => setState(() => _completedOnTime = value),
                      ),
                      const SizedBox(height: 4),
                      Text('Satisfaction: $_satisfaction / 5'),
                      Slider(
                        min: 1,
                        max: 5,
                        divisions: 4,
                        value: _satisfaction.toDouble(),
                        onChanged: (value) => setState(() => _satisfaction = value.toInt()),
                      ),
                      TextField(
                        controller: _wellController,
                        decoration: const InputDecoration(labelText: 'What went well'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _wrongController,
                        decoration: const InputDecoration(labelText: 'What went wrong'),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () => context.read<AutopsyCubit>().submitAutopsy(
                                    deadlineId: _deadlineIdController.text,
                                    completedOnTime: _completedOnTime,
                                    satisfaction: _satisfaction,
                                    whatWentWell: _wellController.text,
                                    whatWentWrong: _wrongController.text,
                                  ),
                          child: Text(state.isSubmitting ? 'Submitting...' : 'Submit autopsy'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
