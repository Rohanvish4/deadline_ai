import 'package:deadline_ai/features/deadlines/presentation/cubit/deadline_cubit.dart';
import 'package:deadline_ai/features/deadlines/presentation/cubit/deadline_state.dart';
import 'package:deadline_ai/features/syllabus_ingestion/presentation/cubit/syllabus_ingestion_cubit.dart';
import 'package:deadline_ai/features/syllabus_ingestion/presentation/cubit/syllabus_ingestion_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UploadSyllabusPage extends StatelessWidget {
  const UploadSyllabusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Syllabus PDFs')),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SyllabusIngestionCubit, SyllabusIngestionState>(
            listenWhen: (previous, current) => previous.errorMessage != current.errorMessage,
            listener: (context, state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!)),
                );
              }
            },
          ),
          BlocListener<DeadlineCubit, DeadlineState>(
            listenWhen: (previous, current) => previous.confirmResponse != current.confirmResponse,
            listener: (context, state) {
              if (state.confirmResponse != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deadlines confirmed successfully')),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<SyllabusIngestionCubit, SyllabusIngestionState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: state.isLoading
                            ? null
                            : () => context.read<SyllabusIngestionCubit>().pickPdfFiles(),
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Pick PDF'),
                      ),
                      ElevatedButton.icon(
                        onPressed: state.isLoading
                            ? null
                            : () => context.read<SyllabusIngestionCubit>().extractDeadlines(),
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Extract deadlines'),
                      ),
                      BlocBuilder<DeadlineCubit, DeadlineState>(
                        builder: (context, deadlineState) {
                          return OutlinedButton.icon(
                            onPressed: deadlineState.isConfirming || state.extractedDeadlines.isEmpty
                                ? null
                                : () => context
                                    .read<DeadlineCubit>()
                                    .confirmExtractedDeadlines(state.extractedDeadlines),
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(
                              deadlineState.isConfirming ? 'Confirming...' : 'Confirm extracted',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Selected files: ${state.files.length}'),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: [
                        ...state.files.map(
                          (f) => ListTile(
                            leading: const Icon(Icons.picture_as_pdf),
                            title: Text(f.name),
                            subtitle: Text('${(f.size / 1024).toStringAsFixed(1)} KB'),
                          ),
                        ),
                        if (state.isLoading)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        if (state.extractedDeadlines.isNotEmpty) ...[
                          const Divider(height: 32),
                          const Text(
                            'Extraction review',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...state.extractedDeadlines.map(
                            (deadline) => Card(
                              child: ListTile(
                                title: Text(deadline.title),
                                subtitle: Text(
                                  '${deadline.courseCode ?? deadline.courseName ?? 'Unknown Course'} • ${deadline.dueDate}',
                                ),
                                trailing: Text('${(deadline.confidence * 100).toStringAsFixed(0)}%'),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
